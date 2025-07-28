import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:padel_pro/controllers/main_controller.dart';
import '../screens/booking_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen/profile_screen.dart';
import 'bottom_nav_bar.dart';
import 'home_header.dart';

class MainScreenNavigation extends StatelessWidget {
  const MainScreenNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController ctrl = Get.find();

    final List<Widget> screens = [
      const HomeScreen(),
      // ShopScreen(),
       BookingScreen(),
      const Profile(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: HomeHeader(),
        toolbarHeight: 70.h,
      ),
      body: Obx(() => screens[ctrl.selectedIndex.value]),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
