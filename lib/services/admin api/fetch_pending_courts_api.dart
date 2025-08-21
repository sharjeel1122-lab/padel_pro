import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PendingCourt {
  final String playgroundId;
  final String playgroundName;
  final String city;
  final String town;
  final Vendor vendor;
  final List<Court> courts;

  PendingCourt({
    required this.playgroundId,
    required this.playgroundName,
    required this.city,
    required this.town,
    required this.vendor,
    required this.courts,
  });

  factory PendingCourt.fromMap(Map<String, dynamic> map) {
    return PendingCourt(
      playgroundId: map['playgroundId']?.toString() ?? '',
      playgroundName: map['playgroundName']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      town: map['town']?.toString() ?? '',
      vendor: Vendor.fromMap(map['vendor'] ?? {}),
      courts: (map['courts'] as List<dynamic>?)
          ?.map((x) => Court.fromMap(x as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class Vendor {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  Vendor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      id: map['id']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
    );
  }
}

class Court {
  final String courtNumber;
  final String courtType;
  final Map<String, dynamic> pricing;
  final Map<String, dynamic> peakHours;
  final String status;
  final DateTime createdAt;

  Court({
    required this.courtNumber,
    required this.courtType,
    required this.pricing,
    required this.peakHours,
    required this.status,
    required this.createdAt,
  });

  factory Court.fromMap(Map<String, dynamic> map) {
    return Court(
      courtNumber: map['courtNumber']?.toString() ?? '',
      courtType: map['courtType']?.toString() ?? '',
      pricing: map['pricing'] is Map ? Map<String, dynamic>.from(map['pricing']) : {},
      peakHours: map['peakHours'] is Map ? Map<String, dynamic>.from(map['peakHours']) : {},
      status: map['status']?.toString() ?? '',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    try {
      if (dateTime is String) {
        return DateTime.parse(dateTime);
      } else if (dateTime is DateTime) {
        return dateTime;
      } else {
        return DateTime.now();
      }
    } catch (e) {
      return DateTime.now();
    }
  }
}

class FetchPendingCourtsApi {
  static const String baseUrl = "https://padel-backend-git-main-invosegs-projects.vercel.app";
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static Future<String?> _getToken() => _storage.read(key: 'token');

  Future<List<PendingCourt>> fetchPendingCourts() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Auth token missing. Save it first with FlutterSecureStorage.');
    }

    final uri = Uri.parse("$baseUrl/api/v1/playground/pendingCourts/");
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch pending courts: ${res.statusCode} ${res.body}");
    }

    try {
      final Map<String, dynamic> body = jsonDecode(res.body);
      print('API Response: $body'); // Debug print
      
      final data = body['data'];
      if (data == null) return <PendingCourt>[];

      List<dynamic> list;
      if (data is Map) {
        // If data is a map, check if it has a 'data' property
        list = data['data'] is List ? data['data'] as List : [];
      } else if (data is List) {
        // If data is directly a list
        list = data;
      } else {
        // If data is neither map nor list, return empty
        return <PendingCourt>[];
      }

      return list.map((e) {
        if (e is Map<String, dynamic>) {
          return PendingCourt.fromMap(e);
        } else {
          print('Invalid item format: $e');
          return null;
        }
      }).where((e) => e != null).cast<PendingCourt>().toList();
    } catch (e) {
      print('Error parsing response: $e');
      throw Exception('Failed to parse API response: $e');
    }
  }
}
