import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeleteUserApi {
  static const String baseUrl = "https://padel-backend-git-main-invosegs-projects.vercel.app";
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static Future<String?> _getToken() => _storage.read(key: 'token');

  /// Deletes a user by ID. Backend expects param name: userId
  /// DELETE /api/v1/admin-booking-management/user/:userId
  Future<bool> deleteUserById(String userId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Auth token missing.');
    }

    final uri = Uri.parse("$baseUrl/api/v1/admin-booking-management/delete/$userId");
    final res = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) return true;

    // try to surface backend message
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = body['message']?.toString() ?? 'Delete failed (${res.statusCode})';
      throw Exception(msg);
    } catch (_) {
      throw Exception('Delete failed (${res.statusCode})');
    }
  }
}

