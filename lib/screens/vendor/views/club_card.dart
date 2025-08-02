import 'package:flutter/material.dart';
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

  ClubCard({
    super.key,
    required this.name,
    required this.location,
    required this.courts,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16)),
              ),
              const Icon(LucideIcons.grid, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 4),
          Text(location, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.layoutPanelTop,
                  color: Colors.white60, size: 16),
              const SizedBox(width: 6),
              Text("$courts Courts",
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const Spacer(),
          const Divider(color: Colors.white30),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Compact View button
                ElevatedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text(
                    "View",
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(50, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),

                // Edit button
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(0),
                  splashRadius: 20,
                ),

                // Delete button
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(0),
                  splashRadius: 20,
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}
