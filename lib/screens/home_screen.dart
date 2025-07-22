import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../custom_widgets/popular_list.dart';
import '../custom_widgets/promotional_banner.dart';
import '../custom_widgets/sport_scroller.dart';




class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SportScroller(),
              const SizedBox(height: 25),
              PromotionalBanner(),
              const SizedBox(height: 8),
              PopularList()
            ],
          ),
        ),
      ),
    );
  }
}
