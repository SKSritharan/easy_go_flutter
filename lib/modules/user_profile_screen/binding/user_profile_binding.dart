import 'package:get/get.dart';

import '../controller/user_profile_controller.dart';

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserProfileController());
  }
}
