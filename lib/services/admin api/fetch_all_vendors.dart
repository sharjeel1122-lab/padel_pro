import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:padel_pro/model/vendors%20model/vendors_model.dart';

class FetchAllVendorsApi {
  // static const String baseUrl = "http://192.168.1.2:3000";
  static const String baseUrl = "https://padel-backend-git-main-invosegs-projects.vercel.app";

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static Future<String?> _getToken() => _storage.read(key: 'token');

  Future<List<VendorsModel>> fetchVendors() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Auth token missing. Save it first with FlutterSecureStorage.');
    }

    final uri = Uri.parse("$baseUrl/api/v1/admin-booking-management/all-vendors");
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch vendors: ${res.statusCode} ${res.body}");
    }

    final Map<String, dynamic> body = jsonDecode(res.body);
    final data = body['data'];
    if (data == null) return <VendorsModel>[];

    final list = (data is Map && data['data'] is List)
        ? (data['data'] as List)
        : (data is List ? data : const []);

    return list
        .map((e) => VendorsModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
