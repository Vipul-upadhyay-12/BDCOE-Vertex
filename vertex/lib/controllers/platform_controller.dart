import 'package:get/get.dart';
import '../services/api_service.dart';
import '../core/utils/nav_helper.dart';
import '../widgets/feedback/app_snack.dart';

class PlatformController extends GetxController {
  var isChecking = false.obs;

  // Verification flags
  var cfVerified = false.obs;
  var lcVerified = false.obs;
  var ccVerified = false.obs;

  // Stored handles
  var savedCf = ''.obs;
  var savedLc = ''.obs;
  var savedCc = ''.obs;

  // CF Metadata
  var cfRating = 0.obs;
  var cfRank = 'Unrated'.obs;
  var cfAvatar = ''.obs;

  bool get hasAtLeastOneHandle =>
      savedCf.value.isNotEmpty || savedLc.value.isNotEmpty || savedCc.value.isNotEmpty;

  // Link all handles initially
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

      if (cleanCf.isNotEmpty) {
        savedCf.value = cleanCf;
        final info = await ApiService.fetchCodeforcesUserInfo(cleanCf);
        if (info != null) {
          cfVerified.value = true;
          cfRating.value = (info['rating'] as num?)?.toInt() ?? 0;
          cfRank.value = info['rank'] ?? 'Unrated';
          cfAvatar.value = info['titlePhoto'] ?? '';
        }
      }

      if (cleanLc.isNotEmpty) {
        savedLc.value = cleanLc;
        lcVerified.value = true;
      }

      if (cleanCc.isNotEmpty) {
        savedCc.value = cleanCc;
        ccVerified.value = true;
      }

      NavHelper.safeOff('/dashboard');
    } catch (_) {
      NavHelper.safeOff('/dashboard');
    } finally {
      isChecking.value = false;
    }
  }

  // Update a single handle directly from Drawer
  Future<void> updateSingleHandle(String platform, String newHandle) async {
    final clean = newHandle.trim();
    if (clean.isEmpty) return;

    if (platform == 'CF') {
      savedCf.value = clean;
      final info = await ApiService.fetchCodeforcesUserInfo(clean);
      if (info != null) {
        cfRating.value = (info['rating'] as num?)?.toInt() ?? 0;
        cfRank.value = info['rank'] ?? 'Unrated';
        cfAvatar.value = info['titlePhoto'] ?? '';
      }
    } else if (platform == 'LC') {
      savedLc.value = clean;
    } else if (platform == 'CC') {
      savedCc.value = clean;
    }

    AppSnack.show(
      title: 'Profile Updated',
      message: '$platform handle updated to $clean',
    );
  }

  // Forget / Disconnect a profile completely
  void forgetProfile(String platform) {
    if (platform == 'CF') {
      savedCf.value = '';
      cfRating.value = 0;
      cfRank.value = 'Unrated';
      cfAvatar.value = '';
      cfVerified.value = false;
    } else if (platform == 'LC') {
      savedLc.value = '';
      lcVerified.value = false;
    } else if (platform == 'CC') {
      savedCc.value = '';
      ccVerified.value = false;
    }

    AppSnack.show(
      title: 'Profile Removed',
      message: '$platform profile has been disconnected.',
    );
  }
}