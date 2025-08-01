import 'dart:convert';

import 'package:http/http.dart' as http;

class UserLoginApi {
  static const String _baseUrl = 'http://10.248.0.109:3000';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    print(' Attempting login with email: $email');

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
        final user = data['user'];
        final role = user['role'] ?? 'user';
        final id = user['id'];

        return {
          'token': token,
          'user': {
            'role': role,
            'id': id,
          },
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
