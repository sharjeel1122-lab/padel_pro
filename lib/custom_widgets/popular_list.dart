import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // kDebugMode, debugPrint
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:padel_pro/controllers/ground_controller.dart';
import 'package:padel_pro/screens/user/views/booking_screen.dart';
import 'package:padel_pro/screens/user/views/user_allclub_screen.dart';

class PopularList extends StatelessWidget {
  final GroundController groundCtrl = Get.find();

  PopularList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = groundCtrl.filteredGrounds;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Most Popular',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Get.to(UserClubScreen()),
                  child: const Text('See All', style: TextStyle(color: Color(0xFF072A40))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 260.h,
              child: items.isEmpty
                  ? Center(
                child: Text(
                  'No recommended playgrounds found',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, idx) {
                  final g = items[idx];
                  final cover = g.coverUrl; // normalized cover URL
                  final hasPrice = (g.price ?? 0) > 0;
                  final hasRating = (g.rating != null) && (g.rating > 0);

                  // DEBUG
                  if (kDebugMode) {
                    debugPrint('🖼️ [PopularList][$idx] ${g.title} coverUrl => ${cover ?? "(null)"}');
                  }

                  return GestureDetector(
                    onTap: () => _showGroundSheet(context, g),
                    child: Container(
                      width: 145.w,
                      margin: EdgeInsets.only(right: 12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cover
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: (cover != null && cover.isNotEmpty)
                                  ? CachedNetworkImage(
                                imageUrl: cover,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) {
                                  if (kDebugMode) {
                                    debugPrint('⚠️ Image load failed for ${g.title} -> $url | error: $error');
                                  }
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.park),
                                  );
                                },
                              )
                                  : Container(
                                color: Colors.grey.shade200,
                                child: const Center(child: Icon(Icons.park)),
                              ),
                            ),
                          ),

                          SizedBox(height: 8.h),

                          // Title
                          Text(
                            g.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),

                          // Subtitle (city)
                          Text(
                            g.subtitle ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),

                          SizedBox(height: 4.h),

                          // Price (optional) + Rating (optional)
                          Row(
                            children: [
                              if (hasPrice)
                                Text(
                                  '${g.price} PKR/night',
                                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                                ),

                              // small spacer only if both exist
                              if (hasPrice && hasRating) SizedBox(width: 6.w),

                              if (hasRating)
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.orange, size: 12.sp),
                                    SizedBox(width: 2.w),
                                    Text(
                                      g.rating.toString(),
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showGroundSheet(BuildContext context, dynamic g) {
    final cover = g.coverUrl as String?;
    final hasPrice = (g.price ?? 0) > 0;
    final hasRating = (g.rating != null) && (g.rating > 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.96,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 5.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),

                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: (cover != null && cover.isNotEmpty)
                        ? CachedNetworkImage(
                      imageUrl: cover,
                      height: 190.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      height: 190.h,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.park, size: 48),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Title + location
                  Text(
                    g.title ?? '',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF072A40)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    g.subtitle ?? '',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                  ),

                  SizedBox(height: 12.h),

                  // Tags row: price / rating
                  Row(
                    children: [
                      if (hasPrice)
                        _chip(
                          icon: Icons.attach_money,
                          label: '${g.price} PKR / hour',
                        ),
                      if (hasPrice && hasRating) SizedBox(width: 8.w),
                      if (hasRating)
                        _chip(
                          icon: Icons.star,
                          iconColor: Colors.orange,
                          label: g.rating.toString(),
                        ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Quick Info (you can map your ground model fields accordingly)
                  if (g.description != null && (g.description as String).isNotEmpty) ...[
                    Text(
                      'About',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      g.description,
                      style: TextStyle(fontSize: 12.5.sp, color: Colors.black87, height: 1.3),
                    ),
                    SizedBox(height: 14.h),
                  ],

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // e.g., navigate to All Clubs or open map if you store coordinates
                            Get.to(UserClubScreen());
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            side: const BorderSide(color: Color(0xFF072A40)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Explore clubs'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Get.to(() => BookingScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF072A40),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Book Now'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _chip({required IconData icon, required String label, Color? iconColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: iconColor ?? const Color(0xFF072A40)),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF072A40)),
          ),
        ],
      ),
    );
  }
}
