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
import 'package:get_storage/get_storage.dart';
import 'core/database/app_database.dart';
import 'core/storage/folder_manager.dart';
import 'core/sync/background_sync_manager.dart';
import 'core/sync/foreground_sync_service.dart';
import 'core/master_data/master_data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init(); // ⭐ REQUIRED

  await getTemporaryDirectory();
  await AppDatabase.instance.database; // Initialize SQLite database
  await MasterDataSeeder.seedIfNeeded(); // Seed static lookup data if needed
  await FolderManager.initializeStructure(); // Initialize Offline Folders
  await BackgroundSyncManager.initialize(); // Initialize M9 Workmanager
  await ForegroundSyncService.initialize(); // Initialize M9 Foreground Service

  getIt.registerLazySingleton<FormValidations>(() => FormValidations());
  getIt.registerLazySingleton<SnackbarHelper>(() => SnackbarHelper());
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
