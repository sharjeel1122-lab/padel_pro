import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:padel_pro/model/users%20model/user_model.dart';

class FetchAllUsersApi {
  // static const String baseUrl = "http://192.168.1.2:3000";
  static const String baseUrl = "https://padel-backend-git-main-invosegs-projects.vercel.app";

  // Secure storage instance
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Read token from secure storage
  static Future<String?> _getToken() => _storage.read(key: 'token');

  Future<List<UserModel>> fetchUsers() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Auth token missing. Ensure you saved it: await _storage.write(key: "token", value: yourJwt)');
    }

    final url = Uri.parse("$baseUrl/api/v1/admin-booking-management/all-users");
    final res = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch users: ${res.statusCode} ${res.body}");
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data == null) return <UserModel>[];

    final list = (data is Map && data['data'] is List)
        ? (data['data'] as List)
        : (data is List ? data : const []);

    return list
        .map((e) => UserModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
