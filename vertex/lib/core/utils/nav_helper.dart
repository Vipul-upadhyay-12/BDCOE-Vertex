import 'package:get/get.dart';

class NavHelper {
  /// Safely pops the current screen, ensuring no snackbar or overlay steals the pop
  static void safeBack() {
    // 1. Close open snackbars first so they don't consume Get.back()
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    // 2. Close active dialogs or bottom sheets if any are open
    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
      Get.back();
    }
    // 3. Pop the actual route
    Get.back();
  }

  /// Replaces the current page safely
  static void safeOff(String routeName, {dynamic arguments}) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.offNamed(routeName, arguments: arguments);
  }

  /// Clears the entire stack safely
  static void safeOffAll(String routeName, {dynamic arguments}) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.offAllNamed(routeName, arguments: arguments);
  }
}