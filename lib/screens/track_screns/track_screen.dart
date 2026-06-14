import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velotracker/models/ride_realtime_data.dart';
import 'package:velotracker/screens/track_screns/ride_summary_screen.dart';
import 'package:velotracker/services/settings_service.dart';
import 'package:velotracker/services/tracking_service.dart';
import 'package:velotracker/theme/app_theme.dart';
import 'package:velotracker/widgets/tracks_widgets/discard_dialog.dart';

enum TrackingState { ready, tracking, paused }

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final TrackingService _trackingService = TrackingService();

  TrackingState _currentState = TrackingState.ready;
  RideRealtimeData _currentData = RideRealtimeData.initial();

  @override
  void dispose() {
    if (_currentState != TrackingState.ready) {
      _trackingService.stopTracking();
    }
    super.dispose();
  }

  Future<void> _onStart() async {
    bool started = await _trackingService.startTracking();

    if (started) {
      setState(() => _currentState = TrackingState.tracking);

      _trackingService.dataStream.listen((data) {
        if (mounted) {
          setState(() {
            _currentData = data;
          });
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GPS permission needed to track ride')),
        );
      }
    }
  }

  void _onPause() {
    _trackingService.pauseTracking();
    setState(() => _currentState = TrackingState.paused);
  }

  void _onResume() {
    _trackingService.resumeTracking();
    setState(() => _currentState = TrackingState.tracking);
  }

  Future<void> _onFinish() async {
    // 1. Ставимо на паузу, щоб не втратити дані
    _trackingService.pauseTracking();

    setState(() => _currentState = TrackingState.paused);

    // 2. Забираємо СИРІ дані (в км та км/год) для збереження в базу
    final double distanceKm = _trackingService.currentDistanceKm;
    final Duration duration = _trackingService.currentDuration;

    final double hours = duration.inSeconds / 3600;
    final double avgSpeed = hours > 0 ? distanceKm / hours : 0;

    // 3. Переходимо на екран підсумків
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RideSummaryScreen(
          distanceKm: distanceKm, // Передаємо в КМ (база завжди в метричній)
          duration: duration,
          avgSpeed: avgSpeed,
          maxSpeed: _trackingService.maxSpeedKph,
          routePoints: List.from(_trackingService.fullRoute),
          startTime: DateTime.now().subtract(duration),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  void _onBackPressed() {
    if (_currentState == TrackingState.ready) {
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) => DiscardDialog(
          onConfirm: () {
            _trackingService.stopTracking();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isPaused = _currentState == TrackingState.paused;
    
    return ListenableBuilder(
        listenable: SettingsController(),
        builder: (context, child) {
          final settings = SettingsController();

          final double displayDist = settings.convertDistance(_currentData.distanceKm);
          final double displaySpeed = settings.convertSpeed(_currentData.currentSpeed);

          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              backgroundColor: isPaused ? pauseColor : theme.colorScheme.surface,
              elevation: 0,
              leading: BackButton(
                color: textPrimaryColor,
                onPressed: _onBackPressed,
              ),
            ),
            // SafeArea захищає від накладання на Dynamic Island зверху та Home Indicator знизу
            body: SafeArea(
              child: Column(
                children: [
                  // ТАЙМЕР
                  Container(
                    width: double.infinity,
                    color: isPaused ? pauseColor : theme.colorScheme.surface,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatDuration(_currentData.duration),
                            // height: 1.1 прибирає зайве пусте місце над/під шрифтом
                            style: theme.textTheme.headlineLarge?.copyWith(fontSize: 48, height: 1.1),
                          ),
                        ),
                        Text('Duration', style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ),

                  // Гнучкий простір замість жорсткого padding64
                  const Spacer(flex: 1),

                  // ЦЕНТРАЛЬНА ЧАСТИНА: ДИСТАНЦІЯ ТА ШВИДКІСТЬ
                  Expanded(
                    flex: 8, // Віддаємо максимум вільного місця під блок з цифрами
                    child: Padding(
                      // Горизонтальні відступи обов'язкові, щоб FittedBox знав межі звуження
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Дистанція
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                displayDist.toStringAsFixed(2),
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontSize: 152,
                                  height: 1.0, 
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Distance (${settings.distanceUnit})',
                              style: theme.textTheme.bodyMedium),

                          // Пружина між дистанцією та швидкістю
                          const Spacer(flex: 2),

                          // Швидкість
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                displaySpeed.toStringAsFixed(1),
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontSize: 128,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Speed (${settings.speedUnit})',
                              style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // НИЗ: КНОПКИ
                  Padding(
                    // Зменшили нижній відступ до 16, оскільки SafeArea вже додає відступ від краю
                    padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                    child: _buildControlButtons(),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildControlButtons() {
    switch (_currentState) {
      case TrackingState.ready:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onStart,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPicture.asset('assets/icons/start.svg'),
              const SizedBox(width: 4),
              const Text('Start')
            ]),
          ),
        );

      case TrackingState.tracking:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _onPause,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPicture.asset('assets/icons/pause.svg'),
              const SizedBox(width: 4),
              const Text('Pause')
            ]),
          ),
        );

      case TrackingState.paused:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _onResume,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/start.svg'),
                      const SizedBox(width: 4),
                      const Text('Resume')
                    ]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: _onFinish,
                style: OutlinedButton.styleFrom(backgroundColor: pauseColor),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/finish.svg'),
                      const SizedBox(width: 4),
                      const Text('Finish')
                    ]),
              ),
            ),
          ],
        );
    }
  }
}