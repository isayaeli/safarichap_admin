import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSuccessDialog({
  required String title,
  required String message,
  String? buttonText,
  VoidCallback? onPressed,
}) {
  Get.dialog(
    AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 56),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onPressed ?? () => Get.back(),
            child: Text(buttonText ?? "Done".tr),
          ),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
