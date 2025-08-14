import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CreateVendorApi {
  // final _baseUrl = 'http://192.168.1.6:3000';
  static const String _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';

  // // final _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';
  // static const String _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';
  final _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> createPlayground(Map<String, dynamic> club, List<String> photoPaths) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Unauthorized: Token not found");

      final url = Uri.parse('$_baseUrl/api/v1/playground/createPlaygorund');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      final jsonFields = ['facilities', 'courts'];

      club.forEach((key, value) {
        if (jsonFields.contains(key)) {
          try {
            request.fields[key] = jsonEncode(value);
          } catch (_) {
            throw Exception('Invalid JSON format in field: $key');
          }
        } else {
          request.fields[key] = value.toString();
        }
      });

      for (String path in photoPaths) {
        final ext = path.split('.').last.toLowerCase();
        MediaType? contentType;

        if (ext == 'jpg' || ext == 'jpeg') {
          contentType = MediaType('image', 'jpeg');
        } else if (ext == 'png') {
          contentType = MediaType('image', 'png');
        } else {
          print(" Unsupported image type: $path");
          continue;
        }

        final file = await http.MultipartFile.fromPath(
          'photos',
          path,
          contentType: contentType,
        );
        request.files.add(file);
      }

      if (request.files.isEmpty) {
        throw Exception("At least one valid image is required.");
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(body);
        print(' Playground Created: $data');
        // Get.snackbar("Success", "Playground created!",
        //     snackPosition: SnackPosition.BOTTOM,
        //     backgroundColor: Colors.green,
        //     colorText: Colors.white);
      } else {
        print('❌ Failed [${response.statusCode}]: $body');
        throw Exception('Error: ${response.statusCode}\n$body');
      }
    } catch (e) {
      print('❌ Exception: $e');
      // Get.snackbar('Error', e.toString(),
      //     backgroundColor: Colors.red, colorText: Colors.white);
      rethrow;
    }
  }
}
