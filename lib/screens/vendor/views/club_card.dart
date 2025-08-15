import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import 'package:padel_pro/controllers/vendor%20controllers/dashboard_controller.dart';

class ClubCard extends StatelessWidget {
  final String name;
  final String location;
  final int courts;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final List<String> imageUrls;

  ClubCard({
    super.key,
    required this.name,
    required this.location,
    required this.courts,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    this.imageUrls = const [],
  });

  final controller = Get.put(VendorDashboardController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF162A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row (title + grid icon opens gallery)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.grid, color: Colors.white54),
                tooltip: 'View photos',
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(location, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(LucideIcons.layoutPanelTop, color: Colors.white60, size: 16),
              const SizedBox(width: 6),
              Text("$courts Courts", style: const TextStyle(color: Colors.white70)),
            ],
          ),

          const Spacer(),
          const Divider(color: Colors.white30),
          const SizedBox(height: 10),

          // Actions row (compact)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text("View", style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(50, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }








}
