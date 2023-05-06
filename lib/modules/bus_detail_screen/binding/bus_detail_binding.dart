import 'package:get/get.dart';

import '../controller/bus_detail_controller.dart';

class BusDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BusDetailController());
  }
}
