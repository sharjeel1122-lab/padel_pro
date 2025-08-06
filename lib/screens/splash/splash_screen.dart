// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/controllers/splash_controller.dart';
import 'package:padel_pro/screens/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';



class OnboardingScreen extends StatelessWidget {
  final PageController _pageController = PageController();
  final OnboardingController controller = Get.find();

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/start.png",
      "title": "Flexible Dates, Instant Confirmation",
      "subtitle": "Choose your travel dates with ease and receive instant confirmation on room availability."
    },
    {
      "image": "assets/start2.png",
      "title": "Global Accessibility",
      "subtitle": "Traveling abroad? No worries. Our app supports multiple languages and currencies"
    },
    {
      "image": "assets/start3.png",
      "title": "Safe and Secure",
      "subtitle": "Rest assured, your payment information is safe with us."
    },
  ];

  OnboardingScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // No SafeArea here
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              controller.isLastPage.value = index == onboardingData.length - 1;
            },
            itemBuilder: (_, index) {
              final data = onboardingData[index];
              return Stack(
                fit: StackFit.expand,
                children: [

                  Positioned.fill(
                    child: Image.asset(
                      data['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Dark overlay
                  Container(color: Colors.black.withOpacity(0.4)),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            textAlign: TextAlign.center,
                            data['title']!,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            textAlign: TextAlign.center,
                            data['subtitle']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 150),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: onboardingData.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Colors.white,
                    dotHeight: 8,
                    dotWidth: 15,
                  ),
                ),
                SizedBox(height: 40),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff072A40),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (controller.isLastPage.value) {
                        controller.markOnboardingSeen();
                        Get.off(() => LoginScreen());
                      } else {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      controller.isLastPage.value ? "Get Started" : "Next",
                      style: TextStyle(fontSize: 16,color: Colors.white),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
