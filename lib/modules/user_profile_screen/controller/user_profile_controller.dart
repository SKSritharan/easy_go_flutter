import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final aboutController = TextEditingController();

  @override
  void onInit() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final userDoc = await users.doc(user!.uid).get();
    nameController.text = userDoc['name'];
    aboutController.text = userDoc['about'];
    super.onInit();
  }

  void onTapSetLoading() {
    isLoading.value = !isLoading.value;
  }

  Future<void> updateProfileData() async {
    if (formKey.currentState!.validate()) {
      onTapSetLoading();
      try {
        CollectionReference ref = firestore.collection('users');
        await ref.doc(user!.uid).update({
          'name': nameController.text,
          'about': aboutController.text,
        });
      } catch (e) {
        print(e);
      }
      onTapSetLoading();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    aboutController.dispose();
    super.dispose();
  }
}
