import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/controllers/auth%20controllers/auth_rolebase_controller.dart';
import 'package:padel_pro/screens/notification_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/user_controller.dart';

class HomeHeader extends StatelessWidget {
   HomeHeader({super.key});
  final authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 3, right: 10),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 20.r, backgroundImage: AssetImage('assets/man.jpg')),
              SizedBox(width: 12.w),
              Expanded(
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userController.username.value,
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(userController.location.value,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey)),
                        ),
                      ],
                    ),
                  ],
                )),
              ),

              SizedBox(width: 8.w),
              _iconButton(
                icon: Icons.notifications_none,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsScreen()),
                  );
                },
              ),

              SizedBox(width: 8.w),
              _iconButton(
                icon: Icons.logout_outlined,
                onTap: () {
                  authController.logout();
                },
              ),
            ],
          ),
        ),

        // Show search field if toggled
        Obx(() => userController.isSearching.value
            ? Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
          child: TextField(
            onChanged: userController.updateSearchText,
            decoration: InputDecoration(
              hintText: "Search venue...",
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        )
            : SizedBox.shrink()),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 37.w,
      height: 37.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 20.sp, color: Colors.black),
      ),
    );
  }
}
