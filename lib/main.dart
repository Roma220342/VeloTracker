import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // 👇 Додано
import 'package:velotracker/services/auth_service.dart';           // 👇 Додано
import 'package:velotracker/screens/welcom_screens/welcome_screen.dart'; // 👇 Додано
import 'screens/rides_screens/rides_screen.dart';
import 'screens/track_screns/track_screen.dart';
import 'screens/settings_screen.dart';
import 'package:velotracker/services/settings_service.dart';
import 'package:velotracker/theme/app_theme.dart';

void main() async {
  // 1. Обов'язкова ініціалізація для виконання асинхронного коду до runApp
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. Утримуємо нативний сплеш-екран на дисплеї
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Завантажуємо налаштування
  SettingsController().loadSettings();

  // 3. Перевіряємо авторизацію ДО того, як малювати інтерфейс
  final String? token = await AuthService().getToken();

  // 4. Запускаємо додаток і передаємо йому знайдений токен
  runApp(VeloTrackerApp(initialToken: token));

  // 5. Тепер, коли Flutter готовий малювати потрібний екран, прибираємо сплеш-екран
  FlutterNativeSplash.remove();
}

class VeloTrackerApp extends StatelessWidget {
  final String? initialToken; // Отримуємо токен через конструктор

  const VeloTrackerApp({super.key, this.initialToken});

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
      // Якщо токен є - йдемо на головний екран, якщо немає - на WelcomeScreen
      home: initialToken != null ? const MainScreen() : const WelcomeScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  final List<Widget> _screens = [
    const SizedBox(), 
    const RidesScreen(), 
    const SettingsScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, 
        
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TrackScreen(),
              ),
            );
          } else {
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