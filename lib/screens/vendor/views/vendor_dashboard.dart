import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:padel_pro/controllers/auth%20controllers/auth_rolebase_controller.dart';
import 'package:padel_pro/controllers/vendor%20controllers/dashboard_controller.dart';
import 'package:padel_pro/screens/profile_screen/controller/profile_controller.dart';
import 'package:padel_pro/screens/profile_screen/profile_screen.dart';
import 'package:padel_pro/screens/vendor/tournament/tournament_create_screen.dart';
import 'package:padel_pro/screens/vendor/tournament/vendor_view_tournament_screen.dart';
import 'package:padel_pro/screens/vendor/views/club_card.dart';
import 'package:padel_pro/screens/vendor/views/fetch_test.dart';
import 'package:padel_pro/services/vendors%20api/fetch_club_courts_api.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});



  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VendorDashboardController());
    final authController = Get.put(AuthController());
    final ProfileController _controllerProfile = Get.put(ProfileController());

    @override
    void initState() {
      super.initState();
      _controllerProfile.fetchProfile();
    }





    return Scaffold(
      drawer: _buildPremiumDrawer(),
      backgroundColor: const Color(0xFF0C1E2C),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0C1E2C),
        elevation: 0,
        toolbarHeight: 40,
        centerTitle: true,
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome, ${_controllerProfile.fullName ?? 'Vendor'}",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Manage Your Clubs.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: controller.addClub,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "New Club",
                        style: TextStyle(color: Color(0xFF0C1E2C)),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF0C1E2C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white70),
                    SizedBox(width: 8),
                    Text(
                      _controllerProfile.profileData['city'],
                      style: TextStyle(color: Colors.white70),
                    ),
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
                const Text(
                  "My Clubs",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Club Cards
                Expanded(
                  child: Obx(
                    () => GridView.builder(
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
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumDrawer() {
    final ProfileController _controllerProfile = Get.put(ProfileController());
    return Drawer(
      width: MediaQuery.of(Get.context!).size.width * 0.8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
      ),
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C1E2C), Color(0xFF0C1E2C), Color(0xFF0C1E2C)],
          ),
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  // Profile Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        '#',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Vendor Name
                  Text(
                    _controllerProfile.fullName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Vendor Email
                  Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: Text(
                        _controllerProfile.profileData['email'] ?? "Your email",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // View Profile Button
                  ElevatedButton(
                    onPressed: () => Get.to(ProfileScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'View Profile',
                      style: TextStyle(
                        color: Color(0xFF0C1E2C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildMenuItem(
                    icon: Icons.tour,
                    title: 'My Tournaments',
                    onTap: () => Get.to(ViewTournamentsScreen()),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(color: Colors.white, thickness: 0.5),
                  ),

                  _buildMenuItem(
                    icon: Icons.api,
                    title: 'Fetch Test',
                    onTap: () async {
                      try {
                        final playgrounds = await FetchVendorApi()
                            .getVendorPlaygrounds();
                        for (var p in playgrounds) {
                          print('🏟️ Playground: ${p["name"]}');
                        }
                      } catch (e) {
                        print('❌ Error fetching vendor playgrounds: $e');
                      }
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(color: Colors.white, thickness: 0.5),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: debugCheckStoredValues,
                      isLogout: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red.shade200 : Colors.white,
        size: 28,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red.shade200 : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isLogout ? Colors.red.shade200 : Colors.white.withOpacity(0.6),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
    );
  }
}

void testVendorPlaygroundApi() async {
  try {
    final response = await FetchVendorApi().getVendorPlaygrounds();
    print(response); // Or update UI with the data
  } catch (e) {
    print('Fetch failed: $e');
  }
}

void debugCheckStoredValues() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  final vendorId = await storage.read(key: 'vendorId');
  print('🧪 token: $token');
  print('🧪 vendorId: $vendorId');
}
