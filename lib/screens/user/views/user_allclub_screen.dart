// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padel_pro/screens/user/user_controller/user_allclub_screen_controller.dart';
import 'package:padel_pro/screens/user/views/user_allclub_details_screen.dart';

class UserClubScreen extends StatelessWidget {
  final controller = Get.put(UserClubScreenController());

  UserClubScreen({super.key});

  static const Color kPrimary = Color(0xFF072A40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Explore Clubs', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimary,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),

            const SizedBox(height: 12),

            // Location chips: All / DHA / Model Town / Bahria Town
            _LocationFilterBar(controller: controller),

            const SizedBox(height: 16),

            // Playgrounds List (ALWAYS use filteredPlaygrounds)
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = controller.filteredPlaygrounds;

                if (list.isEmpty) {
                  return const Center(child: Text('No playgrounds found'));
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final playground = list[index];
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
    return Obx(() {
      final hasText = controller.searchQuery.value.isNotEmpty; // reactive read
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
          controller: controller.searchController,
          onChanged: controller.searchPlaygrounds, // updates Rx searchQuery
          decoration: InputDecoration(
            hintText: 'Search Clubs...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            suffixIcon: hasText
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.searchController.clear();
                controller.searchPlaygrounds('');
              },
            )
                : null,
          ),
        ),
      );
    });
  }

  Widget _buildPlaygroundCard(Map<String, dynamic> playground, BuildContext context) {
    final distance = playground['distance'] ?? '2.5 km';
    final rating = playground['rating'] ?? 4.5;
    final courts = playground['courts'] ?? [];

    final imageUrl = controller.imageUrlFor(playground); // <-- NEW

    return GestureDetector(
      onTap: () => Get.to(() => UserClubDetailScreen(playground: playground)),
      child: Container(
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imageUrl != null
                      ? Image.network(
                    imageUrl,
                    headers: controller.imageHeaders, // <-- if you need auth headers
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _imageFallback(),
                  )
                      : _imageFallback(),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      (playground['isFavorite'] ?? false) ? Icons.favorite : Icons.favorite_border,
                      color: (playground['isFavorite'] ?? false) ? Colors.red : Colors.white,
                    ),
                    onPressed: () => controller.toggleFavorite(
                      (playground['_id']?.toString() ?? playground['id']?.toString()) ?? '',
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  // Location and Distance
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
                  // Courts and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Text(
                        'From Rs. ${controller.getPlaygroundPrice(playground)}/hour',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }
}

class _LocationFilterBar extends StatelessWidget {
  const _LocationFilterBar({required this.controller});
  final UserClubScreenController controller;

  static const Color kPrimary = Color(0xFF072A40);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.locationFilter.value;
      final items = controller.knownLocations;

      ChoiceChip _chip(String label) {
        final selected = current == label;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.mapPin,
                size: 16,
                color: selected ? Colors.white : kPrimary,
              ),
              const SizedBox(width: 6),
              Text(label),
            ],
          ),
          selected: selected,
          onSelected: (_) => controller.setLocationFilter(label),
          selectedColor: kPrimary,
          labelStyle: TextStyle(
            color: selected ? Colors.white : kPrimary,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: selected ? kPrimary : Colors.black12),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final l in items) ...[
              _chip(l),
              const SizedBox(width: 8),
            ],
          ],
        ),
      );
    });
  }
}
