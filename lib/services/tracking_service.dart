import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:velotracker/models/ride_realtime_data.dart';

class TrackingService {
  // --- Приватні змінні ---
  StreamSubscription<Position>? _positionStream;
  Timer? _timer;
  
  // Дані поїздки
  Duration _elapsedTime = Duration.zero;
  double _totalDistanceMeters = 0;
  
  // Тут ми зберігаємо маршрут у простому форматі, який легко відправити на сервер
  List<Map<String, double>> _routePoints = []; 
  
  Position? _lastPosition;
  double _maxSpeedKph = 0;

  // --- "Радіо" для UI ---
  // Через цей контролер ми будемо відправляти оновлення на екран
  final _dataController = StreamController<RideRealtimeData>.broadcast();
  Stream<RideRealtimeData> get dataStream => _dataController.stream;

  // Геттери, щоб забрати фінальні дані при завершенні
  List<Map<String, double>> get fullRoute => _routePoints;
  double get maxSpeedKph => _maxSpeedKph;
  Duration get currentDuration => _elapsedTime;
  double get currentDistanceKm => _totalDistanceMeters / 1000;

  // --- 1. START ---
  Future<bool> startTracking() async {
    // Перевірка дозволів (винесли з UI)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) {
      return false; // Можна додати обробку відкриття налаштувань
    }

    // Скидаємо старі дані перед стартом
    _resetData();

    // Запуск таймера (оновлює час кожну секунду)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      // Оновлюємо UI (швидкість поки 0 або остання відома, але тут передаємо 0 для безпеки таймера)
      // Краще передавати _lastSpeed, але для простоти поки так:
      _emitUpdate(); 
    });

    // Налаштування GPS
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Оновлювати, якщо проїхав 5 метрів
    );

    // Підписка на координати
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _processLocation(position);
    });

    return true;
  }

  // --- 2. ОБРОБКА КООРДИНАТ ---
  void _processLocation(Position newPosition) {
    double distDelta = 0;
    
    // Рахуємо відстань від попередньої точки
    if (_lastPosition != null) {
      distDelta = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );
    }

    // Швидкість (м/с -> км/год)
    double speedKmH = newPosition.speed * 3.6;
    if (speedKmH < 0) speedKmH = 0;
    
    // Фіксуємо макс. швидкість
    if (speedKmH > _maxSpeedKph) _maxSpeedKph = speedKmH;

    _totalDistanceMeters += distDelta;
    
    // Додаємо точку в маршрут
    _routePoints.add({
      'lat': newPosition.latitude,
      'lng': newPosition.longitude,
    });
    
    _lastPosition = newPosition;

    // Відправляємо дані на екран
    _emitUpdate(currentSpeedOverride: speedKmH);
  }

  // Відправка пакету даних
  void _emitUpdate({double? currentSpeedOverride}) {
    // Якщо швидкість не передана (наприклад, від таймера), ставимо 0 або останню відому
    // Для простоти, якщо це таймер - не оновлюємо швидкість, якщо GPS - оновлюємо
    
    double speed = currentSpeedOverride ?? 0.0;
    // (В ідеальній реалізації можна зберігати останню актуальну швидкість)

    _dataController.add(RideRealtimeData(
      duration: _elapsedTime,
      distanceKm: _totalDistanceMeters / 1000,
      currentSpeed: speed,
    ));
  }

  // --- 3. PAUSE / RESUME ---
  void pauseTracking() {
    _positionStream?.pause(); // GPS на паузу
    _timer?.cancel();         // Таймер стоп
  }

  void resumeTracking() {
    _positionStream?.resume();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      _emitUpdate();
    });
  }

  // --- 4. STOP ---
  void stopTracking() {
    _positionStream?.cancel();
    _timer?.cancel();
  }

  void _resetData() {
    _elapsedTime = Duration.zero;
    _totalDistanceMeters = 0;
    _routePoints = [];
    _lastPosition = null;
    _maxSpeedKph = 0;
  }
}