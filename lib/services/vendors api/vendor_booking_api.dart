import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class BookingItem {
  final String id;
  final String playgroundName;
  final String playgroundLocation;
  final String userFullName;
  final String userPhone;
  final num? userAvgRating;
  final String? userSkillLevel;

  final String date;       // YYYY-MM-DD
  final String startTime;  // HH:mm
  final String courtNumber;
  final int duration;      // minutes
  final num? totalPrice;

  final DateTime createdAt;
  final DateTime? ratingCreatedAt;
  final num? ratingValue;

  BookingItem({
    required this.id,
    required this.playgroundName,
    required this.playgroundLocation,
    required this.userFullName,
    required this.userPhone,
    required this.userAvgRating,
    required this.userSkillLevel,
    required this.date,
    required this.startTime,
    required this.courtNumber,
    required this.duration,
    required this.totalPrice,
    required this.createdAt,
    this.ratingCreatedAt,
    this.ratingValue,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    final playground = json['playgroundId'] ?? {};
    final user = json['userId'] ?? {};

    String fullName = [
      user['firstName']?.toString() ?? '',
      user['lastName']?.toString() ?? ''
    ].where((e) => e.trim().isNotEmpty).join(' ');
    if (fullName.trim().isEmpty) fullName = 'Guest User';

    DateTime? ratingAt;
    num? ratingVal;
    if (json['rating'] != null) {
      ratingVal = _toNum(json['rating']['value']);
      final rc = json['rating']['createdAt']?.toString();
      if (rc != null) ratingAt = DateTime.tryParse(rc);
    }

    return BookingItem(
      id: json['_id']?.toString() ?? '',
      playgroundName: playground['name']?.toString() ?? 'Playground',
      playgroundLocation: playground['location']?.toString() ?? '',
      userFullName: fullName,
      userPhone: user['phone']?.toString() ?? '',
      userAvgRating: _toNum(user['averageRating']),
      userSkillLevel: user['skillLevel']?.toString(),
      date: json['date']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      courtNumber: json['courtNumber']?.toString() ?? '',
      duration: int.tryParse(json['duration']?.toString() ?? '') ?? 0,
      totalPrice: _toNum(json['totalPrice']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      ratingCreatedAt: ratingAt,
      ratingValue: ratingVal,
    );
  }
}

num? _toNum(dynamic v) {
  if (v is num) return v;
  return num.tryParse(v?.toString() ?? '');
}

class VendorBookingApi {
  final _storage = const FlutterSecureStorage();
   // final _baseUrl = 'http://192.168.1.4:3000';

  static const String _baseUrl =  'https://padel-backend-git-main-invosegs-projects.vercel.app';

  Future<String?> _token() => _storage.read(key: 'token');

  Future<List<BookingItem>> fetchBookings() async {
    final token = await _token();
    final uri = Uri.parse('$_baseUrl/api/v1/booking/getBookings');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },

    );
    print("Response body: ${res.body}");


    final data = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final List arr = (data['data'] as List?) ?? [];
      return arr.map((e) => BookingItem.fromJson(e)).toList();
    } else {
      final msg = data['message']?.toString() ?? 'Failed to fetch bookings';
      throw Exception(msg);
    }
  }
}
