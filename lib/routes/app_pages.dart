import 'package:get/get.dart';

import './app_routes.dart';
import '../modules/splash_screen/splash_screen.dart';
import '../modules/sign_in_screen/sign_in_screen.dart';
import '../modules/sign_up_screen/sign_up_screen.dart';
import '../modules/user_home_screen/user_home_screen.dart';
import '../modules/driver_home_screen/driver_home_screen.dart';
import '../modules/user_profile_screen/user_profile_screen.dart';
import '../modules/splash_screen/binding/splash_binding.dart';
import '../modules/sign_in_screen/binding/sign_in_binding.dart';
import '../modules/sign_up_screen/binding/sign_up_binding.dart';
import '../modules/user_home_screen/binding/user_home_binding.dart';
import '../modules/driver_home_screen/binding/driver_home_binding.dart';
import '../modules/bus_detail_screen/binding/bus_detail_binding.dart';
import '../modules/bus_detail_screen/bus_detail_screen.dart';
import '../modules/user_profile_screen/binding/user_profile_binding.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splashScreen,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.signInScreen,
      page: () => const SignInScreen(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: AppRoutes.signUpScreen,
      page: () => const SignUpScreen(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: AppRoutes.userHomeScreen,
      page: () => const UserHomeScreen(),
      binding: UserHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.driverHomeScreen,
      page: () => const DriverHomeScreen(),
      binding: DriverHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.userProfileScreen,
      page: () => const UserProfileScreen(),
      binding: UserProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.busDetailScreen,
      page: () => const BusDetailScreen(),
      binding: BusDetailBinding(),
    ),
  ];
}
