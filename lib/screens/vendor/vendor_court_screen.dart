import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/vendor/controllers/court_controller.dart';
import 'widgets/court_card.dart';
import 'widgets/court_dialog.dart';

class VendorCourtScreen extends StatelessWidget {
  final controller = Get.put(VendorCourtController());

  VendorCourtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text("My Venues", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color(0xFF072A40),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => showCourtDialog(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.courts.isEmpty) {
            return Center(
              child: Text("No venues added yet",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: controller.courts.length,
            itemBuilder: (context, index) {
              final court = controller.courts[index];
              return CourtCard(court: court);
            },
          );
        }),
      ),
    );
  }
}
