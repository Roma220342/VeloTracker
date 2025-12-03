import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api/users';
  static const String _tokenKey = 'jwt_token';

  static const String _webClientId = '282808432308-sb0es97v49phernjl7uti1cee0rjqa2f.apps.googleusercontent.com';

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // 1. Звичайна реєстрація (Email + Password)
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('$_baseUrl/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        if (response.data['token'] != null) {
          await _storage.write(key: _tokenKey, value: response.data['token']);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Register Error: $e');
      return false;
    }
  }

  // 2. Звичайний вхід (Email + Password)
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('$_baseUrl/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: _tokenKey, value: token);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  // 3. Google авторизація
  Future<bool> continueWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: _webClientId,
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        debugPrint('Google Sign In cancelled by user');
        return false;
      }

      // Отримуємо токени
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint('ПОМИЛКА: Google ID Token is null.');
        debugPrint('Перевір Web Client ID в AuthService.');
        return false;
      }

      debugPrint('Google ID Token отримано.');

      // Відправляємо на бекенд
      return await _sendGoogleTokenToBackend(idToken);

    } catch (e) {
      debugPrint('Google Sign In Exception: $e');
      return false;
    }
  }

  Future<bool> _sendGoogleTokenToBackend(String googleIdToken) async {
    try {
      final response = await _dio.post('$_baseUrl/google', data: {
        'token': googleIdToken,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        await _storage.write(key: _tokenKey, value: token);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Backend Google Auth Error: $e');
      return false;
    }
  }

  // Вихід з акаунту
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _googleSignIn.signOut();
  }
  
  // Отримання збереженого токена
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Скидання пароля 
  Future<bool> sendPasswordResetCode(String email) async {
    try {
      final response = await _dio.post('$_baseUrl/forgot-password', data: {'email': email});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Перевірка коду скидання
  Future<bool> verifyResetCode(String email, String code) async {
    try {
      final response = await _dio.post('$_baseUrl/verify-code', data: {'email': email, 'code': code});
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Скидання пароля з новим паролем
  Future<bool> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await _dio.post('$_baseUrl/reset-password', data: {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}