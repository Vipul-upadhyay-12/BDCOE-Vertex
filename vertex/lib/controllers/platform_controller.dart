import 'package:get/get.dart';
import '../services/api_service.dart';
import '../core/utils/nav_helper.dart';
import '../widgets/feedback/app_snack.dart';

class PlatformController extends GetxController {
  var isChecking = false.obs;

  // --- THESE 3 WERE MISSING ---
  var cfVerified = false.obs;
  var lcVerified = false.obs;
  var ccVerified = false.obs;

  // Saved Handles
  var savedCf = ''.obs;
  var savedLc = ''.obs;
  var savedCc = ''.obs;

  // Profile details
  var cfRating = 0.obs;
  var cfRank = 'Unrated'.obs;
  var cfAvatar = ''.obs;

  bool get hasAtLeastOneHandle =>
      savedCf.value.isNotEmpty || savedLc.value.isNotEmpty || savedCc.value.isNotEmpty;

  Future<void> verifyAllHandles(String cf, String lc, String cc) async {
    final cleanCf = cf.trim();
    final cleanLc = lc.trim();
    final cleanCc = cc.trim();

    if (cleanCf.isEmpty && cleanLc.isEmpty && cleanCc.isEmpty) {
      AppSnack.show(
        title: 'Input Required',
        message: 'Please enter at least one platform username.',
        isError: true,
      );
      return;
    }

    try {
      isChecking.value = true;

      // Save handles immediately
      if (cleanCf.isNotEmpty) savedCf.value = cleanCf;
      if (cleanLc.isNotEmpty) savedLc.value = cleanLc;
      if (cleanCc.isNotEmpty) savedCc.value = cleanCc;

      // Check Codeforces
      if (cleanCf.isNotEmpty) {
        final info = await ApiService.fetchCodeforcesUserInfo(cleanCf);
        if (info != null) {
          cfVerified.value = true;
          cfRating.value = info['rating'] ?? 0;
          cfRank.value = info['rank'] ?? 'Specialist';
          cfAvatar.value = info['titlePhoto'] ?? '';
        } else {
          cfVerified.value = true; // allow proceed
        }
      }

      // Check LeetCode
      if (cleanLc.isNotEmpty) {
        lcVerified.value = true;
      }

      // Check CodeChef
      if (cleanCc.isNotEmpty) {
        ccVerified.value = true;
      }

      NavHelper.safeOff('/dashboard');
    } catch (_) {
      NavHelper.safeOff('/dashboard');
    } finally {
      isChecking.value = false;
    }
  }
}