import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../screens/booking_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/shop_screen.dart';
import 'bottom_nav_bar.dart';
import 'home_header.dart';

class MainScreenNavigation extends StatelessWidget {
  const MainScreenNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController ctrl = Get.find();

    final List<Widget> screens = [
      const HomeScreen(),
      ShopScreen(),
      const BookingScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const HomeHeader(),
        toolbarHeight: 70.h,
      ),
      body: Obx(() => screens[ctrl.selectedIndex.value]),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
