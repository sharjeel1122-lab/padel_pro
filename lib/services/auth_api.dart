import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  static const String baseUrl = "http://192.168.100.191:3000/api";

  static Future<http.Response> signup({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String city,
    String role = 'user',
  }) {
    final names = fullName.trim().split(' ');
    final firstName = names.first;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    return http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "email": email.trim().toLowerCase(),
        "phone": phone,
        "city": city,
        "password": password,
        // "role": role,
      }),
    );
  }

  static Future<http.Response> login(String email, String password) {
    return http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim().toLowerCase(),
        "password": password,
      }),
    );
  }
}
