// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/admin/controllers/dashboard_controller.dart';

class StatsGrid extends StatelessWidget {
  final controller = Get.find<DashboardController>();

  StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Obx(() => GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _statCard(Icons.sports_tennis, "Total Venues", "${controller.totalCourts.value}"),
        _statCard(Icons.people, "Vendors", "${controller.vendors.value}"),
        _statCard(Icons.store, "Products", "${controller.products.value}"),
        _statCard(Icons.notifications_active, "Requests", "${controller.requests.value}"),
      ],
    ));
  }

  Widget _statCard(IconData icon, String label, String count) {
    return GestureDetector(
      onTap: () {
        if (label == "Total Venues") {
          Get.toNamed('/total-venues');
        } else if (label == "Vendors") {
          Get.toNamed('/total-vendors');
        } else if (label == "Products") {
          Get.toNamed('/products');
        } else if (label == "Requests") {
          Get.toNamed('/requests');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A3B5C),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.1),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(count,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                )),
            Text(label,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 6),
            const LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.white10,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
