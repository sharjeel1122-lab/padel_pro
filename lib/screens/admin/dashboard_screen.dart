import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          if (isWide) _buildSidebar(),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildStatsGrid(context),
                    const SizedBox(height: 32),
                    _buildVendorSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sidebar
  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Color(0xFF072A40),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PadelPro Admin",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
          const SizedBox(height: 32),
          _sidebarItem(Icons.dashboard, "Dashboard",),
          _sidebarItem(Icons.sports_tennis, "Courts"),
          _sidebarItem(Icons.people, "Vendors"),
          _sidebarItem(Icons.store, "Products"),
          _sidebarItem(Icons.settings, "Settings"),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white70),
          const SizedBox(width: 12),
          Text(title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome Admin 👋",
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF072A40),
            )),
        const SizedBox(height: 4),
        Text("Your admin panel at a glance",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            )),
      ],
    );
  }

  // Stats Grid
  Widget _buildStatsGrid(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _dashboardCard(Icons.sports_tennis, "Courts", "24", Color(0xFF072A40)),
        _dashboardCard(Icons.people, "Vendors", "10", Color(0xFF072A40)),
        _dashboardCard(Icons.store, "Products", "42", Color(0xFF072A40)),
        _dashboardCard(Icons.notifications_active, "Requests", "5", Color(0xFF072A40)),
      ],
    );
  }

  Widget _dashboardCard(IconData icon, String label, String count, Color color) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 14),
            Text(count,
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // Recent Vendors Section
  Widget _buildVendorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Vendors",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF072A40),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text("Vendor ${index + 1}",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text("Added ${3 + index} courts",
                    style: GoogleFonts.poppins(fontSize: 13)),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[700]),
                onTap: () {
                  // Navigate to detail
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
