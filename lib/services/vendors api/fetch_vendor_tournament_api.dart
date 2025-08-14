// services/vendors api/get_vendor_tournaments_api.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class GetVendorTournamentsApi {
  // final _baseUrl = 'http://192.168.1.8:3000';
  static const String _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';

  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'token');

  Future<List<dynamic>> getVendorTournaments() async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception("❌ Token missing. Please log in again.");
      }

      final url = Uri.parse('$_baseUrl/api/v1/tournament/vendor-tournamnets');
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
        print('Tournaments fetched: ${decoded['data'].length}');
        return decoded['data']; // Make sure this matches your backend structure
      } else {
        throw Exception(
          '❌ Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}',
        );
      }
    } catch (e) {
      print('🚨 getVendorTournaments error: $e');
      rethrow;
    }
  }
}
