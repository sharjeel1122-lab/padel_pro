import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ProfileApi {
  final String baseUrl = 'http://192.168.1.6:3000';
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Profile Data: ${data['data']}");
        return data['data'];
      } else {
        print("Failed to fetch profile: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }
}
