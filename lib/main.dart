import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:padel_pro/custom_widgets/MainScreenNavigation.dart';
import 'package:padel_pro/screens/sign_up.dart';
import 'controllers/main_controller.dart';
import 'controllers/shop_controller.dart';
import 'controllers/sport_controller.dart';
import 'controllers/ground_controller.dart';
import 'controllers/product_controller.dart';

import 'screens/login_screen.dart';

void main() {
  // Inject controllers globally
  Get.put(MainController());
  Get.put(SportController());
  Get.put(GroundController());
  Get.put(ShopController());
  Get.put(ProductController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/home',
        getPages: [
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/home', page: () => const MainScreenNavigation()),
          GetPage(name: '/signup', page: ()=> SignUpScreen())
        ],
      ),
    );
  }
}
