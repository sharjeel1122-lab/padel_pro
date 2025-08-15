import 'dart:convert';

import 'package:http/http.dart' as http;

class UserMPINLoginApi {
  // static const String baseUrl = 'http://192.168.1.6:3000';
  static const String baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';


  static Future<Map<String, dynamic>> loginWithMPIN(String mpin) async {
    final url = Uri.parse('$baseUrl/api/mpin');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mpin': mpin}),
      );

      final responseData = jsonDecode(response.body);


      print("RESPONSE RESPONSE ❤❤❤❤❤ : ${response.body}");

      if (response.statusCode == 200) {
        final data = responseData['data'] ?? {};

        if (data['token'] == null || data['user'] == null) {
          throw Exception('Token or user missing in response');
        }

        return {
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        throw Exception(responseData['message'] ?? 'MPIN login failed');
      }
    } catch (e) {
      print('❌ MPIN login error: $e');
      rethrow;
    }
  }
}
