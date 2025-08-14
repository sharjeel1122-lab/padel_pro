import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/controllers/ground_controller.dart';
import 'package:padel_pro/screens/ground_book_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/image_slider_controller.dart';

class GroundExploreScreen extends StatelessWidget {
  final groundCtrl = Get.find<GroundController>();
  final imageCtrl = Get.put(ImageSliderController());

  GroundExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Grounds',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: groundCtrl.updateSearch,
              decoration: InputDecoration(
                hintText: 'Search grounds...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final grounds = groundCtrl.filteredGrounds;
              if (grounds.isEmpty) {
                return const Center(child: Text('No grounds found'));
              }

              return RefreshIndicator(
                color: Colors.black,
                onRefresh: () async{
                  groundCtrl.popularGrounds;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: grounds.length,
                  itemBuilder: (context, index) {
                    final g = grounds[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.asset(g.images[0],
                                height: 160, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Ground Title with overflow handling
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      g.title,
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Responsive Small Button
                                ElevatedButton(
                                  onPressed: () {

                                    imageCtrl.currentIndex.value = 0;

                                    showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        backgroundColor: Colors.transparent, // make whole dialog transparent
                                        insetPadding: const EdgeInsets.all(16),
                                        child: Stack(
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: SizedBox(
                                                    height: 250,
                                                    width: double.infinity,
                                                    child: PageView.builder(
                                                      onPageChanged: imageCtrl.updateIndex,
                                                      itemCount: g.images.length,
                                                      itemBuilder: (_, index) {
                                                        return Image.asset(
                                                          g.images[index],
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),

                                                // 👇 Custom colored area with dots
                                                Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: const BorderRadius.vertical(
                                                      bottom: Radius.circular(16),
                                                    ),
                                                  ),
                                                  child: Obx(() {
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: List.generate(g.images.length, (index) {
                                                        return Container(
                                                          margin: const EdgeInsets.symmetric(horizontal: 3),
                                                          width: imageCtrl.currentIndex.value == index ? 10 : 6,
                                                          height: 6,
                                                          decoration: BoxDecoration(
                                                            color: imageCtrl.currentIndex.value == index
                                                                ? Colors.black
                                                                : Colors.grey,
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                        );
                                                      }),
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),

                                            // 👇 Small back button
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: CircleAvatar(
                                                radius: 15,
                                                backgroundColor: Colors.white,
                                                child: IconButton(
                                                  icon: const Icon(Icons.close, size: 15, color: Colors.black),
                                                  onPressed: () {
                                                    Get.back(); // Close dialog
                                                    Get.delete<ImageSliderController>();
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).then((_) {
                                      Get.delete<ImageSliderController>();
                                    });

                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    backgroundColor: Colors.grey.shade200,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    minimumSize: Size(0, 0),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.image, size: 14, color: Colors.black),
                                      const SizedBox(width: 4),
                                      Text(
                                        'View',
                                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(g.subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                              ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      Text('${g.price} PKR/night', style: GoogleFonts.poppins(fontSize: 14)),
                                      const Spacer(),
                                      Icon(Icons.star, color: Colors.orange, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${g.rating}', style: GoogleFonts.poppins(fontSize: 14)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => GroundBookingScreen(ground: g));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF072A40),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text('Book Now', style: GoogleFonts.poppins(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
