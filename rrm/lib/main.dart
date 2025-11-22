import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/dependency_injection.dart';
import 'package:rrm/device_controller.dart';
import 'package:rrm/routes/app_routes.dart';
import 'package:rrm/routes/common/common_app_pages.dart';
import 'package:rrm/utils/validation_utils.dart';
import 'package:rrm/widgets/snackbar_widget.dart';
import 'controller.dart';
import 'utils/colors.dart';

void main() {
  getIt.registerLazySingleton<FormValidations>(() => FormValidations());
  getIt.registerLazySingleton<SnackbarHelper>(() => SnackbarHelper());
  Get.put(DeviceController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AppController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.WHITE,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // initialRoute: routeRootpage,
      initialRoute: routehomepage,
      // initialRoute: routecattlepage,
      getPages: AppRoutes.routes,
    );
  }
}
