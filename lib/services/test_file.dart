// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class TestAdminDashboardScreen extends StatelessWidget {
//   const TestAdminDashboardScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final isWide = MediaQuery.of(context).size.width > 800;
//
//     return Scaffold(
//       backgroundColor: Color(0xFF072A40),
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
//               color: Colors.white.withOpacity(0.95),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: const [
//                 Icon(Icons.search, color:Color(0xFF072A40)),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search",
//                       hintStyle: TextStyle(color: Color(0xFF072A40)),
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
//             color:  Colors.white.withOpacity(0.95),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Icon(Icons.tune, color: Color(0xFF072A40)),
//         ),
//         const SizedBox(width: 16),
//         if (isWide)
//         const SizedBox(width: 16),
//         ElevatedButton.icon(
//           onPressed: () {},
//           icon: const Icon(Icons.add, color: Color(0xFF072A40)),
//           label: const Text(
//             "Add New",
//             style: TextStyle(color: Color(0xFF072A40)),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.white.withOpacity(0.95),
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
//         _statCard(Icons.sports_tennis, "Total Courts", "24", Color(0xFF072A40)),
//         _statCard(Icons.people, "Vendors", "10", Color(0xFF072A40)),
//         _statCard(Icons.store, "Products", "42", Color(0xFF072A40)),
//         _statCard(Icons.notifications_active, "Requests", "5", Color(0xFF072A40)),
//       ],
//     );
//   }
//
//   Widget _statCard(IconData icon, String label, String count, Color iconColor) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.95),
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
//                 color: Color(0xFF072A40),
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               )),
//           Text(label,
//               style: GoogleFonts.poppins(
//                 color: Color(0xFF072A40),
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               )),
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
//               color:  Colors.white,
//               fontWeight: FontWeight.w600,
//             )),
//         const SizedBox(height: 12),
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.95),
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
//                     backgroundColor: Color(0xFF072A40).withOpacity(0.2),
//                     child: Icon(court["icon"], color: Color(0xFF072A40)),
//                   ),
//                   title: Text(court["name"],
//                       style: GoogleFonts.poppins(color: Color(0xFF072A40))),
//                   subtitle: Text(court["date"],
//                       style: GoogleFonts.poppins(
//                           color: Color(0xFF072A40), fontSize: 12)),
//                   trailing: Text(court["type"],
//                       style: GoogleFonts.poppins(color: Color(0xFF072A40))),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
