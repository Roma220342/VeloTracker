import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyIsKm = 'is_km';
  static const String _keyIsDarkMode = 'is_dark_mode';

  // --- Units (Km/Miles) ---
  Future<void> setUnitSystem(bool isKm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsKm, isKm);
  }

  Future<bool> getUnitSystem() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsKm) ?? true; // Default: Km
  }

  // --- Theme (Dark/Light) ---
  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkMode, isDark);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDarkMode) ?? false; // Default: Light
  }
}