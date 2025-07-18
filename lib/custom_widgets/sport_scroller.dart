// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ground for',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text('See All', style: TextStyle(color: Color(0xFF072A40))),
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
                  onTap: () => sportCtrl.selectSport(idx),
                  child: AnimatedScale(
                    scale: selected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 70.w,
                      margin: EdgeInsets.only(right: 5.w),
                      decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        // border: Border.all(
                        //   color: selected ? Colors.green : Colors.transparent,
                        //   width: 2,
                        // ),
                      ),
                      padding: EdgeInsets.all(5.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 24.r,
                            backgroundColor: selected
                                ? Colors.green.withOpacity(0.1)
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
                              color: selected ? Color(0xFF072A40) : Colors.black,
                            ),
                          ),
                        ],
                      ),
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
