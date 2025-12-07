import 'package:flutter/material.dart';
import 'package:velotracker/services/auth_service.dart';
import 'package:velotracker/services/preferences_service.dart';
import 'package:velotracker/utils/app_logger.dart';

class SettingsController extends ChangeNotifier {
  // 1. Робимо Singleton, щоб мати доступ до одного й того ж екземпляра всюди
  static final SettingsController _instance = SettingsController._internal();
  factory SettingsController() => _instance;
  SettingsController._internal();

  final AuthService _authService = AuthService();
  final PreferencesService _prefsService = PreferencesService();

  bool isKmSelected = true;
  bool isDarkMode = false;
  String userEmail = 'Loading...';
  bool isLoading = true;

  // --- ХЕЛПЕРИ ДЛЯ КОНВЕРТАЦІЇ ---
  
  // Отримати назву одиниці виміру
  String get distanceUnit => isKmSelected ? 'km' : 'mi';
  String get speedUnit => isKmSelected ? 'km/h' : 'mph';

  // Конвертувати дистанцію (вхід завжди в км)
  double convertDistance(double km) {
    if (isKmSelected) return km;
    return km * 0.621371;
  }

  // Конвертувати швидкість (вхід завжди в км/год)
  double convertSpeed(double kmh) {
    if (isKmSelected) return kmh;
    return kmh * 0.621371;
  }

  // Завантаження налаштувань
  Future<void> loadSettings() async {
    // (Логіка завантаження залишається такою ж, як була)
    if (!isLoading) isLoading = true; // Тільки якщо треба оновити UI
    
    try {
      final isKm = await _prefsService.getUnitSystem();
      final isDark = await _prefsService.getDarkMode();
      final userProfile = await _authService.getUserProfile();

      isKmSelected = isKm;
      isDarkMode = isDark;

      if (userProfile != null && userProfile['email'] != null) {
        userEmail = userProfile['email'];
      } else {
        userEmail = 'No Email';
      }
    } catch (e, stack) {
      logger.e('Error loading settings', error: e, stackTrace: stack);
      userEmail = 'Connection Error';
    } finally {
      isLoading = false;
      notifyListeners(); // Це оновить всі екрани
    }
  }

  Future<void> toggleUnit(bool isKm) async {
    if (isKmSelected == isKm) return;

    isKmSelected = isKm;
    notifyListeners(); // Всі екрани моментально змінять цифри

    await _prefsService.setUnitSystem(isKm);
    logger.i('Unit system saved: ${isKm ? "km" : "miles"}');
  }

  Future<void> toggleTheme(bool isDark) async {
    if (isDarkMode == isDark) return;

    isDarkMode = isDark;
    notifyListeners();

    await _prefsService.setDarkMode(isDark);
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}