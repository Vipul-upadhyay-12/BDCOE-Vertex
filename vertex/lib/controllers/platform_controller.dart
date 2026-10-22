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

  Future<void> verifyAllHandles(String cf, String lc, String cc) async {
    if (cf.isEmpty && lc.isEmpty && cc.isEmpty) {
      Get.snackbar('Input Error', 'Enter at least one username');
      return;
    }

    isChecking.value = true;

    if (cf.isNotEmpty) {
      cfVerified.value = await ApiService.checkCodeforces(cf.trim());
      if (cfVerified.value) savedCf.value = cf.trim();
    }
    if (lc.isNotEmpty) {
      lcVerified.value = await ApiService.checkLeetCode(lc.trim());
      if (lcVerified.value) savedLc.value = lc.trim();
    }
    if (cc.isNotEmpty) {
      ccVerified.value = await ApiService.checkCodeChef(cc.trim());
      if (ccVerified.value) savedCc.value = cc.trim();
    }

    isChecking.value = false;

    // If at least one handle succeeded, move ahead
    if (cfVerified.value || lcVerified.value || ccVerified.value) {
      Get.offNamed('/dashboard');
    } else {
      Get.snackbar('Failed', 'Could not verify the entered handles.');
    }
  }
}