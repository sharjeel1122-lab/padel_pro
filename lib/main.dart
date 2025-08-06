
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'app binding/app_binding.dart';
import 'app routes/app_pages.dart';
import 'app routes/app_routes.dart';


void main() async {
  await GetStorage.init();
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
        initialRoute: AppRoutes.INITIAL, // Or whatever your initial route should be
        getPages: AppPages.routes,
        initialBinding: AppBindings(),
      ),
    );
  }
}






