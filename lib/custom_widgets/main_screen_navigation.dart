  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:padel_pro/controllers/main_controller.dart';
  import 'package:padel_pro/screens/profile_screen/user_profile_screen.dart';
  import '../screens/user/views/booking_screen.dart';
  import '../screens/home_screen.dart';
  import 'bottom_nav_bar.dart';

  class MainScreenNavigation extends StatelessWidget {
    const MainScreenNavigation({super.key});

    @override
    Widget build(BuildContext context) {
      final MainController ctrl = Get.find();

      final List<Widget> screens = [
        HomeScreen(),
        BookingScreen(),
         UserProfileScreen(),
      ];

      return Scaffold(
        backgroundColor: Colors.white,
       body:  Obx(() => screens[ctrl.selectedIndex.value]),
        bottomNavigationBar:  BottomNavBar(),
      );
    }
  }