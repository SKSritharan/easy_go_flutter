import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/widgets/snackbar_service.dart';

class DriverHomeController extends GetxController {
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final fromController = TextEditingController();
  final toController = TextEditingController();

  RxBool isLoading = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void onTapSetLoading() {
    isLoading.value = !isLoading.value;
  }

  void submitForm() async {
    if (formKey.currentState!.validate()) {
      onTapSetLoading();
      try {
        var user = auth.currentUser;
        CollectionReference ref = firestore.collection('buses');
        await ref.doc(user!.uid).set({
          'name': nameController.text,
          'number': numberController.text,
          'from': GeoPoint(
              double.parse(fromController.text.split(',')[0].trim()),
              double.parse(fromController.text.split(',')[1].trim())),
          'to': GeoPoint(double.parse(toController.text.split(',')[0].trim()),
              double.parse(toController.text.split(',')[1].trim())),
        });
        Get.back();
        SnackbarService.showSuccess('Bus Registered Successfully!');
      } catch (e) {
        SnackbarService.showError('Register failed. Please try again later.');
      }
      onTapSetLoading();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }
}
