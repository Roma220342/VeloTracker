import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/code_verification_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/rides_screen.dart';
import 'screens/track_screen.dart';
import 'screens/ride_summary_screen.dart';
import 'screens/settings_screen.dart';

// main.dart
void main() {
  runApp(const VeloTrackerApp());
}

class VeloTrackerApp extends StatelessWidget {
  const VeloTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VeloTracker',
      theme: lightTheme,
      builder: (context, child) {
       
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      home: const SettingsScreen(),
      
    );
  }
}

