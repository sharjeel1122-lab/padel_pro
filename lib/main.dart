import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:padel_pro/custom_widgets/main_screen_navigation.dart';
import 'package:padel_pro/screens/add_ground_screen.dart';
import 'package:padel_pro/screens/admin/controllers/dashboard_controller.dart';
import 'package:padel_pro/screens/admin/requests/admin_request_screen.dart';
import 'package:padel_pro/screens/admin/total_vendors/total_vendors_screen.dart';
import 'package:padel_pro/screens/ground_explore_screen.dart';
import 'package:padel_pro/screens/mpin%20screen/forget_mpin.dart';
import 'package:padel_pro/screens/mpin%20screen/mpin_login.dart';
import 'package:padel_pro/screens/password%20reset%20screens/reset_password_request.dart';
import 'package:padel_pro/screens/profile_screen/controller/profile_controller.dart';
import 'package:padel_pro/screens/profile_screen/edit_profile_screen.dart';
import 'package:padel_pro/screens/sign_up.dart';
import 'package:padel_pro/screens/splash/splash_screen.dart';
import 'package:padel_pro/screens/vendor/vendor_auth/vendor_signup_screen.dart';
import 'package:padel_pro/screens/vendor/vendor_court_screen.dart';
import 'package:padel_pro/screens/verification/email_verification_screen.dart';
import 'controllers/main_controller.dart';
import 'controllers/shop_controller.dart';
import 'controllers/splash_controller.dart';
import 'controllers/sport_controller.dart';
import 'controllers/ground_controller.dart';
import 'controllers/product_controller.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/further_screens/add_vendor.dart';
import 'screens/admin/further_screens/add_venue.dart';
import 'screens/admin/total_venues/total_venues_screen.dart';
import 'screens/login_screen.dart';

void main() {
  Get.put(DashboardController());
  Get.put(MainController());
  Get.put(SportController());
  Get.put(GroundController());
  Get.put(ShopController());
  Get.put(ProductController());
  Get.put(ProfileController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController onboardingController = Get.put(
      OnboardingController(),
    );
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => GetMaterialApp(
        home: onboardingController.hasSeenOnboarding()
            ? LoginScreen()
            : OnboardingScreen(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        getPages: [
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/userHome', page: () => const MainScreenNavigation()),
          GetPage(name: '/signup', page: () => SignUpScreen()),
          GetPage(name: '/explore_grounds', page: () => GroundExploreScreen()),
          GetPage(name: '/addGround', page: () => AddGroundScreen()),
          GetPage(name: '/admin-dashboard', page: () => AdminDashboardScreen()),
          GetPage(name: '/splash', page: () => OnboardingScreen()),
          GetPage(name: '/vendorLogin', page: () => VendorCourtScreen()),
          GetPage(name: '/vendorsignup', page: () => VendorSignUpScreen()),
          GetPage(name: '/editprofile', page: () => EditProfileScreen()),
          GetPage(name: '/addVendor', page: () => AddVendorScreen()),
          GetPage(name: '/addVenue', page: () => AddVenueScreen()),
          GetPage(name: '/total-venues', page: () => TotalVenuesScreen()),
          GetPage(name: '/total-vendors', page: () => TotalVendorsScreen()),
          GetPage(name: '/requests', page: () => AdminRequestScreen()),
          GetPage(name: '/mpin', page: () => MPINLoginScreen()),
          GetPage(name: '/forget-mpin', page: () => ForgotMPINScreen()),
          GetPage(name: '/reset-password', page: () => ResetPasswordRequestScreen()),
          GetPage(name: '/verify-otp', page: () => EmailVerificationScreen()),
        ],
      ),
    );
  }
}
