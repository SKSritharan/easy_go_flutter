import 'package:get/get.dart';

import '../controller/driver_home_controller.dart';

class DriverHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DriverHomeController());
  }
}
