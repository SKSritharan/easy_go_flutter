import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_go_v1/utils/widgets/snackbar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final auth = FirebaseAuth.instance;
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () async {
      User? user = await FirebaseAuth.instance.authStateChanges().first;
      if (user == null) {
        Get.offAndToNamed(AppRoutes.signInScreen);
      } else {
        await validateUser();
      }
    });
    super.onInit();
  }

  Future<void> validateUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('role') == "User") {
          SnackbarService.showSuccess('Welcome Back');
          Get.offAndToNamed(AppRoutes.userHomeScreen);
        } else {
          SnackbarService.showSuccess('Welcome Back');
          Get.offAndToNamed(AppRoutes.driverHomeScreen);
        }
      } else {
        SnackbarService.showError(
            'Something went wrong, please try again later.');
      }
    });
  }
}
