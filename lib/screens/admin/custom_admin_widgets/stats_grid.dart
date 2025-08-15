// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/admin/controllers/dashboard_controller.dart';

// UPDATED: import path points to "vendors controllers"
import 'package:padel_pro/screens/admin/total%20clubs/admin_total_club_screen.dart';

class StatsGrid extends StatelessWidget {
  StatsGrid({super.key});

  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Obx(
          () => GridView.count(
        crossAxisCount: isWide ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          // Mapped to your controller values:
          // totalCourts -> Total Users
          // vendors     -> Total Vendors
          // products    -> Total Clubs
          // requests    -> Pending Requests
          _statCard(Icons.people, "Total Users",
              controller.totalCourts.value.toString() == "0"? "0":
              "${controller.totalCourts.value-1}"),
          _statCard(Icons.storefront, "Total Vendors",
              "${controller.vendors.value}"),
          _statCard(Icons.sports_tennis, "Total Clubs",
              "${controller.products.value}"),
          _statCard(Icons.notifications_active, "Pending Requests",
              "${controller.requests.value}"),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String count) {
    return GestureDetector(
      onTap: () {
        if (label == "Total Users") {
          Get.toNamed('/total-users');
        } else if (label == "Total Vendors") {
          Get.toNamed('/total-vendors');
        } else if (label == "Total Clubs") {
          Get.to(() => AdminClubScreen());
        } else if (label == "Pending Requests") {
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
            Text(
              count,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
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
