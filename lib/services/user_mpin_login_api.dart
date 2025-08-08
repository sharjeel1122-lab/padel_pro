import 'dart:convert';
import 'package:http/http.dart' as http;

class UserMPINLoginApi {
  static const String baseUrl = 'http://10.248.2.67:3000';
  static Future<Map<String, dynamic>> loginWithMPIN(String mpin) async {
    final url = Uri.parse('$baseUrl/api/mpin');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mpin': mpin}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];

        if (data == null || data['token'] == null || data['user'] == null) {
          throw Exception('Token or user missing in response');
        }

        return {
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'MPIN login failed');
      }
    } catch (e) {
      print('❌ MPIN login error: $e');
      rethrow;
    }
  }
}
