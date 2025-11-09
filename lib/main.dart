import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';

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
        // Ігноруємо системне масштабування шрифтів, 
        // щоб завжди відповідати макету Figma (100% = 1.0)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      home: const WelcomeScreen (),
      
    );
  }
}

