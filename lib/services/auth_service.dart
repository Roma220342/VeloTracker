import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:velotracker/utils/app_logger.dart';

class AuthService {
  // static const String _baseUrl = 'https://aida-aglitter-speedfully.ngrok-free.dev/api/users';
  static const String _baseUrl = 'https://velotrackerserver.onrender.com/api/users';
  static const String _tokenKey = 'jwt_token';

  static const String _webClientId =
      '282808432308-sb0es97v49phernjl7uti1cee0rjqa2f.apps.googleusercontent.com';

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  
  // 1. EMAIL + PASSWORD REGISTER
  Future<bool> register(String name, String email, String password) async {
    logger.i('Registering user: $email');

    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      logger.d('Register status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final token = response.data['token'];
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
          logger.i('Registration success. Token saved.');
        }
        return true;
      }

      logger.w('Register failed. Status: ${response.statusCode}');
      return false;
    } catch (e, stack) {
      logger.e('Register exception', error: e, stackTrace: stack);
      return false;
    }
  }

  
  // 2. Email + Password LOGIN
  Future<bool> login(String email, String password) async {
    logger.i('Login attempt: $email');

    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {'email': email, 'password': password},
      );

      logger.d('Login status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: _tokenKey, value: token);
        logger.i('Login success. Token saved.');
        return true;
      }

      logger.w('Login failed. Status: ${response.statusCode}');
      return false;
    } catch (e, stack) {
      logger.e('Login exception', error: e, stackTrace: stack);
      return false;
    }
  }

  
  // 3. GOOGLE AUTH
  Future<bool> continueWithGoogle() async {
    logger.i('Google Sign-In started');

    try {
      await _googleSignIn.initialize(serverClientId: _webClientId);

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();

      if (googleUser == null) {
        logger.w('Google Sign-In cancelled by user');
        return false;
      }

      logger.i('Google Sign-In success: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        logger.e('Google ID Token is null — check Web Client ID');
        return false;
      }

      logger.d('Google ID Token retrieved. Sending to backend…');

      return await _sendGoogleTokenToBackend(idToken);
    } catch (e, stack) {
      logger.e('Google Sign-In exception', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> _sendGoogleTokenToBackend(String googleIdToken) async {
    logger.i('Sending Google token to backend…');

    try {
      final response = await _dio.post(
        '$_baseUrl/google',
        data: {'token': googleIdToken},
      );

      logger.d('Backend Google Auth status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        await _storage.write(key: _tokenKey, value: token);
        logger.i('Google auth success. Token saved.');
        return true;
      }

      logger.w('Google backend auth failed. Status: ${response.statusCode}');
      return false;
    } catch (e, stack) {
      logger.e('Google backend auth exception', error: e, stackTrace: stack);
      return false;
    }
  }

  
  // LOGOUT
  Future<void> logout() async {
    logger.i('Logging out…');

    await _storage.delete(key: _tokenKey);
    await _googleSignIn.signOut();

    logger.i('Logout complete. Token removed.');
  }

  
  // GET TOKEN FROM SECURE STORAGE
  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    logger.d('Token read: ${token != null ? "exists" : "null"}');
    return token;
  }

  
  // PASSWORD RESET FLOW
  Future<bool> sendPasswordResetCode(String email) async {
    logger.i('Sending password reset code to $email');

    try {
      final res = await _dio.post(
        '$_baseUrl/forgot-password',
        data: {'email': email},
      );

      logger.d('Reset code status: ${res.statusCode}');
      return res.statusCode == 200;
    } catch (e, stack) {
      logger.e('Send reset code exception', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> verifyResetCode(String email, String code) async {
    logger.i('Verifying reset code for $email');

    try {
      final res = await _dio.post(
        '$_baseUrl/verify-code',
        data: {'email': email, 'code': code},
      );

      logger.d('Verify code status: ${res.statusCode}');
      return res.statusCode == 200 && res.data['success'] == true;
    } catch (e, stack) {
      logger.e('Verify reset code exception', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> resetPassword(
      String email, String code, String newPassword) async {
    logger.i('Resetting password for $email');

    try {
      final res = await _dio.post(
        '$_baseUrl/reset-password',
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
      );

      logger.d('Reset password status: ${res.statusCode}');
      return res.statusCode == 200;
    } catch (e, stack) {
      logger.e('Reset password exception', error: e, stackTrace: stack);
      return false;
    }
  }
  
  // GET USER PROFILE
  Future<Map<String, dynamic>?> getUserProfile() async {
    logger.i('Fetching user profile…');

    try {
      final token = await getToken();
      if (token == null) {
        logger.w('Profile fetch failed — token is null');
        return null;
      }

      final response = await _dio.get(
        '$_baseUrl/profile',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      logger.d('Profile status: ${response.statusCode}');

      if (response.statusCode == 200) {
        logger.i('Profile fetched successfully');
        return response.data;
      }

      logger.w('Failed to fetch profile. Status: ${response.statusCode}');
      return null;
    } catch (e, stack) {
      logger.e('Profile fetch exception', error: e, stackTrace: stack);
      return null;
    }
  }

  Future<bool> loginAnonymously() async {
    logger.i('Attempting anonymous login...');

    try {
      final response = await _dio.post('$_baseUrl/anonymous');

      logger.d('Guest login status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
          logger.i('Guest login success. Token saved.');
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      logger.e('Guest login exception', error: e, stackTrace: stack);
      return false;
    }
  }

  // CONVERT GUEST TO USER
  Future<String?> convertGuest(String name, String email, String password) async {
    final token = await getToken();
    if (token == null) return "No guest session found";

    try {
      final response = await _dio.put(
        '$_baseUrl/convert-guest',
        data: {'name': name, 'email': email, 'password': password},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        await _storage.write(key: _tokenKey, value: newToken);
        logger.i('Guest converted to User successfully');
        return null; 
      }
      return 'Server error: ${response.statusCode}';
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return e.response!.data['message'] ?? 'Registration failed';
      }
      return 'Connection error';
    }
  }

  // LINK GOOGLE до гостевого акаунту
  Future<String?> linkGoogle() async {
    final token = await getToken(); // Токен гостя
    if (token == null) return "No guest session";

    logger.i('Linking Google account started');

    try {
      await _googleSignIn.initialize(serverClientId: _webClientId);

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        logger.w('Google linking cancelled by user');
        return null; 
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        logger.e('Google ID Token is null');
        return "Google auth failed";
      }

      final response = await _dio.put(
        '$_baseUrl/link-google',
        data: {'token': idToken},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        await _storage.write(key: _tokenKey, value: newToken);
        logger.i('Guest linked to Google successfully');
        return null; 
      }
      
      return 'Server error: ${response.statusCode}';

    } on DioException catch (e) {
      logger.e('Link Google Dio exception', error: e);
      if (e.response != null && e.response!.data != null) {

        return e.response!.data['message'] ?? 'Linking failed';
      }
      return 'Connection error';
    } catch (e, stack) {
      logger.e('Link Google unknown exception', error: e, stackTrace: stack);
      return 'Unknown error: $e';
    }
  }
}
