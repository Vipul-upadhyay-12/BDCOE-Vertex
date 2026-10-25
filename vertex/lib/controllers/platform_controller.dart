// lib/controllers/platform_controller.dart
import 'package:get/get.dart';
import '../services/api_service.dart';

class PlatformController extends GetxController {
  var isChecking = false.obs;

  var cfVerified = false.obs;
  var lcVerified = false.obs;
  var ccVerified = false.obs;

  var savedCf = ''.obs;
  var savedLc = ''.obs;
  var savedCc = ''.obs;

  // Helper check: has the user linked at least 1 handle?
  bool get hasAtLeastOneHandle => 
      savedCf.value.isNotEmpty || savedLc.value.isNotEmpty || savedCc.value.isNotEmpty;

  Future<void> verifyAllHandles(String cf, String lc, String cc) async {
    final cleanCf = cf.trim();
    final cleanLc = lc.trim();
    final cleanCc = cc.trim();

    if (cleanCf.isEmpty && cleanLc.isEmpty && cleanCc.isEmpty) {
      Get.snackbar('Input Required', 'Please enter at least one platform username.');
      return;
    }

    isChecking.value = true;

    // Reset status
    cfVerified.value = false;
    lcVerified.value = false;
    ccVerified.value = false;

    // 1. Check Codeforces if entered
    if (cleanCf.isNotEmpty) {
      cfVerified.value = await ApiService.checkCodeforces(cleanCf);
      if (cfVerified.value) savedCf.value = cleanCf;
    }

    // 2. Check LeetCode if entered
    if (cleanLc.isNotEmpty) {
      lcVerified.value = await ApiService.checkLeetCode(cleanLc);
      if (lcVerified.value) savedLc.value = cleanLc;
    }

    // 3. Check CodeChef if entered
    if (cleanCc.isNotEmpty) {
      ccVerified.value = await ApiService.checkCodeChef(cleanCc);
      if (ccVerified.value) savedCc.value = cleanCc;
    }

    isChecking.value = false;

    // Check if any handle that was entered failed
    bool anyEnteredFailed = 
        (cleanCf.isNotEmpty && !cfVerified.value) ||
        (cleanLc.isNotEmpty && !lcVerified.value) ||
        (cleanCc.isNotEmpty && !ccVerified.value);

    if (anyEnteredFailed) {
      Get.snackbar(
        'Verification Warning', 
        'Some entered handles could not be found. Check spelling or leave them blank.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Success if at least one handle is saved
    if (hasAtLeastOneHandle) {
      Get.offNamed('/dashboard');
    }
  }
}