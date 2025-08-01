import 'dart:convert';

import 'package:http/http.dart' as http;

class UserSignUpApi {
  static const String _baseUrl = 'http://10.248.2.72:3000';
  Future<Map<String, dynamic>> signupUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String mpin,
    required String city,
    required String phone, String? photoPath,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'mpin': mpin,
          'city': city,
          'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }
}
