// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padel_pro/screens/admin/total%20clubs/recommended_status_controller.dart';

// your existing controllers & screens
import 'package:padel_pro/screens/user/user_controller/user_allclub_screen_controller.dart';
import 'package:padel_pro/screens/user/views/user_allclub_details_screen.dart';

// new files below

const Color kPrimary = Color(0xFF072A40);
const Color kBg = Color(0xFFF5F5F5);

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
        title: const Text('Manage Clubs', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimary,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),


            Expanded(
              child: Obx(() {
                if (userClubController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userClubController.playgrounds.isEmpty) {
                  return const Center(child: Text('No playgrounds found'));
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: userClubController.searchController,
        onChanged: (value) => userClubController.searchPlaygrounds(value),
        decoration: InputDecoration(
          hintText: 'Search Clubs...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          suffixIcon: userClubController.searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
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

  // Widget _buildCategories() {
  //   final categories = ['All', 'DHA', 'Model Town', 'Bahria Town'];
  //
  //   return SizedBox(
  //     height: 40,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: categories.length,
  //       itemBuilder: (context, index) {
  //         final isSelected = userClubController.selectedCategory.value == index;
  //         return Padding(
  //           padding: const EdgeInsets.only(right: 8),
  //           child: ChoiceChip(
  //             label: Text(categories[index]),
  //             selected: isSelected,
  //             onSelected: (selected) {
  //               userClubController.selectedCategory.value = index;
  //               userClubController.filterByCategory(categories[index]);
  //             },
  //             selectedColor: kPrimary,
  //             labelStyle: TextStyle(
  //               color: isSelected ? Colors.white : Colors.black87,
  //             ),
  //             backgroundColor: Colors.white,
  //             side: BorderSide(
  //               color: isSelected ? kPrimary : Colors.grey.shade300,
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildPlaygroundCard(Map<String, dynamic> playground, BuildContext context) {
    final distance = playground['distance'] ?? '2.5 km';
    final rating = playground['rating'] ?? 4.5;
    final courts = (playground['courts'] ?? []) as List;
    final isRecommended = (playground['recommended'] ?? false) as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: isRecommended ? kPrimary.withOpacity(0.4) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              playground['image'] ??
                  'https://www.shutterstock.com/image-illustration/indoor-padel-paddle-tennis-court-260nw-2486054935.jpg',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + rating + recommended chip
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        playground['name'] ?? 'Club Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kPrimary.withOpacity(0.25)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thumb_up_alt_outlined, size: 16, color: kPrimary),
                        SizedBox(width: 6),
                        Text(
                          'Recommended',
                          style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Location + Distance
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        playground['location'] ?? 'Club Location',
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.directions, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Courts and Price + Admin Actions
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.layoutPanelTop, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${courts.length} Courts',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'From Rs. ${userClubController.getPlaygroundPrice(playground)}/hour',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Buttons: Details + Recommend/Unrecommend (admin)
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Get.to(() => UserClubDetailScreen(playground: playground)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kPrimary),
                        foregroundColor: kPrimary,
                      ),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
                    ),
                    const SizedBox(width: 12),
                    Obx(() {
                      final loading = recommendedController.isBusyFor(playground['id'] ?? '').value;
                      final rec = (playground['recommended'] ?? false) as bool;

                      return ElevatedButton.icon(
                        onPressed: loading
                            ? null
                            : () async {
                          final confirm = await _confirmRecommendDialog(rec);
                          if (confirm != true) return;

                          await recommendedController.updateRecommended(
                            id: playground['id']?.toString() ?? '',
                            recommended: !rec,
                            onLocalSuccess: () {
                              // reflect in list immediately
                              final idx = userClubController.playgrounds.indexWhere(
                                    (p) => p['id']?.toString() == playground['id']?.toString(),
                              );
                              if (idx != -1) {
                                userClubController.playgrounds[idx]['recommended'] = !rec;
                                userClubController.playgrounds.refresh();
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rec ? Colors.redAccent : kPrimary,
                          foregroundColor: Colors.white,
                        ),
                        icon: loading
                            ? const SizedBox(
                            width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(rec ? Icons.thumb_down_alt_outlined : Icons.thumb_up_alt_outlined),
                        label: Text(rec ? 'Unrecommend' : 'Recommend'),
                      );
                    }),
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

    return Get.defaultDialog<bool>(
      title: title,
      middleText: desc,
      barrierDismissible: false,
      radius: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white),
        onPressed: () => Get.back(result: true),
        child: const Text('Confirm'),
      ),
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(foregroundColor: kPrimary, side: const BorderSide(color: kPrimary)),
        onPressed: () => Get.back(result: false),
        child: const Text('Cancel'),
      ),
    );
  }
}
