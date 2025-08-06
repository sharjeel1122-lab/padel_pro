// import 'package:flutter/material.dart';
//
// class CourtModel {
//   TextEditingController courtNumberController;
//   List<String> courtType;
//   List<Map<String, dynamic>> pricing;
//   List<Map<String, dynamic>> peakHours;
//
//   CourtModel({
//     required this.courtNumberController,
//     required this.courtType,
//     required this.pricing,
//     required this.peakHours,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       'courtNumber': courtNumberController.text.trim(),
//       'courtType': courtType,
//       'pricing': pricing,
//       'peakHours': peakHours,
//     };
//   }
//
// }
import 'package:flutter/material.dart';

import 'club_court_pricing _model.dart';

class CourtModel {
  TextEditingController courtNumberController;
  List<String> courtType;
  List<Pricing> pricing;
  List<PeakHours> peakHours;

  CourtModel({
    required this.courtNumberController,
    required this.courtType,
    required this.pricing,
    required this.peakHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'courtNumber': courtNumberController.text.trim(),
      'courtType': courtType,
      'pricing': pricing.map((p) => p.toJson()).toList(),
      'peakHours': peakHours.map((ph) => ph.toJson()).toList(),
    };
  }
}
