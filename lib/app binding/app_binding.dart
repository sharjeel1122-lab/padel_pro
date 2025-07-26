import 'package:get/get.dart';
import 'package:padel_pro/controllers/auth%20controllers/otp_controller.dart';
import 'package:padel_pro/controllers/auth%20controllers/vendor_signup_controller.dart';
import 'package:padel_pro/services/verify_otp_api.dart';
import '../controllers/auth controllers/auth_rolebase_controller.dart';
import '../controllers/auth controllers/user_signup_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/shop_controller.dart';
import '../controllers/sport_controller.dart';
import '../controllers/ground_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/splash_controller.dart';
import '../screens/admin/controllers/dashboard_controller.dart';
import '../screens/profile_screen/controller/profile_controller.dart';
import '../screens/vendor/vendor_auth/vendor_signup_screen.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => MainController(), fenix: true);
    Get.lazyPut(() => SportController(), fenix: true);
    Get.lazyPut(() => GroundController(), fenix: true);
    Get.lazyPut(() => ShopController(), fenix: true);
    Get.lazyPut(() => ProductController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => VendorSignUpController(), fenix: true);
    Get.lazyPut(() =>  UserSignUpController(), fenix: true);
    Get.lazyPut(() =>  OnboardingController(), fenix: true);
    Get.lazyPut(() =>   OtpController(), fenix: true);
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => AuthOtpService(), fenix: true);

  }
}