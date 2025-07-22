import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/admin/controllers/dashboard_controller.dart';

import 'custom_admin_widgets/admin_top_bar.dart';
import 'custom_admin_widgets/recent_venues_table.dart';
import 'custom_admin_widgets/stats_grid.dart';


class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({super.key});

  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF072A40),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminTopBar(isWide: isWide),
                const SizedBox(height: 24),
                StatsGrid(),
                const SizedBox(height: 24),
                RecentVenuesTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
