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
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await getTemporaryDirectory();
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // 👈 App text size fixed
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        primarySwatch: AppColors.WHITE,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: routeRootpage,
      // initialRoute: routehomepage,
      // initialRoute: routefarmerdetailspage,
      // initialRoute: routecattlepage,
      getPages: AppRoutes.routes,
    );
  }
}
