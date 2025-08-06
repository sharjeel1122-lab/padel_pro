import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';


class CreateVendorApi {
  final _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();


  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> createPlayground(
      Map<String, dynamic> club, List<String> photoPaths) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Unauthorized: Token not found");

      _dio.options.headers['Authorization'] = 'Bearer $token';

      FormData formData = FormData();

      final jsonFields = ['facilities', 'courts'];

      club.forEach((key, value) {
        if (jsonFields.contains(key)) {
          formData.fields.add(MapEntry(key, jsonEncode(value)));
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      for (String path in photoPaths) {
        final file = File(path);
        if (!file.existsSync()) {
          print('File does not exist: $path');
          continue;
        }

        final fileName = path.split('/').last;
        final mimeType = _getMimeType(fileName);

        if (mimeType == null) {
          print("Unsupported image type: $path");
          continue;
        }

        formData.files.add(MapEntry(
          'photos',
          await MultipartFile.fromFile(path, filename: fileName, contentType: mimeType),
        ));
      }

      if (formData.files.isEmpty) {
        throw Exception("At least one valid image is required.");
      }

      final response = await _dio.post(
        '$_baseUrl/api/v1/playground/createPlaygorund',
        data: formData,
      );

      if (response.statusCode == 201) {
        print('✅ Playground Created: ${response.data}');

      } else {
        print('❌ Error: ${response.statusCode} - ${response.data}');
        throw Exception('Failed to create playground');
      }
    } catch (e) {
      print('❌ Exception: $e');

    }
  }


  MediaType? _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      default:
        return null;
    }
  }
}
