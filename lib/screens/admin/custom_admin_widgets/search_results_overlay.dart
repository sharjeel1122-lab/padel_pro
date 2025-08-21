import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padel_pro/screens/admin/controllers/search_controller.dart';
import 'package:padel_pro/services/admin%20api/fetch_pending_courts_api.dart';

class SearchResultsOverlay extends StatelessWidget {
  final PendingCourtsSearchController searchController;

  const SearchResultsOverlay({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PendingCourtsSearchController>(
      builder: (controller) {
        if (!controller.showSearchResults.value) {
          return const SizedBox.shrink();
        }

                 return Stack(
           children: [
             // Blurred background overlay with tap to close
             Positioned.fill(
               child: GestureDetector(
                 onTap: () {
                   controller.hideSearchOverlay();
                 },
                 child: BackdropFilter(
                   filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                   child: Container(
                     color: Colors.black.withOpacity(0.3),
                   ),
                 ),
               ),
             ),
                         // Search results content
             Positioned(
               top: 80, // Below the top bar
               left: 20,
               right: 20,
               bottom: 20,
               child: GestureDetector(
                 onTap: () {
                   // Prevent closing when tapping on the content
                 },
                 child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A3B5C).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Search Results",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                                                     IconButton(
                             onPressed: () {
                               controller.hideSearchOverlay();
                             },
                             icon: const Icon(Icons.close, color: Colors.white),
                           ),
                        ],
                      ),
                    ),
                    // Results list
                    Expanded(
                      child: controller.searchResults.isEmpty
                          ? _buildNoResults()
                          : _buildResultsList(controller),
                    ),
                                     ],
                 ),
               ),
             ),
           ),
          ],
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No results found",
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try searching with different keywords",
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(PendingCourtsSearchController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final court = controller.searchResults[index];
        return _buildResultCard(court);
      },
    );
  }

  Widget _buildResultCard(PendingCourt court) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: Text(
          court.playgroundName,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "${court.city}, ${court.town}",
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              "Vendor: ${court.vendor.firstName} ${court.vendor.lastName}",
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        children: [
          ...court.courts.map((courtItem) => _buildCourtItem(court, courtItem)),
        ],
      ),
    );
  }

  Widget _buildCourtItem(PendingCourt pendingCourt, Court court) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            radius: 20,
            child: const Icon(Icons.sports_tennis, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Court ${court.courtNumber}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  court.courtType,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Text(
              court.status.toUpperCase(),
              style: GoogleFonts.poppins(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
