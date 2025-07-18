import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:padel_pro/screens/notification_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15,left: 3,right: 10),
      child: Row(
        children: [
          CircleAvatar(radius: 20.r, backgroundImage: AssetImage('assets/man.jpg')),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Asad Ali', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text('Lahore, Pakistan', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 37.w,
            height: 37.w,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 0.5),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsScreen()));
              },
              icon: Icon(Icons.notifications_none, size: 20.sp, color: Colors.black),
            ),
          )

        ],
      ),
    );
  }
}
