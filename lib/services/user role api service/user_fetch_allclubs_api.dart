import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserFetchAllClubsApi {
  final String baseUrl = 'http://192.168.0.101:3000';
  final _storage = const FlutterSecureStorage();

  // 🔐 Get token
  Future<String?> _getToken() async => await _storage.read(key: 'token');

  /// ✅ Fetch all clubs with courts (User role)





  Future<List<dynamic>> fetchAllPlaygrounds() async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception("❌ Missing token. Please log in again.");
      }

      final url = Uri.parse('$baseUrl/api/v1/playground/allPlaygorund');
      print('🔄 GET: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('✅ All playgrounds fetched: ${decoded['data']['count']}');
        return decoded['data']['data']; // returns a List of playgrounds
      } else {
        throw Exception(
          '❌ Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}',
        );
      }
    } catch (e) {
      print('🚨 getVendorPlaygrounds error: $e');
      rethrow;
    }
  }
}
