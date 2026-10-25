import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';

class AppSnack {
  static void show({
    required String title,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Prevent duplicate stacked overlays from blocking button taps
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.surfaceElevated,
      borderColor: isError ? AppColors.error : AppColors.primaryGreen,
      borderWidth: 1.2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: duration,
      isDismissible: true,
      // Prevents the overlay from blocking background tap gestures:
      overlayBlur: 0,
      snackStyle: SnackStyle.FLOATING,
    );
  }
}