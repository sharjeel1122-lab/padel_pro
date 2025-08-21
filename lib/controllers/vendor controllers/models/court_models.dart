import 'package:flutter/material.dart';

class PricingRow {
  PricingRow({required this.duration, required this.priceCtrl});
  int duration;
  final TextEditingController priceCtrl;
}

class PeakRow {
  final TextEditingController startCtrl = TextEditingController();
  final TextEditingController endCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController(text: '0');
  
  void dispose() {
    startCtrl.dispose();
    endCtrl.dispose();
    priceCtrl.dispose();
  }
}
