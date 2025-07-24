import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  static const String _baseUrl = 'http://192.168.1.4:3000';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    print('🚀 Attempting login with email: $email');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),   // ✅ Ensure 'email' matches backend expectations
          'password': password.trim(),
        }),
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
        final role = data['user']['role'] ?? 'user'; // fallback if role is missing

        return {
          'token': token,
          'user': {'role': role},
        };


        // final responseData = jsonDecode(response.body);
        //
        // // ✅ Check if token exists and is a String
        // final token = responseData['token'];
        // if (token == null || token is! String) {
        //   throw Exception('Token missing or invalid in response');
        // }
        //
        // // ✅ Get role (or fetch from backend if needed)
        // final role = await _determineUserRole(token);
        //
        // return {
        //   'token': token,
        //   'user': {'role': role},
        // };
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



  //Sign up Vendor
  static Future<Map<String, dynamic>> signupVendor({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String mpin,
    required String city,
    required String phone,
    required String cnic,
    required String ntn,
    String? photo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/vendors'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'mpin': mpin,
          'city': city,
          'phone': phone,
          'cnic': cnic,
          'ntn': ntn,
          'photo': photo,
          'role' : 'vendor',
          'status': 'pending',
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register vendor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Vendor registration failed: $e');
    }
  }



}