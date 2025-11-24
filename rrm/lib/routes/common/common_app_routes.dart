import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:rrm/pages/cattle/cattle_binding.dart';
import 'package:rrm/pages/cattle/cattle_screen.dart';
import 'package:rrm/pages/claim/claim_binding.dart';
import 'package:rrm/pages/claim/claim_sceen.dart';
import 'package:rrm/pages/data_display/data_display_binding.dart';
import 'package:rrm/pages/data_display/data_display_screen.dart';
import 'package:rrm/pages/farmer_details/farmer_details_binding.dart';
import 'package:rrm/pages/farmer_details/farmer_details_page.dart';
import 'package:rrm/pages/home/home_binding.dart';
import 'package:rrm/pages/home/home_page.dart';
import 'package:rrm/pages/kyc/kyc_binding.dart';
import 'package:rrm/pages/login/login_binding.dart';
import 'package:rrm/pages/login/login_page.dart';
import 'package:rrm/pages/splash/splash_binding.dart';
import 'package:rrm/pages/splash/splash_page.dart';
import 'package:rrm/pages/kyc/kyc_screen.dart';
import 'package:rrm/pages/tagging/tagging_binding.dart';
import 'package:rrm/pages/tagging_data_screen.dart/tagging_data_binding.dart';
import 'package:rrm/pages/tagging_data_screen.dart/tagging_data_screen.dart';
import 'package:rrm/pages/tagging/tagging_screen.dart';
import 'package:rrm/routes/common/common_app_pages.dart';

//COMMON APP ROUTE HERE

class CommonRoutes {
  static final routes = [
    GetPage(
      name: routeRootpage,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: routeLoginpage,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: routehomepage,
      page: () => const Homepage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: routetaggingpage,

      page: () => const TaggingScreen(),
      binding: TaggingBinding(),
    ),
    GetPage(
      name: routetaggingdatapage,
      page: () => const TaggingDataScreen(),
      binding: TaggingDataBinding(),
    ),
    GetPage(
      name: routekycpage,
      page: () => const KycScreen(),
      binding: KycBinding(),
    ),
    GetPage(
      name: routecattlepage,
      page: () => const Cattlescreen(),
      binding: CattleBinding(),
    ),
    GetPage(
      name: routeclaimpage,
      page: () => const ClaimScreen(),
      binding: ClaimBinding(),
    ),
    GetPage(
      name: routeDatadisplaypage,
      page: () => const Datadisplaypage(),
      binding: DatadisplayBinding(),
    ),
    GetPage(
      name: routefarmerdetailspage,
      page: () => const FarmerDetailsScreen(),
      binding: FarmerDetailsBinding(),
    ),
  ];
}
