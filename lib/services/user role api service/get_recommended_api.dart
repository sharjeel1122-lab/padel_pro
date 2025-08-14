// lib/api/get_recommended_club.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:padel_pro/model/ground_model.dart';

class GetRecommendedClub {
  final String baseUrl =
      "https://padel-backend-git-main-invosegs-projects.vercel.app";

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<String?> _getToken() async => await _storage.read(key: 'token');

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Ground>> fetchRecommended() async {
    try {
      final uri = Uri.parse("$baseUrl/api/v1/playground/getRecommended/");
      print("📡 Fetching from: $uri");

      final response = await http.get(uri, headers: await _headers());

      print("🔍 Status code: ${response.statusCode}");
      if (response.body.isNotEmpty) print("📦 Raw body: ${response.body}");

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("Unauthorized: Missing/invalid token");
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        // Your controller returned: { success, message, data: { count, data: [...] } }
        final outerData = jsonData['data'] as Map<String, dynamic>? ?? {};
        final List<dynamic> list = (outerData['data'] as List?) ?? [];

        print("✅ Total items from API: ${list.length}");

        final allGrounds = list
            .map((e) => Ground.fromJson(e as Map<String, dynamic>, baseUrl: baseUrl))
            .toList();

        // safety: only recommended
        final recommendedOnly = allGrounds.where((g) => g.recommended).toList();
        print("🎯 Recommended only: ${recommendedOnly.length}");

        return recommendedOnly;
      }

      // other errors -> extract message if present
      String msg = "Failed (HTTP ${response.statusCode})";
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) msg = body['message'];
        if (body is Map && body['error'] != null) msg = body['error'];
      } catch (_) {}
      throw Exception(msg);
    } catch (e) {
      print("❌ Error fetching recommended: $e");
      throw Exception(e.toString());
    }
  }
}
