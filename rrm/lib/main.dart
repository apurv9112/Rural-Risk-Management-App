import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rrm/controller.dart';
import 'package:rrm/dependency_injection.dart';
import 'package:rrm/device_controller.dart';
import 'package:rrm/routes/app_routes.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      initialBinding: BindingsBuilder(() {
        Get.put(AppController());
        Get.put(DeviceController());
      }),

      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },

      theme: ThemeData(
        primarySwatch: AppColors.WHITE,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: routeRootpage,
      getPages: AppRoutes.routes,
    );
  }
}
