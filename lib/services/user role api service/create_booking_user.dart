import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BookingApi {
  final _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app/api/v1/booking/book/';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'token');

  Future<Map<String, dynamic>> createBooking({
    required String playgroundId,
    required String courtNumber,
    required String date, // Format: YYYY-MM-DD
    required String startTime, // Format: HH:mm
    required int duration,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse('$_baseUrl/api/v1/booking/create');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'playgroundId': playgroundId,
        'courtNumber': courtNumber,
        'date': date,
        'startTime': startTime,
        'duration': duration,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'success': true, 'data': data['data']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Booking failed'};
    }
  }
}
