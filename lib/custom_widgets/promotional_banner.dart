import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:padel_pro/screens/user/views/user_allclub_screen.dart';

class PromotionalBanner extends StatelessWidget {
  const PromotionalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(
          image: AssetImage('assets/promo_image.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Disc up to 30%',
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text('Special Sports Day!', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: () {
                    Get.to(UserClubScreen());
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF072A40)),
                  child: Text('Book now', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          // SizedBox(width: 1.w),
          // Container(
          //   width: 90.w,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(12.r),
          //     image: DecorationImage(
          //       image: AssetImage('assets/man.jpg'),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
