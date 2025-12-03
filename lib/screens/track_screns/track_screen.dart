import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart';
import 'package:velotracker/widgets/tracks_widgets/discard_dialog.dart'; 
import 'package:flutter_svg/flutter_svg.dart';

enum TrackingState { ready, tracking, paused }

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  TrackingState _currentState = TrackingState.ready;

  // Заглушки для метрик (Стартові значення - нулі)
  String _duration = "00:00:00";
  String _distance = "0.00";
  String _speed = "0.0"; 

  // --- ЛОГІКА ПЕРЕХОДІВ ---

  void _onStart() {
    setState(() {
      _currentState = TrackingState.tracking;
      // TODO: Тут запуститься таймер, і _duration почне змінюватися
    });
  }

  void _onPause() {
    setState(() {
      _currentState = TrackingState.paused;
    });
  }

  void _onResume() {
    setState(() {
      _currentState = TrackingState.tracking;
    });
  }

  void _onFinish() {
    setState(() {
      _currentState = TrackingState.ready;
      _duration = "00:00:00";
      _distance = "0.00";
      _speed = "0.0";
    });
  }

  void _onBackPressed() {
    if (_currentState == TrackingState.ready) {
      Navigator.of(context).pop(); 
    } else {
      showDialog(
        context: context,
        builder: (context) => DiscardDialog(
          onConfirm: () {
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
    final screenHeight = MediaQuery.of(context).size.height;
    final padding64 = screenHeight * 0.075;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        backgroundColor: isPaused ? pauseColor : theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: textPrimaryColor,
          onPressed: _onBackPressed,
        ),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: isPaused ? pauseColor : theme.colorScheme.surface, 
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Text(
                  _duration,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 48
                  ),
                ),
                Text('Duration', style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          SizedBox(height: padding64),
          Expanded(
            child: Column(
              children: [
                Text(
                  _distance,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 152
                  ),
                ),
                const SizedBox(height: 8),
                Text('Distance (km)', style: theme.textTheme.bodyMedium),
                
                SizedBox(height: padding64),
    
                Text(
                  _speed,
                   style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 128
                  ),
                ),
                const SizedBox(height: 8),
                Text('Speed (km/h)', style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
            
          Padding(
            padding: EdgeInsets.only(
              bottom: padding64, 
              left: 16, 
              right: 16,
            ),
            child: _buildControlButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    switch (_currentState) {
      case TrackingState.ready:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onStart,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  SvgPicture.asset(
                  'assets/icons/start.svg',
                ),
                SizedBox(width: 4),
                const Text('Start')  
              ]
            ),
          ),
        );
      

      case TrackingState.tracking:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _onPause,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  SvgPicture.asset(
                  'assets/icons/pause.svg',
                ),
                SizedBox(width: 4),
                const Text('Pause')  
              ]
            ),
          ),
        );

      case TrackingState.paused:
        return Row(
          children: [
           
            Expanded(
              child: SizedBox(
                child: ElevatedButton(
                  onPressed: _onResume,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        SvgPicture.asset(
                        'assets/icons/start.svg',
                      ),
                      SizedBox(width: 4),
                      const Text('Resume')  
                    ]
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Finish
            Expanded(
                    child: SizedBox(
                     child: OutlinedButton(
                  onPressed: _onFinish,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: pauseColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        SvgPicture.asset(
                        'assets/icons/finish.svg',
                      ),
                      SizedBox(width: 4),
                      const Text('Finish')  
                    ]
                  ),
                ),
              ),
            ),
    ],
  );
}
}
}