import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class FetchVendorApi {
  final _baseUrl = 'http://192.168.1.6:3000';
  final _storage = const FlutterSecureStorage();

  // 🔐 Read token from secure storage
  Future<String?> _getToken() async => await _storage.read(key: 'token');

  /// ✅ Fetch only playgrounds created by the logged-in vendor
  Future<List<dynamic>> getVendorPlaygrounds() async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception("❌ Missing token. Please log in again.");
      }

      final url = Uri.parse('$_baseUrl/api/v1/playground/vendorsPlaygound');
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
        print('✅ Vendor playgrounds fetched: ${decoded['data']['count']}');
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


  //Delete Playground API

  Future<void> deletePlaygroundById(String id) async {
    final token = await _storage.read(key: 'token'); // ✅ get token
    final uri = Uri.parse('$_baseUrl/api/v1/playground/delete/$id'); // ✅ make sure this matches your actual endpoint

    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete playground');
    }
  }





}
