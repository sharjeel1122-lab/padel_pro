import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:padel_pro/controllers/ground_controller.dart';

class PopularList extends StatelessWidget {
  final GroundController groundCtrl = Get.find();

  PopularList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Filter only recommended grounds
      final recommendedGrounds = groundCtrl.popularGrounds
          .where((g) => g.recommended)
          .toList();

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
                  onPressed: () {}, // Optional: go to full list
                  child: Text('See All', style: TextStyle(color: Color(0xFF072A40))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 260.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendedGrounds.length,
                itemBuilder: (context, idx) {
                  final g = recommendedGrounds[idx];
                  return Container(
                    width: 145.w,
                    margin: EdgeInsets.only(right: 12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.asset(
                              g.images[0],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          g.title,
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          g.subtitle,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              '${g.price} PKR/night',
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
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
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
