import 'package:flutter/material.dart';
import 'package:velotracker/services/auth_service.dart';
import 'package:velotracker/services/preferences_service.dart';
import 'package:velotracker/utils/app_logger.dart';

class SettingsController extends ChangeNotifier {
  static final SettingsController _instance = SettingsController._internal();
  factory SettingsController() => _instance;
  SettingsController._internal();

  bool get isGuest => userEmail == 'Guest';

  final AuthService _authService = AuthService();
  final PreferencesService _prefsService = PreferencesService();

  bool isKmSelected = true;
  bool isDarkMode = false;
  String userEmail = 'Loading...';
  bool isLoading = true;

  // Отримати назву одиниці виміру
  String get distanceUnit => isKmSelected ? 'km' : 'mi';
  String get speedUnit => isKmSelected ? 'km/h' : 'mph';

  // Конвертувати дистанцію 
  double convertDistance(double km) {
    if (isKmSelected) return km;
    return km * 0.621371;
  }

  // Конвертувати швидкість 
  double convertSpeed(double kmh) {
    if (isKmSelected) return kmh;
    return kmh * 0.621371;
  }

  // Завантаження налаштувань
  Future<void> loadSettings() async {
    if (!isLoading) isLoading = true; 
    
    try {
      final isKm = await _prefsService.getUnitSystem();
      final userProfile = await _authService.getUserProfile();

      isKmSelected = isKm;
   

     if (userProfile != null && userProfile['email'] != null) {
        final String rawEmail = userProfile['email'];
  
        if (rawEmail.endsWith('@velotracker.anon')) {
          userEmail = 'Guest';
        } else {
          userEmail = rawEmail;
        }
      } else {
        userEmail = 'No Email';
      }
    } catch (e, stack) {
      logger.e('Error loading settings', error: e, stackTrace: stack);
      userEmail = 'Connection Error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleUnit(bool isKm) async {
    if (isKmSelected == isKm) return;

    isKmSelected = isKm;
    notifyListeners(); 
    await _prefsService.setUnitSystem(isKm);
    logger.i('Unit system saved: ${isKm ? "km" : "miles"}');
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}