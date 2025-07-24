import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';

class BottomNavBar extends StatelessWidget {
  final MainController ctrl = Get.find();

  BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      decoration: BoxDecoration(

        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
          currentIndex: ctrl.selectedIndex.value,
          onTap: ctrl.changeTab,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF072A40)  , // bright green
          unselectedItemColor: Color(0xFF515151),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            color: Color(0xFF072A40),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.home,size: 24,),
              ),
              label: 'Home',
            ),
            // BottomNavigationBarItem(
            //   icon: Padding(
            //     padding: EdgeInsets.all(12),
            //     child: Icon(Icons.map_outlined,size: 24),
            //   ),
            //   label: 'Shop',
            // ),
            BottomNavigationBarItem(
              icon: Padding(
                padding:  EdgeInsets.all(12),
                child: Icon(Icons.calendar_today_outlined,size: 24),
              ),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding:  EdgeInsets.all(12),
                child: Icon(Icons.person_outline,size: 24),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    ));
  }
}
