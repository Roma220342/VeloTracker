import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velotracker/main.dart';
import 'package:velotracker/services/auth_service.dart';
import 'package:velotracker/screens/welcom_screens/welcome_screen.dart';

// Клас SplashScreen (StatefulWidget)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Клас _SplashScreenState (State)
class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  PageRouteBuilder _createRoute(Widget targetScreen) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  Future<void> _checkAuth() async {
    final List<dynamic> results = await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _authService.getToken(),
    ]);

    final String? token = results[1];

    if(!mounted) return;

    if (token != null){
      // ВИКОРИСТАННЯ ПЛАВНОГО ПЕРЕХОДУ
      Navigator.of(context).pushReplacement(
        _createRoute(const MainScreen()),
      );
    }else{
      // ВИКОРИСТАННЯ ПЛАВНОГО ПЕРЕХОДУ
      Navigator.of(context).pushReplacement(
        _createRoute(const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/logo_splash_screen.svg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            Text(
              'VeloTracker',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}