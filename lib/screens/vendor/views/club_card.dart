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
                onPressed: () => _openGallery(context),
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

  void _openGallery(BuildContext context) {
    if (imageUrls.isEmpty) {
      Get.snackbar(
        'No images',
        'This club has no photos yet.',
        backgroundColor: Color(0xFF162A3A),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gallery',
      barrierColor: Colors.black.withOpacity(0.90),
      pageBuilder: (ctx, anim1, anim2) {
        final pageController = PageController(initialPage: 0);
        int current = 0;

        return StatefulBuilder(
          builder: (ctx, setState) {
            Widget dot(bool active) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.white38,
                borderRadius: BorderRadius.circular(10),
              ),
            );

            Future<void> toPrev() async {
              if (current > 0) {
                await pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              }
            }

            Future<void> toNext() async {
              if (current < imageUrls.length - 1) {
                await pageController.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              }
            }

            return SafeArea(
              child: Stack(
                children: [
                  // Swipeable pages with pinch-to-zoom
                  PageView.builder(
                    controller: pageController,
                    itemCount: imageUrls.length,
                    onPageChanged: (i) => setState(() => current = i),
                    itemBuilder: (_, i) {
                      final url = imageUrls[i].trim();
                      return Center(
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                            loadingBuilder: (c, child, prog) {
                              if (prog == null) return child;
                              return const SizedBox(
                                width: 64,
                                height: 64,
                                child: CircularProgressIndicator(color: Colors.white),
                              );
                            },
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 64,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Close button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(ctx).pop(),
                      tooltip: 'Close',
                    ),
                  ),

                  // Left arrow
                  if (imageUrls.length > 1)
                    Positioned(
                      left: 4,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left, size: 36, color: Colors.white70),
                          onPressed: toPrev,
                        ),
                      ),
                    ),

                  // Right arrow
                  if (imageUrls.length > 1)
                    Positioned(
                      right: 4,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right, size: 36, color: Colors.white70),
                          onPressed: toNext,
                        ),
                      ),
                    ),

                  // Dots indicator
                  if (imageUrls.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imageUrls.length, (i) => dot(i == current)),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 180),
    );
  }
}
