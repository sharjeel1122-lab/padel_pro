import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingController extends GetxController {
  final storage1 = const FlutterSecureStorage();
  final storage = GetStorage();
  final isLastPage = false.obs;
  final isLoggedIn = false.obs;

  bool hasSeenOnboarding() {
    return storage.read('seenOnboarding') ?? false;
  }
   void getIsLoggedIn() async{
    var value = await storage1.read(key: 'isLoggedIn');

    print("Check : ${value}");
    if (value != null) {
      isLoggedIn.value = value.toString() == 'true';
    }
   }

  void markOnboardingSeen() {
    storage.write('seenOnboarding', true);
  }
}
