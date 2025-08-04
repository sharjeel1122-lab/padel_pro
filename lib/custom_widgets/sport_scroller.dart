import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:padel_pro/screens/user/views/user_allclub_screen.dart';
import '../../../controllers/sport_controller.dart';


class SportScroller extends StatelessWidget {
  final SportController sportCtrl = Get.find();

  final sports = ['Padel', 'Football', 'Cricket', 'Badminton', 'Volleyball'];
  final sportIcons = [
    'assets/padel.jpg',
    'assets/footal.jpg',
    'assets/cricket.jpeg',
    'assets/badmiton.jpg',
    'assets/volleyball.jpeg',
  ];

  SportScroller({super.key});

  void _handleSportTap(int index, BuildContext context) {
    sportCtrl.selectSport(index);

    if (sports[index] == 'Padel') {
      Get.to(() => UserClubScreen());
    } else {
      _showComingSoonDialog(context, sports[index]);
    }
  }

  void _showComingSoonDialog(BuildContext context, String sportName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF072A40).withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.sports,
                    size: 40.w,
                    color: const Color(0xFF072A40),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                '$sportName Coming Soon!',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF072A40),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'We are working hard to bring $sportName grounds to you. Stay tuned!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20.h),
              // Confetti button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF072A40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 12.h,
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Got It!',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ground for',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {Get.to(UserClubScreen());},
                child: Text(
                  'See All',
                  style: TextStyle(color: const Color(0xFF072A40)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sports.length,
            itemBuilder: (context, idx) {
              return Obx(() {
                final selected = sportCtrl.selectedSport.value == idx;
                return GestureDetector(
                  onTap: () => _handleSportTap(idx, context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: 5.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: selected
                          ? const Color(0xFF072A40).withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    padding: EdgeInsets.all(5.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: selected
                              ? const Color(0xFF072A40).withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          backgroundImage: AssetImage(sportIcons[idx]),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          sports[idx],
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selected
                                ? const Color(0xFF072A40)
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}


// // ignore_for_file: deprecated_member_use
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import '../../../controllers/sport_controller.dart';
//
// class SportScroller extends StatelessWidget {
//   final SportController sportCtrl = Get.find();
//
//   final sports = ['Padel', 'Football', 'Cricket', 'Badminton', 'Volleyball'];
//   final sportIcons = [
//     'assets/padel.jpg',
//     'assets/footal.jpg',
//     'assets/cricket.jpeg',
//     'assets/badmiton.jpg',
//     'assets/volleyball.jpeg',
//   ];
//
//   SportScroller({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 5),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Ground for',
//                 style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//               ),
//               TextButton(
//                 onPressed: () {},
//                 child: Text('See All', style: TextStyle(color: Color(0xFF072A40))),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(
//           height: 90.h,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: sports.length,
//             itemBuilder: (context, idx) {
//               return Obx(() {
//                 final selected = sportCtrl.selectedSport.value == idx;
//                 return GestureDetector(
//                   onTap: () => sportCtrl.selectSport(idx),
//                   child: AnimatedScale(
//                     scale: selected ? 1.1 : 1.0,
//                     duration: const Duration(milliseconds: 200),
//                     child: Container(
//                       width: 70.w,
//                       margin: EdgeInsets.only(right: 5.w),
//                       decoration: BoxDecoration(
//                         // shape: BoxShape.circle,
//                         // border: Border.all(
//                         //   color: selected ? Colors.green : Colors.transparent,
//                         //   width: 2,
//                         // ),
//                       ),
//                       padding: EdgeInsets.all(5.w),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CircleAvatar(
//                             radius: 24.r,
//                             backgroundColor: selected
//                                 ? Colors.green.withOpacity(0.1)
//                                 : Colors.grey.withOpacity(0.1),
//                             backgroundImage: AssetImage(sportIcons[idx]),
//                           ),
//                           SizedBox(height: 6.h),
//                           Text(
//                             sports[idx],
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               fontWeight: selected
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                               color: selected ? Color(0xFF072A40) : Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               });
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
