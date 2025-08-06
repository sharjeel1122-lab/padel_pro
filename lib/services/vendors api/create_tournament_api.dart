import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TournamentService {
  final String _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';
  final _storage = const FlutterSecureStorage();


  Future<String?> _getToken() async => await _storage.read(key: 'token');


  Future<Map<String, dynamic>> createTournament({
    required String name,
    required String description,
    File? photo,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('❌ Missing token. Please log in again.');
      }

      final uri = Uri.parse('$_baseUrl/api/v1/tournament/');
      print('📤 POST: $uri');

      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name'] = name
        ..fields['description'] = description;

      if (photo != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
        print('📷 Attached image: ${photo.path}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      print('✅ Create Tournament Response: ${response.statusCode} -> $data');

      return {
        'statusCode': response.statusCode,
        'body': data,
      };
    } catch (e) {
      print('🚨 createTournament Error: $e');
      return {
        'statusCode': 500,
        'body': {'success': false, 'error': e.toString()},
      };
    }
  }
}
