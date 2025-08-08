import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CreateTournamentApi {
  final _baseUrl = 'http://10.248.2.67:3000';
  final _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> createTournament({
    required String name,
    required String registrationLink,
    required String tournamentType,
    required String location,
    required String startDate,
    required String startTime,
    required String description,
    File? photo,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Unauthorized: Token not found");

      final url = Uri.parse('$_baseUrl/api/v1/tournament/');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';


      request.fields['name'] = name;
      request.fields['registrationLink'] = registrationLink;
      request.fields['tournamentType'] = tournamentType;
      request.fields['location'] = location;
      request.fields['startDate'] = startDate;
      request.fields['startTime'] = startTime;
      request.fields['description'] = description;


      if (photo != null) {
        final ext = photo.path.split('.').last.toLowerCase();
        MediaType? contentType;

        if (ext == 'jpg' || ext == 'jpeg') {
          contentType = MediaType('image', 'jpeg');
        } else if (ext == 'png') {
          contentType = MediaType('image', 'png');
        }

        if (contentType != null) {
          final image = await http.MultipartFile.fromPath(
            'photo',
            photo.path,
            contentType: contentType,
          );
          request.files.add(image);
        } else {
          throw Exception('Unsupported image format: .$ext');
        }
      }


      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(body);
        print('Tournament Created: $data');
        Get.snackbar("Success", "Tournament created!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        print('❌ Failed [${response.statusCode}]: $body');
        throw Exception('Error: ${response.statusCode}\n$body');
      }
    } catch (e) {
      print('❌ Exception: $e');
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
      rethrow;
    }
  }
}
