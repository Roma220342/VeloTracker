import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:velotracker/models/ride_model.dart';
import 'package:velotracker/services/auth_service.dart';
import 'package:velotracker/utils/app_logger.dart';

class RideService {
  // static const String _baseUrl = 'https://aida-aglitter-speedfully.ngrok-free.dev/api/rides';
  static const String _baseUrl = 'https://velotracker-api.onrender.com/api/rides';
  final AuthService _authService = AuthService();

  // Створення поїздки
  Future<bool> saveRide({
    required String title,
    String? notes,
    required double distance,
    required String duration,
    required double avgSpeed,
    required double maxSpeed,
    required List<Map<String, double>> routePoints,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      logger.e('SaveRide failed: token is null');
      return false;
    }

    try {
      logger.i('Saving new ride to $_baseUrl');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'notes': notes ?? '',
          'distance': distance,
          'duration': duration,
          'avg_speed': avgSpeed,
          'max_speed': maxSpeed,
          'route_data': routePoints,
          'start_time': DateTime.now().toIso8601String(),
        }),
      );

      logger.d('SaveRide response: ${response.statusCode}');

      return response.statusCode == 201;
    } catch (e, stack) {
      logger.e('SaveRide exception', error: e, stackTrace: stack);
      return false;
    }
  }

  // Отримання всіх поїздок користувача
  Future<List<RideModel>> getUserRides() async {
    final token = await _authService.getToken();
    if (token == null) {
      logger.e('GetUserRides failed: token is null');
      return [];
    }

    try {
      logger.i('GET $_baseUrl');

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      logger.d('Status: ${response.statusCode}');
      logger.d('Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        logger.i('Fetched ${data.length} rides');

        return data.map((json) {
          try {
            return RideModel.fromJson(json);
          } catch (e, stack) {
            logger.e(
              'Ride parsing error',
              error: e,
              stackTrace: stack,
            );
            rethrow;
          }
        }).toList();
      } else {
        logger.w('Server returned ${response.statusCode}');
        return [];
      }
    } catch (e, stack) {
      logger.e('GetUserRides exception', error: e, stackTrace: stack);
      return [];
    }
  }

  // Оновлення поїздки
  Future<bool> updateRide(String rideId, String newTitle, String newNotes) async {
    final token = await _authService.getToken();
    if (token == null) {
      logger.e('UpdateRide failed: token null');
      return false;
    }

    try {
      logger.i('Updating ride $rideId');

      final response = await http.put(
        Uri.parse('$_baseUrl/$rideId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': newTitle,
          'notes': newNotes,
        }),
      );

      logger.d('UpdateRide status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e, stack) {
      logger.e('UpdateRide exception', error: e, stackTrace: stack);
      return false;
    }
  }

  // Видалення поїздки
  Future<bool> deleteRide(String rideId) async {
    final token = await _authService.getToken();
    if (token == null) {
      logger.e('DeleteRide failed: token null');
      return false;
    }

    try {
      logger.i('Deleting ride $rideId');

      final response = await http.delete(
        Uri.parse('$_baseUrl/$rideId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      logger.d('DeleteRide status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e, stack) {
      logger.e('DeleteRide exception', error: e, stackTrace: stack);
      return false;
    }
  }
}
