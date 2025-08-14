import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class UserSignUpApi {
  // final String _baseUrl = 'http://192.168.1.6:3000';
  final String _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';

  Future<Map<String, dynamic>> signupUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String mpin,
    required String city,
    required String town,     // REQUIRED for backend
    required String phone,
    String role = 'user',      // default (backend disallows "vendor" here)
    String? photoPath,         // uploaded as multipart "photo"
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/signup');
      final request = http.MultipartRequest('POST', uri);

      // Text fields
      request.fields.addAll({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'mpin': mpin,
        'city': city,
        'town': town,
        'phone': phone,
        'role': role,
      });

      // Required by backend (req.file), UI enforces selection
      if (photoPath != null && photoPath.isNotEmpty && File(photoPath).existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }
}
