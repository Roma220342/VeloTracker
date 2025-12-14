import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:velotracker/models/ride_realtime_data.dart';
import 'package:velotracker/utils/app_logger.dart';

class TrackingService {
  static const double _speedThresholdKmh = 1.0;
  static const int _signalLostTimeoutMs = 5000;

  StreamSubscription<Position>? _positionStream;
  Timer? _timer;

  Duration _elapsedTime = Duration.zero;
  double _totalDistanceMeters = 0;
  double _currentSpeedKmH = 0;
  double _maxSpeedKmH = 0;

  DateTime _lastGpsUpdate = DateTime.now();
  Position? _lastPosition;
  List<Map<String, double>> _routePoints = [];

  final _dataController = StreamController<RideRealtimeData>.broadcast();
  Stream<RideRealtimeData> get dataStream => _dataController.stream;

  List<Map<String, double>> get fullRoute => _routePoints;
  double get maxSpeedKph => _maxSpeedKmH;
  Duration get currentDuration => _elapsedTime;
  double get currentDistanceKm => _totalDistanceMeters / 1000;

  Future<bool> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    _resetData();

    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "VeloTracker",
          notificationText: "Recording your ride...",
          notificationIcon: AndroidResource(name: 'ic_launcher'),
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.fitness,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    }

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      _processLocation(position);
    }, onError: (e) {
      logger.e("Tracking Error: $e");
    });

    _startTimer();

    return true;
  }

  void pauseTracking() {
    _positionStream?.pause();
    _timer?.cancel();
    _currentSpeedKmH = 0;
    _emitUpdate();
  }

  void resumeTracking() {
    _positionStream?.resume();
    _lastGpsUpdate = DateTime.now();
    _startTimer();
  }

  void stopTracking() {
    _positionStream?.cancel();
    _timer?.cancel();
    _positionStream = null;
    _timer = null;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      _checkSignalLoss();
      _emitUpdate();
    });
  }

  void _processLocation(Position newPosition) {
    _lastGpsUpdate = DateTime.now();

    double distDelta = 0;
    if (_lastPosition != null) {
      distDelta = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );
    }

    double rawSpeed = newPosition.speed * 3.6;

    if (rawSpeed < _speedThresholdKmh) {
      _currentSpeedKmH = 0;
    } else {
      _currentSpeedKmH = rawSpeed;
    }

    if (_currentSpeedKmH > _maxSpeedKmH) {
      _maxSpeedKmH = _currentSpeedKmH;
    }

    _totalDistanceMeters += distDelta;
    _lastPosition = newPosition;

    _routePoints.add({
      'lat': newPosition.latitude,
      'lng': newPosition.longitude,
    });

    _emitUpdate();
  }

  void _checkSignalLoss() {
    final timeSinceLastUpdate =
        DateTime.now().difference(_lastGpsUpdate).inMilliseconds;

    if (timeSinceLastUpdate > _signalLostTimeoutMs &&
        _currentSpeedKmH > 0) {
      _currentSpeedKmH = 0;
    }
  }

  void _emitUpdate() {
    if (!_dataController.isClosed) {
      _dataController.add(RideRealtimeData(
        duration: _elapsedTime,
        distanceKm: _totalDistanceMeters / 1000,
        currentSpeed: _currentSpeedKmH,
      ));
    }
  }

  void _resetData() {
    _elapsedTime = Duration.zero;
    _totalDistanceMeters = 0;
    _currentSpeedKmH = 0;
    _maxSpeedKmH = 0;
    _routePoints = [];
    _lastPosition = null;
    _lastGpsUpdate = DateTime.now();
  }
}
