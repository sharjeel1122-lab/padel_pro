//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get_storage/get_storage.dart';
// import 'app binding/app_binding.dart';
// import 'app routes/app_pages.dart';
// import 'app routes/app_routes.dart';
//
//
// void main() async {
//   await GetStorage.init();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       builder: (context, _) => GetMaterialApp(
//         debugShowCheckedModeBanner: false,
//         initialRoute: AppRoutes.INITIAL,
//         getPages: AppPages.routes,
//         initialBinding: AppBindings(),
//       ),
//     );
//   }
// }
//
//
//
//
//
//


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_app_minimizer_plus/flutter_app_minimizer_plus.dart';
import 'package:padel_pro/controllers/auth%20controllers/auth_rolebase_controller.dart';

import 'app binding/app_binding.dart';
import 'app routes/app_pages.dart';
import 'app routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(AuthController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.INITIAL,
        getPages: AppPages.routes,
        initialBinding: AppBindings(),

        // ADDED ↓ Global back-handler: root par back = MINIMIZE
        navigatorKey: Get.key,
        builder: (context, child) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) return; // child route ne pop kar diya
              final nav = Get.key.currentState;
              if (nav?.canPop() == true) {
                nav!.pop(); // inner page: normal back
              } else {
                FlutterAppMinimizerPlus.minimizeApp();
              }
            },
            child: child!,
          );
        },
      ),
    );
  }
}
