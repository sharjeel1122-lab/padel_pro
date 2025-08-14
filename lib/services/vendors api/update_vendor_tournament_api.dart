import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UpdateVendorTournamentApi {
  static const String baseUrl = "https://padel-backend-git-main-invosegs-projects.vercel.app";
  static const String updatePrefix = "/api/v1/tournament";

  static const _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> updateTournament({
    required String id,
    String? name,
    String? registrationLink,
    String? tournamentType,
    String? location,
    String? startDate,
    String? startTime,
    String? description,
    File? photoFile,
  }) async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      throw Exception("Missing auth token");
    }

    final uri = Uri.parse("$baseUrl$updatePrefix/$id");
    final req = http.MultipartRequest('PATCH', uri);
    req.headers['Authorization'] = 'Bearer $token';

    void addField(String key, String? v) {
      if (v != null && v.trim().isNotEmpty) {
        req.fields[key] = v.trim();
      }
    }

    addField('name', name);
    addField('registrationLink', registrationLink);
    addField('tournamentType', tournamentType);
    addField('location', location);
    addField('startDate', startDate);
    addField('startTime', startTime);
    addField('description', description);

    if (photoFile != null) {
      req.files.add(await http.MultipartFile.fromPath('photo', photoFile.path));
    }

    final res = await req.send();
    final body = await res.stream.bytesToString();

    Map<String, dynamic> map;
    try {
      map = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      map = {'raw': body};
    }

    if (res.statusCode != 200) {
      throw Exception(map['message'] ?? 'Update failed (${res.statusCode})');
    }
    // Backend returns successResponse(res, { ...tournament fields... }, ...)
    return map['data'] is Map<String, dynamic> ? map['data'] : map;
  }
}
