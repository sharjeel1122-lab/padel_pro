// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padel_pro/screens/user/user_controller/user_allclub_screen_controller.dart';
import 'package:padel_pro/screens/user/views/user_allclub_details_screen.dart';

class UserClubScreen extends StatelessWidget {
  final controller = Get.put(UserClubScreenController());

   UserClubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(

        centerTitle: true,
        title: const Text('Explore Clubs', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF072A40),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 16),
            // Categories
            _buildCategories(),
            const SizedBox(height: 16),
            // Playgrounds List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.playgrounds.isEmpty) {
                  return const Center(child: Text('No playgrounds found'));
                }

                return ListView.builder(
                  itemCount: controller.playgrounds.length,
                  itemBuilder: (context, index) {
                    final playground = controller.playgrounds[index];
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
        controller: controller.searchController,
        onChanged: (value) => controller.searchPlaygrounds(value),
        decoration: InputDecoration(
          hintText: 'Search Clubs...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          suffixIcon: controller.searchController.text.isNotEmpty
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
  }

  Widget _buildCategories() {
    final categories = ['All', 'DHA', 'Model Town' ,'Bahria Town'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = controller.selectedCategory.value == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (selected) {
                controller.selectedCategory.value = index;
                controller.filterByCategory(categories[index]);
              },
              selectedColor: const Color(0xFF0C1E2C),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              backgroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaygroundCard(Map<String, dynamic> playground, BuildContext context) {
    final distance = playground['distance'] ?? '2.5 km';
    final rating = playground['rating'] ?? 4.5;
    final courts = playground['courts'] ?? [];

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
                  child: Image.network(
                    playground['image'] ?? 'https://www.shutterstock.com/image-illustration/indoor-padel-paddle-tennis-court-260nw-2486054935.jpg',
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
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      playground['isFavorite'] ?? false ? Icons.favorite : Icons.favorite_border,
                      color: playground['isFavorite'] ?? false ? Colors.red : Colors.white,
                    ),
                    onPressed: () => controller.toggleFavorite(playground['id']),
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
                          color: Color(0xFF0C1E2C),
                        ),
                      ),
                      // Text(
                      //   'From Rs. ${playground['minPrice'] ?? '15'}/hour',
                      //   style: const TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     color: Color(0xFF0C1E2C),
                      //   ),
                      // ),
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Playgrounds',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Price Range
              const Text('Price Range (\$/hour)', style: TextStyle(fontWeight: FontWeight.bold)),
              RangeSlider(
                values: controller.priceRange.value,
                min: 5,
                max: 50,
                divisions: 9,
                labels: RangeLabels(
                  '\$${controller.priceRange.value.start.round()}',
                  '\$${controller.priceRange.value.end.round()}',
                ),
                onChanged: (RangeValues values) {
                  controller.priceRange.value = values;
                },
              ),
              const SizedBox(height: 20),
              // Court Type
              const Text('Court Type', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Indoor', 'Outdoor', 'Panoramic', 'Crystal', 'Wall'].map((type) {
                  final isSelected = controller.selectedTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.selectedTypes.add(type);
                      } else {
                        controller.selectedTypes.remove(type);
                      }
                      controller.selectedTypes.refresh();
                    },
                    selectedColor: const Color(0xFF0C1E2C).withOpacity(0.2),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF0C1E2C) : Colors.black87,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Facilities
              const Text('Facilities', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['wifi', 'lockers', 'showers', 'cafe', 'parking'].map((facility) {
                  final isSelected = controller.selectedFacilities.contains(facility);
                  return FilterChip(
                    label: Text(facility),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.selectedFacilities.add(facility);
                      } else {
                        controller.selectedFacilities.remove(facility);
                      }
                      controller.selectedFacilities.refresh();
                    },
                    selectedColor: const Color(0xFF0C1E2C).withOpacity(0.2),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF0C1E2C) : Colors.black87,
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.resetFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF0C1E2C)),
                      ),
                      child: const Text('Reset', style: TextStyle(color: Color(0xFF0C1E2C))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C1E2C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}