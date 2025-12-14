import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyIsKm = 'is_km';

  Future<void> setUnitSystem(bool isKm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsKm, isKm);
  }

  Future<bool> getUnitSystem() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsKm) ?? true; // Default: Km
  }


}