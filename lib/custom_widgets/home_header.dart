import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:padel_pro/controllers/auth controllers/auth_rolebase_controller.dart';
import '../screens/profile_screen/controller/profile_controller.dart';
import '../../controllers/user_controller.dart';
import 'package:padel_pro/screens/notification_screen.dart';

class HomeHeader extends StatelessWidget {
  HomeHeader({super.key});

  final authController = Get.find<AuthController>();
  // as requested
  final ProfileController _controllerProfile = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 3, right: 10),
          child: Row(
            children: [
              SizedBox(
                width: 40.r,
                height: 40.r,
                child: ClipOval(
                  child: Obx(() {
                    final dynamic p = _controllerProfile.profileData['photo'];
                    final url = (p is String) ? p.trim() : '';
                    if (url.isEmpty) return _buildDefaultAvatar();

                    final safe = _normalizeUrl(url);
                    return Image.network(
                      safe,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                      loadingBuilder: (c, child, prog) =>
                      prog == null
                          ? child
                          : const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(width: 12.w),

              // ---- Middle content must be Expanded to avoid overflow ----
              Expanded(
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_controllerProfile.isLoading.value)
                      const SizedBox(
                        height: 5,
                        child: LinearProgressIndicator(color: Colors.white),
                      )
                    else
                      Text(
                        _controllerProfile.fullName.isNotEmpty
                            ? _controllerProfile.fullName
                            : 'Name...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C1E2C),
                        ),
                      ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Obx(() => Text(
                            userController.location.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          )),
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
                    MaterialPageRoute(builder: (context) => NotificationsScreen()),
                  );
                },
              ),

              SizedBox(width: 8.w),

              _iconButton(
                icon: Icons.logout_outlined,
                onTap: () => authController.logout(),
              ),
            ],
          ),
        ),

        // Optional search box (unchanged)
        Obx(() => userController.isSearching.value
            ? Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
          child: TextField(
            onChanged: userController.updateSearchText,
            decoration: InputDecoration(
              hintText: "Search venue...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        )
            : const SizedBox.shrink()),
      ],
    );
  }

  // ---------- Helpers ----------

  Widget _buildDefaultAvatar() =>
      Image.asset('assets/man.jpg', fit: BoxFit.cover);

  String _normalizeUrl(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return s;
    s = Uri.encodeFull(s);
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    const base = 'https://padel-backend-git-main-invosegs-projects.vercel.app';
    if (s.startsWith('/')) return '$base$s';
    return '$base/$s';
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
