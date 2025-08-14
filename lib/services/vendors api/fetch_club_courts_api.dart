import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class FetchVendorApi {
  // final _baseUrl = 'http://192.168.1.6:3000';
  final String _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';

  final _storage = const FlutterSecureStorage();


  Future<String?> _getToken() async => await _storage.read(key: 'token');


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
    final token = await _storage.read(key: 'token'); //
    final uri = Uri.parse('$_baseUrl/api/v1/playground/delete/$id');

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


  //Update Playground
  Future<Map<String, dynamic>> updatePlaygroundById(
      String id,
      Map<String, dynamic> payload,
      ) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Missing token');

    final uri = Uri.parse('$_baseUrl/api/v1/playground/update/$id');
    print(uri);
    try {
      final res = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        dynamic errorBody;
        try { errorBody = jsonDecode(res.body); } catch (_) { errorBody = res.body; }
        final msg = (errorBody is Map && errorBody['message'] != null)
            ? errorBody['message']
            : 'HTTP ${res.statusCode}: ${res.reasonPhrase ?? 'Unknown error'}';
        throw Exception('Update failed: $msg');
      }
    } catch (e) {
      rethrow;
    }
  }


  //Update Courts

  Future<Map<String, dynamic>> updateCourtById(
      String id,
      Map<String, dynamic> payload,
      ) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Missing token');

    final uri = Uri.parse('$_baseUrl/api/v1/playground/updateCourts/$id');
    print(uri);
    try {
      final res = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        dynamic errorBody;
        try { errorBody = jsonDecode(res.body); } catch (_) { errorBody = res.body; }
        final msg = (errorBody is Map && errorBody['message'] != null)
            ? errorBody['message']
            : 'HTTP ${res.statusCode}: ${res.reasonPhrase ?? 'Unknown error'}';
        throw Exception('Update failed: $msg');
      }
    } catch (e) {
      rethrow;
    }
  }





}


