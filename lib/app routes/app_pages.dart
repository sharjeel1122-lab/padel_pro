import 'package:get/get.dart';
import 'package:padel_pro/Error%20Screen/error_screen_otp.dart';

import 'package:padel_pro/screens/vendor/views/pending_approval_screen.dart';
import 'package:padel_pro/screens/vendor/views/vendor_dashboard.dart';
import '../screens/add_ground_screen.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/further_screens/add_vendor.dart';
import '../screens/admin/further_screens/add_venue.dart';
import '../screens/admin/requests/admin_request_screen.dart';
import '../screens/admin/total_vendors/total_vendors_screen.dart';
import '../screens/admin/total_venues/total_venues_screen.dart';
import '../screens/ground_explore_screen.dart';
import '../screens/login_screen.dart';
import '../screens/mpin screen/forget_mpin.dart';
import '../screens/mpin screen/mpin_login.dart';
import '../screens/password reset screens/reset_password_request.dart';
import '../screens/profile_screen/edit_profile_screen.dart';
import '../screens/sign_up.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/vendor/vendor_auth/vendor_signup_screen.dart';

import '../screens/verification/email_verification_screen.dart';
import '../screens/verification/verify_your_email.dart';
import '../custom_widgets/main_screen_navigation.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final routes = [

    GetPage(
      name: AppRoutes.INITIAL,
      page: () =>  MainScreenNavigation(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.USER_HOME,
      page: () => const MainScreenNavigation(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => SignUpScreen(),
    ),
    GetPage(
      name: AppRoutes.EXPLORE_GROUNDS,
      page: () => GroundExploreScreen(),
    ),
    GetPage(
      name: AppRoutes.ADD_GROUND,
      page: () => AddGroundScreen(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_DASHBOARD,
      page: () => AdminDashboardScreen(),
    ),
    // GetPage(
    //   name: AppRoutes.VENDOR_LOGIN,
    //   // page: () => VendorDashboard(),
    // ),
    GetPage(
      name: AppRoutes.VENDOR_SIGNUP,
      page: () => VendorSignUpScreen(),
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => EditProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.ADD_VENDOR,
      page: () => AddVendorScreen(),
    ),
    GetPage(
      name: AppRoutes.ADD_VENUE,
      page: () => AddVenueScreen(),
    ),
    GetPage(
      name: AppRoutes.VENDOR_DASHBOARD,
      page: () => DashboardView(),
    ),

    // GetPage(
    //   name: AppRoutes.TOTAL_VENUES,
    //   page: () => TotalVenuesScreen(),
    // ),
    GetPage(
      name: AppRoutes.TOTAL_VENDORS,
      page: () => TotalVendorsScreen(),
    ),
    GetPage(
      name: AppRoutes.REQUESTS,
      page: () => AdminRequestScreen(),
    ),
    GetPage(
      name: AppRoutes.MPIN,
      page: () => MPINLoginScreen(),
    ),
    GetPage(
      name: AppRoutes.FORGET_MPIN,
      page: () => ForgotMPINScreen(),
    ),
    GetPage(
      name: AppRoutes.RESET_PASSWORD,
      page: () => ResetPasswordRequestScreen(),
    ),

    // GetPage(
    //   name: AppRoutes.VERIFY_OTP,
    //   page: () {
    //     EmailVerificationScreen(email: email.value)
    //   },
    // ),
    GetPage(
      name: AppRoutes.VERIFY_YOUR_EMAIL,
      page: () => EmailVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.PENDING_SCREEN,
      page: () => PendingApprovalScreen(contactNumber: '03014530509'),
    ),
  ];
}