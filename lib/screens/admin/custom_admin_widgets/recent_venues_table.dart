import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/admin/controllers/dashboard_controller.dart';


class RecentVenuesTable extends StatelessWidget {
  final controller = Get.find<DashboardController>();

  RecentVenuesTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Venues",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A3B5C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Obx(() => ListView.separated(
            itemCount: controller.courts.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (_, __) =>
            const Divider(color: Colors.white10, height: 0),
            itemBuilder: (context, index) {
              final court = controller.courts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.sports_tennis, color: Colors.white),
                ),
                title: Text(court.name,
                    style: GoogleFonts.poppins(color: Colors.white)),
                subtitle: Text(court.date,
                    style: GoogleFonts.poppins(
                        color: Colors.white54, fontSize: 12)),
                trailing: Text(court.type,
                    style: GoogleFonts.poppins(color: Colors.white70)),
              );
            },
          )),
        ),
      ],
    );
  }
}
