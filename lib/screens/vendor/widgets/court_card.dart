import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/court_controller.dart';
import '../vendor_models/court_model.dart';
import 'court_dialog.dart';

class CourtCard extends StatelessWidget {
  final VendorCourtModel court;
  const CourtCard({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VendorCourtController>();
    return Card(
      color: Colors.grey.shade200,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(court.imageUrls.first),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(court.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "📍 ${court.location}\n💰 PKR ${court.price.toStringAsFixed(0)}\n🕒 ${court.startTime} - ${court.endTime}",
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              court.isApproved ? Icons.verified : Icons.hourglass_top,
              color: court.isApproved ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () {
                controller.populateForEdit(court);
                showCourtDialog(context, isEdit: true, courtId: court.id);
              },
              child: Text('Edit',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF072A40),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline)),
            )
          ],
        ),
      ),
    );
  }
}
