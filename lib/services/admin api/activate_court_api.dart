import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ActivateCourtApi {
  static const String baseUrl = "https://padel-backend-git-main-invosegs-projects.vercel.app";
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static Future<String?> _getToken() => _storage.read(key: 'token');

  Future<Map<String, dynamic>> activateCourt(String playgroundId, String courtNumber) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Auth token missing. Save it first with FlutterSecureStorage.');
    }

    final uri = Uri.parse("$baseUrl/api/v1/playground/$playgroundId/courts/$courtNumber/activate");
    final res = await http.patch(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      final errorBody = jsonDecode(res.body);
      throw Exception(errorBody['message'] ?? "Failed to activate court: ${res.statusCode}");
    }

    final Map<String, dynamic> body = jsonDecode(res.body);
    return body;
  }
}
