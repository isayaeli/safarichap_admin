import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showErrorSnack(String message) {
  _snack("Error".tr, message, Icons.error_outline, Colors.red, 4);
}

void showSuccessSnack(String message) {
  _snack("Success".tr, message, Icons.check_circle_outline, Colors.green, 3);
}

void showInfosSnack(String message) {
  _snack("Info".tr, message, Icons.info_outline, Colors.blue, 3);
}

void _snack(
  String title,
  String message,
  IconData icon,
  Color color,
  int seconds,
) {
  if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
  GetSnackBar(
    title: title,
    message: message,
    maxWidth: 520,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    snackPosition: SnackPosition.TOP,
    duration: Duration(seconds: seconds),
    mainButton: TextButton(
      child: Text("dismiss".tr),
      onPressed: () => Get.closeCurrentSnackbar(),
    ),
    icon: Icon(size: 30, icon, color: color),
  ).show();
}
