import 'package:flutter/material.dart';

class CourtModel {
  TextEditingController courtNumberController;
  List<String> courtType; // Must be List<String>
  List<Map<String, dynamic>> pricing;
  List<Map<String, dynamic>> peakHours;

  CourtModel({
    required this.courtNumberController,
    required this.courtType,
    required this.pricing,
    required this.peakHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'courtNumber': courtNumberController.text.trim(),
      'courtType': courtType, // ✅ Send as List
      'pricing': pricing,
      'peakHours': peakHours,
    };
  }
}
