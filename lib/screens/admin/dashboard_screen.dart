// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class AdminDashboardScreen extends StatelessWidget {
//   const AdminDashboardScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final isWide = MediaQuery.of(context).size.width > 800;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF072A40),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildTopBar(isWide),
//                     const SizedBox(height: 24),
//                     _buildStatCardsGrid(context),
//                     const SizedBox(height: 24),
//                     _buildRecentCourtsTable(),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   // --------------------------- Top Bar ---------------------------
//   Widget _buildTopBar(bool isWide) {
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             height: 50,
//             decoration: BoxDecoration(
//               color: const Color(0xFF0A3B5C),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: const [
//                 Icon(Icons.search, color: Colors.white54),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search",
//                       hintStyle: TextStyle(color: Colors.white54),
//                       border: InputBorder.none,
//                     ),
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Container(
//           height: 50,
//           width: 50,
//           decoration: BoxDecoration(
//             color: const Color(0xFF0A3B5C),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Icon(Icons.tune, color: Colors.white),
//         ),
//         if (isWide)
//           Container(
//             height: 50,
//             width: 50,
//             decoration: BoxDecoration(
//               color: const Color(0xFF0A3B5C),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(Icons.tune, color: Colors.white),
//           ),
//         const SizedBox(width: 16),
//         ElevatedButton.icon(
//           onPressed: () {},
//           icon: const Icon(Icons.add, color: Colors.white),
//           label: const Text(
//             "Add New",
//             style: TextStyle(color: Colors.white),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF0A3B5C),
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // --------------------------- Stat Cards Grid ---------------------------
//   Widget _buildStatCardsGrid(BuildContext context) {
//     final isWide = MediaQuery.of(context).size.width > 700;
//
//     return GridView.count(
//       crossAxisCount: isWide ? 4 : 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       children: [
//         _statCard(Icons.sports_tennis, "Total Courts", "24", Colors.white),
//         _statCard(Icons.people, "Vendors", "10", Colors.white),
//         _statCard(Icons.store, "Products", "42", Colors.white),
//         _statCard(Icons.notifications_active, "Requests", "5", Colors.white),
//       ],
//     );
//   }
//
//   Widget _statCard(IconData icon, String label, String count, Color iconColor) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF0A3B5C),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.white.withOpacity(0.1),
//             child: Icon(icon, color: iconColor),
//           ),
//           const SizedBox(height: 12),
//           Text(count,
//               style: GoogleFonts.poppins(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               )),
//           Text(label,
//               style: GoogleFonts.poppins(
//                 color: Colors.white70,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               )),
//           const SizedBox(height: 6),
//           LinearProgressIndicator(
//             value: 0.7,
//             backgroundColor: Colors.white10,
//             color: Colors.white,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --------------------------- Recent Courts Table ---------------------------
//   Widget _buildRecentCourtsTable() {
//     final List<Map<String, dynamic>> recentCourts = [
//       {"icon": Icons.sports_tennis, "name": "Court A", "date": "03-02-2025", "type": "Clay"},
//       {"icon": Icons.sports_tennis, "name": "Court B", "date": "27-02-2025", "type": "Grass"},
//       {"icon": Icons.sports_tennis, "name": "Court C", "date": "23-02-2025", "type": "Hard"},
//       {"icon": Icons.sports_tennis, "name": "Court D", "date": "23-02-2025", "type": "Clay"},
//       {"icon": Icons.sports_tennis, "name": "Court E", "date": "22-02-2025", "type": "Synthetic"},
//     ];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Recent Courts",
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//             )),
//         const SizedBox(height: 12),
//         Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFF0A3B5C),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Scrollbar(
//             thumbVisibility: true,
//             child: ListView.separated(
//               itemCount: recentCourts.length,
//               shrinkWrap: true,
//               physics: const BouncingScrollPhysics(),
//               separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 0),
//               itemBuilder: (context, index) {
//                 final court = recentCourts[index];
//                 return ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Colors.white.withOpacity(0.2),
//                     child: Icon(court["icon"], color: Colors.white),
//                   ),
//                   title: Text(court["name"], style: GoogleFonts.poppins(color: Colors.white)),
//                   subtitle: Text(court["date"], style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
//                   trailing: Text(court["type"], style: GoogleFonts.poppins(color: Colors.white70)),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controllers/dashboard_controller.dart';

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(isWide),
                    const SizedBox(height: 24),
                    _buildStatCardsGrid(context),
                    const SizedBox(height: 24),
                    _buildRecentCourtsTable(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isWide) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF0A3B5C),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Icon(Icons.search, color: Colors.white54),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF0A3B5C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
        if (isWide)
          Container(
            height: 50,
            width: 50,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A3B5C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add New", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A3B5C),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardsGrid(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Obx(() => GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _statCard(Icons.sports_tennis, "Total Courts", "${controller.totalCourts.value}"),
        _statCard(Icons.people, "Vendors", "${controller.vendors.value}"),
        _statCard(Icons.store, "Products", "${controller.products.value}"),
        _statCard(Icons.notifications_active, "Requests", "${controller.requests.value}"),
      ],
    ));
  }

  Widget _statCard(IconData icon, String label, String count) {
    return Container(
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
    );
  }

  Widget _buildRecentCourtsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Courts",
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
          child: Obx(() => Scrollbar(
            thumbVisibility: true,
            child: ListView.separated(
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
            ),
          )),
        ),
      ],
    );
  }
}
