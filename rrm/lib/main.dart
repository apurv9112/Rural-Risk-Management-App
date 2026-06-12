import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rrm/dependency_injection.dart';
import 'package:rrm/device_controller.dart';
import 'package:rrm/routes/app_routes.dart';
import 'package:rrm/routes/common/common_app_pages.dart';

import 'controller.dart';
import 'utils/colors.dart';
import 'package:rrm/services/offline/sync_coordinator.dart';
import 'package:rrm/services/offline/connectivity_service.dart';
import 'package:rrm/services/offline/background_sync_manager.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init(); // ⭐ REQUIRED

  initDependencies();

  // Initialize Background Sync Infrastructure
  final coordinator = getIt<SyncCoordinator>();
  await coordinator.init(); // Recovers stale locks & runs if needed

  getIt<ConnectivityService>().init();
  getIt<BackgroundSyncManager>().init();
  getIt<BackgroundSyncManager>().registerRecoveryTask();
  Get.put(AppController());
  Get.put(DeviceController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
      theme: ThemeData(
        primarySwatch: AppColors.WHITE,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: routeRootpage,
      // initialRoute: routesignaturepage,
      getPages: AppRoutes.routes,
    );
  }
}
