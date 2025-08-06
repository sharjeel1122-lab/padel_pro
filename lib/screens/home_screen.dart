import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:padel_pro/controllers/user_controller.dart';
import 'package:padel_pro/custom_widgets/home_header.dart';
import 'package:padel_pro/custom_widgets/quick_menu_card_card.dart';

import '../controllers/auth controllers/auth_rolebase_controller.dart';
import '../custom_widgets/popular_list.dart';
import '../custom_widgets/promotional_banner.dart';
import '../custom_widgets/sport_scroller.dart';




class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});
   final userController = Get.put(UserController());
   final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar:  AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title:  HomeHeader(),
        toolbarHeight: 70.h,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SportScroller(),
              const SizedBox(height: 25),
              PromotionalBanner(),
              const SizedBox(height: 8),
              PopularList(),
              QuickMenuCard(
                title: "Open match",
                subtitle: "If you are looking for players at your level",
                imagePath: "assets/images/player.png",
                gradientColors: [Colors.blue.shade400, Colors.blue.shade700],
                onTap: () {
                  // Navigate or show dialog
                },
              ),
              QuickMenuCard(
                title: "Tournaments",
                subtitle: "If you are looking for players at your level",
                imagePath: "assets/images/trophy.png",
                gradientColors: [Colors.green.shade400, Colors.green.shade700],
                onTap: () {
                  // Navigate or show dialog
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
   // Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
   //   return Container(
   //     width: 37.w,
   //     height: 37.w,
   //     decoration: BoxDecoration(
   //       shape: BoxShape.circle,
   //       border: Border.all(color: Colors.grey.shade400, width: 0.5),
   //     ),
   //     child: IconButton(
   //       onPressed: onTap,
   //       icon: Icon(icon, size: 20.sp, color: Colors.black),
   //     ),
   //   );
   // }
}
