import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_go_v1/routes/app_routes.dart';
import 'package:easy_go_v1/utils/widgets/snackbar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool isVisible = true.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FirebaseAuth auth = FirebaseAuth.instance;

  void _onTapSetLoading() {
    isLoading.value = !isLoading.value;
  }

  void changePasswordVisibility() {
    isVisible.value = !isVisible.value;
  }

  void submitForm() async {
    if (formKey.currentState!.validate()) {
      _onTapSetLoading();

      try {
        await auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        await validateUser();
        SnackbarService.showSuccess('You have successfully Logged in.');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          SnackbarService.showError(
            'There is no user record corresponding to this email address',
          );
        } else if (e.code == 'wrong-password') {
          SnackbarService.showError('The password is invalid');
        } else if (e.code == 'network-request-failed') {
          SnackbarService.showError(
              'An error occurred. Please check your internet connection and try again');
        }
      } catch (e) {
        SnackbarService.showError('Login failed. Please try again later.');
      }

      _onTapSetLoading();
    }
  }

  Future<void> validateUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('role') == "User") {
          Get.offAndToNamed(AppRoutes.userHomeScreen);
        } else {
          Get.offAndToNamed(AppRoutes.driverHomeScreen);
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }
}
