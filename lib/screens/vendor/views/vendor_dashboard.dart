import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/controllers/vendor%20controllers/dashboard_controller.dart';
import 'package:padel_pro/screens/vendor/views/club_card.dart';


class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VendorDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFF0C1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1E2C),
        elevation: 0,
        toolbarHeight: 40,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome, Vendor",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          SizedBox(height: 4),
                          Text("Manage Your Clubs.",
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: controller.addClub,
                      icon: const Icon(Icons.add),
                      label: const Text("New Club"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white70),
                    SizedBox(width: 8),
                    Text("Lahore", style: TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search clubs...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text("My Clubs",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Club Cards
                Expanded(
                  child: Obx(() => GridView.builder(
                    itemCount: controller.clubs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 3 : 2,
                      mainAxisExtent: 210,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final club = controller.clubs[index];
                      return ClubCard(
                        name: club['name'],
                        location: club['location'],
                        courts: club['courts'],
                        onView: () => controller.viewCourts(index),
                        onEdit: () => controller.editClub(index),
                        onDelete: () => controller.deleteClub(index),
                      );
                    },
                  )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
