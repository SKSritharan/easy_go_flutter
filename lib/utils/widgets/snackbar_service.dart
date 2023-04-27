import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarService {
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
