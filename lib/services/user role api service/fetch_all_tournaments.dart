// services/vendors api/get_vendor_tournaments_api.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class GetAllTournamentsApi {

  final _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app/api/v1/booking/book/';
  // final _baseUrl = 'http://10.248.0.164:3000';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'token');

  Future<List<dynamic>> getAllTournaments() async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception("❌ Token missing. Please log in again.");
      }

      final url = Uri.parse('$_baseUrl/api/v1/tournament');
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
