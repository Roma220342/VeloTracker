import 'package:flutter/material.dart';
import 'package:velotracker/screens/welcom_screens/splash_screen.dart';
import 'screens/rides_screens/rides_screen.dart';
import 'screens/track_screns/track_screen.dart';
import 'screens/settings_screen.dart';
import 'package:velotracker/services/settings_service.dart';
import 'package:velotracker/theme/app_theme.dart';

void main() {
  SettingsController().loadSettings();
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
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Починаємо з індексу 1 (Rides), щоб це був перший екран
  int _currentIndex = 1;

  // Список екранів для IndexedStack
  final List<Widget> _screens = [
    const SizedBox(), // Індекс 0: Заглушка (Track відкривається окремо)
    const RidesScreen(), // Індекс 1: Rides
    const SettingsScreen(), // Індекс 2: Settings
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      // IndexedStack зберігає стан екранів при перемиканні
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Важливо для коректного відображення кольорів
        
        onTap: (index) {
          if (index == 0) {
            // Якщо натиснули "Track" - відкриваємо його як повноекранну сторінку (поверх меню)
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TrackScreen(),
              ),
            );
          } else {
            // Для інших вкладок (Rides, Settings) просто перемикаємо індекс
            setState(() => _currentIndex = index);
          }
        },
        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_button_checked),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}