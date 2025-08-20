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
                onPressed: () {
                  _openImageGallery(context);
                },
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

  void _openImageGallery(BuildContext context) {
    if (imageUrls.isEmpty) {
      Get.snackbar(
        'Photos',
        'No photos available for this club',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }

    final pageController = PageController();
    int current = 0;

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) {
          final canPrev = current > 0;
          final canNext = current < imageUrls.length - 1;

          return Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: SafeArea(
              child: Stack(
                children: [
                  // Image pager
                  Positioned.fill(
                    child: PageView.builder(
                      controller: pageController,
                      onPageChanged: (i) => setState(() => current = i),
                      itemCount: imageUrls.length,
                      itemBuilder: (_, i) {
                        final url = imageUrls[i];
                        return InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 4,
                          child: Center(
                            child: Image.network(
                              url,
                              fit: BoxFit.contain,
                              loadingBuilder: (c, w, p) {
                                if (p == null) return w;
                                return const Center(
                                  child: CircularProgressIndicator(color: Colors.grey),
                                );
                              },
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white54,
                                size: 64,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Top bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black87,
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.close, color: Colors.white70),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$name  (${current + 1}/${imageUrls.length})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Left chevron
                  if (imageUrls.length > 1 && canPrev)
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            pageController.previousPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.chevron_left, size: 28, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                  // Right chevron
                  if (imageUrls.length > 1 && canNext)
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.chevron_right, size: 28, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                  // Bottom thumbnails
                  if (imageUrls.length > 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black87,
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(imageUrls.length, (i) {
                              final url = imageUrls[i];
                              final selected = i == current;
                              return GestureDetector(
                                onTap: () => pageController.animateToPage(
                                  i,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: 70,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selected ? Colors.white : Colors.white30,
                                      width: selected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (c, w, p) {
                                        if (p == null) return w;
                                        return const Center(
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.white10,
                                        child: const Icon(Icons.broken_image, color: Colors.white54),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: true,
    ).whenComplete(() => pageController.dispose());
  }
}
