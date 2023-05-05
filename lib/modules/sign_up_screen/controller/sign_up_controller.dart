import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_go_v1/routes/app_routes.dart';
import 'package:easy_go_v1/utils/widgets/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = 'User';

  RxBool isLoading = false.obs;
  RxBool isVisible = true.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void onTapSetLoading() {
    isLoading.value = !isLoading.value;
  }

  void changePasswordVisibility() {
    isVisible.value = !isVisible.value;
  }

  void submitForm() async {
    if (formKey.currentState!.validate()) {
      onTapSetLoading();

      try {
        await auth
            .createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            )
            .then(
              (value) => addUserToDataStore(),
            );
        if (selectedRole == "User") {
          Get.offAllNamed(AppRoutes.userHomeScreen);
        } else {
          Get.offAllNamed(AppRoutes.driverHomeScreen);
        }

        SnackbarService.showSuccess('Register Success!');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          SnackbarService.showError('Email is already taken');
        } else if (e.code == 'network-request-failed') {
          SnackbarService.showError(
              'An error occurred. Please check your internet connection and try again');
        }
      } catch (e) {
        SnackbarService.showError('Register failed. Please try again later.');
      }

      onTapSetLoading();
    }
  }

  void addUserToDataStore() async {
    var user = auth.currentUser;
    CollectionReference ref = firestore.collection('users');
    await ref.doc(user!.uid).set({
      'name': nameController.text,
      'email': emailController.text,
      'role': selectedRole,
      'image':
          "https://static.vecteezy.com/system/resources/previews/021/548/095/original/default-profile-picture-avatar-user-avatar-icon-person-icon-head-icon-profile-picture-icons-default-anonymous-user-male-and-female-businessman-photo-placeholder-social-network-avatar-portrait-free-vector.jpg",
      'about': "Hi there, I'm  using EasyGo.",
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
