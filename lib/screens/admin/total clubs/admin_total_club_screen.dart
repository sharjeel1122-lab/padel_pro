// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/admin/total%20clubs/admin_total_club_details.dart';
import 'package:padel_pro/screens/admin/total%20clubs/recommended_status_controller.dart';

// your existing controllers & screens
import 'package:padel_pro/screens/user/user_controller/user_allclub_screen_controller.dart';
import 'package:padel_pro/screens/user/views/user_allclub_details_screen.dart';

// Admin theme colors
const Color kPrimary = Color(0xFF0A3B5C);
const Color kBg = Color(0xFF072A40);
const Color kCardBg = Color(0xFF0A3B5C);
const Color kAccent = Color(0xFF1E88E5);

class AdminClubScreen extends StatelessWidget {
  final userClubController = Get.put(UserClubScreenController());
  final recommendedController = Get.put(RecommendedStatusController());

  AdminClubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Manage Clubs',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: kPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => userClubController.refreshData(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kPrimary, kBg],
          ),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (userClubController.isLoading.value) {
                    return _buildLoadingState();
                }

                if (userClubController.playgrounds.isEmpty) {
                    return _buildEmptyState();
                }

                return ListView.builder(
                  itemCount: userClubController.playgrounds.length,
                  itemBuilder: (context, index) {
                    final playground = userClubController.playgrounds[index];
                    return _buildPlaygroundCard(playground, context);
                  },
                );
              }),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: userClubController.searchController,
        onChanged: (value) => userClubController.searchPlaygrounds(value),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Search clubs by name, location...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: userClubController.searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
            onPressed: () {
              userClubController.searchController.clear();
              userClubController.searchPlaygrounds('');
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Obx(() {
      final totalClubs = userClubController.playgrounds.length;
      final recommendedClubs = userClubController.playgrounds
          .where((p) => (p['recommended'] ?? false) as bool)
          .length;

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.sports_tennis,
              title: 'Total Clubs',
              value: totalClubs.toString(),
              color: kAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.thumb_up_alt_outlined,
              title: 'Recommended',
              value: recommendedClubs.toString(),
              color: Colors.orange,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading clubs...',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_tennis,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No clubs found',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaygroundCard(Map<String, dynamic> playground, BuildContext context) {
    final distance = playground['distance'] ?? '2.5 km';
    final rating = playground['rating'] ?? 4.5;
    final courts = (playground['courts'] ?? []) as List;
    final isRecommended = (playground['recommended'] ?? false) as bool;
    final photos = (playground['photos'] as List<dynamic>?)
        ?.where((e) => e != null)
        .toList()
        ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecommended ? Colors.orange.withOpacity(0.5) : Colors.white.withOpacity(0.2),
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlay
          Stack(
            children: [
          ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              photos.isNotEmpty ? photos[0] : 'https://via.placeholder.com/180x180',
                  height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image, size: 50, color: Colors.white70),
                  ),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
              // Recommended badge
              if (isRecommended)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Recommended',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        playground['name'] ?? 'Club Name',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                      children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                        ),
                    ),
                  ],
                ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Location + Distance
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        playground['location'] ?? 'Club Location',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.directions, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Courts and Price
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                      children: [
                          const Icon(LucideIcons.layoutPanelTop, size: 16, color: kAccent),
                          const SizedBox(width: 6),
                        Text(
                          '${courts.length} Courts',
                            style: GoogleFonts.poppins(
                              color: kAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                      'From Rs. ${userClubController.getPlaygroundPrice(playground)}/hour',
                        style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Buttons: Details + Recommend/Unrecommend (admin)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                      onPressed: () => Get.to(() => AdminClubDetailScreen(playground: playground)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: Text(
                          'Details',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final loading = recommendedController.isBusyFor(playground['_id'] ?? '').value;
                      final rec = (playground['recommended'] ?? false) as bool;

                      return ElevatedButton.icon(
                        onPressed: loading
                            ? null
                            : () async {
                          final confirm = await _confirmRecommendDialog(rec);
                          if (confirm != true) return;

                          await recommendedController.updateRecommended(
                              id: playground['_id']?.toString() ?? '',
                            recommended: !rec,
                            onLocalSuccess: () {
                              // reflect in list immediately
                              final idx = userClubController.playgrounds.indexWhere(
                                      (p) => p['_id']?.toString() == playground['_id']?.toString(),
                              );
                              if (idx != -1) {
                                userClubController.playgrounds[idx]['recommended'] = !rec;
                                userClubController.playgrounds.refresh();
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: rec ? Colors.redAccent : Colors.orange,
                          foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                        ),
                        icon: loading
                            ? const SizedBox(
                                  width: 18, height: 18, 
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(
                                  rec ? Icons.thumb_down_alt_outlined : Icons.thumb_up_alt_outlined,
                                  size: 18,
                                ),
                          label: Text(
                            rec ? 'Unrecommend' : 'Recommend',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                      );
                    }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmRecommendDialog(bool currentlyRecommended) {
    final title = currentlyRecommended ? 'Remove recommendation?' : 'Mark as recommended?';
    final desc = currentlyRecommended
        ? 'This club will no longer appear as recommended to users.'
        : 'This club will appear as recommended to users.';

    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: kPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          desc,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
        onPressed: () => Get.back(result: true),
            child: Text(
              'Confirm',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
