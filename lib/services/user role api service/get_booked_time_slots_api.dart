import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// ---- DTOs ----

class BookedSlotDto {
  final String startTime; // "HH:mm"
  final String endTime;   // "HH:mm"
  final String duration;  // "60 minutes"
  final String timeSlot;  // "09:00 - 10:00"
  final num price;

  BookedSlotDto({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.timeSlot,
    required this.price,
  });

  factory BookedSlotDto.fromMap(Map<String, dynamic> m) => BookedSlotDto(
    startTime: (m['startTime'] ?? '').toString(),
    endTime: (m['endTime'] ?? '').toString(),
    duration: (m['duration'] ?? '').toString(),
    timeSlot: (m['timeSlot'] ?? '').toString(),
    price: m['price'] is num ? m['price'] : num.tryParse('${m['price'] ?? 0}') ?? 0,
  );
}

class BookedTimeSlotsDto {
  final String? playgroundName;
  final String? playgroundLocation;
  final int? courtNumber;
  final String? courtType;
  final String? date;         // "YYYY-MM-DD"
  final String? openingTime;  // "HH:mm"
  final String? closingTime;  // "HH:mm"
  final int totalBookedSlots;
  final List<BookedSlotDto> bookedSlots;
  final String? message;

  BookedTimeSlotsDto({
    this.playgroundName,
    this.playgroundLocation,
    this.courtNumber,
    this.courtType,
    this.date,
    this.openingTime,
    this.closingTime,
    required this.totalBookedSlots,
    required this.bookedSlots,
    this.message,
  });

  factory BookedTimeSlotsDto.fromApi(Map<String, dynamic> body) {
    final data = body['data'] is Map<String, dynamic> ? body['data'] as Map<String, dynamic> : <String, dynamic>{};
    final slots = (data['bookedSlots'] is List)
        ? (data['bookedSlots'] as List)
        .map((e) => BookedSlotDto.fromMap(e as Map<String, dynamic>))
        .toList()
        : <BookedSlotDto>[];
    return BookedTimeSlotsDto(
      playgroundName: data['playgroundName']?.toString(),
      playgroundLocation: data['playgroundLocation']?.toString(),
      courtNumber: data['courtNumber'] is num ? (data['courtNumber'] as num).toInt() : int.tryParse('${data['courtNumber'] ?? ''}'),
      courtType: data['courtType']?.toString(),
      date: data['date']?.toString(),
      openingTime: data['openingTime']?.toString(),
      closingTime: data['closingTime']?.toString(),
      totalBookedSlots: data['totalBookedSlots'] is num ? (data['totalBookedSlots'] as num).toInt() : 0,
      bookedSlots: slots,
      message: (body['message'] ?? data['message'])?.toString(),
    );
  }
}

/// ---- API ----

class GetBookedTimeSlotsApi {
  static const _baseUrl = 'https://padel-backend-git-main-invosegs-projects.vercel.app';
  static const _endpoint = '/api/v1/booking/showBookedCourts';
  static const _storage = FlutterSecureStorage();

  Future<BookedTimeSlotsDto> fetch({
    required String playgroundId,
    required int courtNumber,
    required String date, // "YYYY-MM-DD"
  }) async {
    final token = await _storage.read(key: 'token');
    final uri = Uri.parse('$_baseUrl$_endpoint');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'playgroundId': playgroundId,
        'courtNumber': courtNumber,
        'date': date,
      }),
    );

    final Map<String, dynamic> body =
    res.body.isNotEmpty ? (jsonDecode(res.body) as Map<String, dynamic>) : <String, dynamic>{};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return BookedTimeSlotsDto.fromApi(body);
    }

    final msg = (body['message'] ?? res.reasonPhrase ?? 'Request failed ${res.statusCode}').toString();
    throw Exception(msg);
  }
}
