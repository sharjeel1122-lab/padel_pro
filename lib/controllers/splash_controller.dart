import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingController extends GetxController {
  final storage = GetStorage();
  final isLastPage = false.obs;

  bool hasSeenOnboarding() {
    return storage.read('seenOnboarding') ?? false;
  }

  void markOnboardingSeen() {
    storage.write('seenOnboarding', true);
  }
}
