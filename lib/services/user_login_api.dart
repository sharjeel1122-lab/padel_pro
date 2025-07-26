import 'dart:convert';

import 'package:http/http.dart' as http;

class UserLoginApi {
  static const String _baseUrl = 'http://192.168.1.3:3000';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    print('🚀 Attempting login with email: $email');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password.trim()}),
      );

      print('📩 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];

        if (data == null || data['token'] == null || data['user'] == null) {
          throw Exception('Token missing or invalid in response');
        }

        final token = data['token'];
        final role =
            data['user']['role'] ?? 'user';

        return {
          'token': token,
          'user': {'role': role},
        };

      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  static Exception _handleError(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['message'] ?? 'Login failed';
      return Exception('$errorMessage (Status: ${response.statusCode})');
    } catch (e) {
      return Exception('Login failed with status: ${response.statusCode}');
    }
  }
}
