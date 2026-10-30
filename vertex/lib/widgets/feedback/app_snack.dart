import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';

class AppSnack {
  static void show({
    String? title,
    String? message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    SnackPosition? snackPosition,
    Color? backgroundColor,
    Color? colorText,
  }) {
    // 1. Instantly kill any active or queued snackbar so buttons never freeze
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    final Color effectiveBorderColor = isError ? AppColors.error : AppColors.primaryGreen;
    final Color effectiveTitleColor = colorText ?? Colors.white;

    Get.rawSnackbar(
      titleText: Text(
        title ?? '',
        style: TextStyle(
          color: effectiveTitleColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      messageText: Text(
        message ?? '',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
      backgroundColor: backgroundColor ?? AppColors.surfaceElevated,
      borderColor: effectiveBorderColor,
      borderWidth: 1.2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      instantInit: true,
      animationDuration: const Duration(milliseconds: 150),
      snackStyle: SnackStyle.FLOATING,
    );
  }
}