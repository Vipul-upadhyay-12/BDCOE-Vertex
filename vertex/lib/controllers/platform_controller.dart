import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';
import '../core/utils/nav_helper.dart';
import '../widgets/feedback/app_snack.dart';

class PlatformController extends GetxController {
  final GetStorage _box = GetStorage();

  var isChecking = false.obs;

  // Verification flags
  var cfVerified = false.obs;
  var lcVerified = false.obs;
  var ccVerified = false.obs;
  var acVerified = false.obs;

  // Stored handles
  var savedCf = ''.obs;
  var savedLc = ''.obs;
  var savedCc = ''.obs;
  var savedAc = ''.obs;

  // CF Metadata
  var cfRating = 0.obs;
  var cfRank = 'Unrated'.obs;
  var cfAvatar = ''.obs;

  bool get hasAtLeastOneHandle =>
      savedCf.value.isNotEmpty ||
      savedLc.value.isNotEmpty ||
      savedCc.value.isNotEmpty ||
      savedAc.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadPersistedHandles();
  }

  /// Automatically restores saved handles on app launch
  void loadPersistedHandles() {
    savedCf.value = _box.read('handle_cf') ?? '';
    savedLc.value = _box.read('handle_lc') ?? '';
    savedCc.value = _box.read('handle_cc') ?? '';
    savedAc.value = _box.read('handle_ac') ?? '';

    cfVerified.value = savedCf.value.isNotEmpty;
    lcVerified.value = savedLc.value.isNotEmpty;
    ccVerified.value = savedCc.value.isNotEmpty;
    acVerified.value = savedAc.value.isNotEmpty;

    cfRating.value = _box.read('cf_rating') ?? 0;
    cfRank.value = _box.read('cf_rank') ?? 'Unrated';
    cfAvatar.value = _box.read('cf_avatar') ?? '';
  }

  void _saveToDisk() {
    _box.write('handle_cf', savedCf.value);
    _box.write('handle_lc', savedLc.value);
    _box.write('handle_cc', savedCc.value);
    _box.write('handle_ac', savedAc.value);

    _box.write('cf_rating', cfRating.value);
    _box.write('cf_rank', cfRank.value);
    _box.write('cf_avatar', cfAvatar.value);
  }

  /// Quick save method used by settings and forms
  void saveHandles({
    required String cf,
    required String lc,
    required String cc,
    String ac = '',
  }) {
    savedCf.value = cf.trim();
    savedLc.value = lc.trim();
    savedCc.value = cc.trim();
    savedAc.value = ac.trim();

    cfVerified.value = savedCf.value.isNotEmpty;
    lcVerified.value = savedLc.value.isNotEmpty;
    ccVerified.value = savedCc.value.isNotEmpty;
    acVerified.value = savedAc.value.isNotEmpty;

    _saveToDisk();
  }

  // Link all handles initially
  Future<void> verifyAllHandles(
    String cf,
    String lc,
    String cc, [
    String ac = '',
  ]) async {
    final cleanCf = cf.trim();
    final cleanLc = lc.trim();
    final cleanCc = cc.trim();
    final cleanAc = ac.trim();

    if (cleanCf.isEmpty && cleanLc.isEmpty && cleanCc.isEmpty && cleanAc.isEmpty) {
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

      if (cleanAc.isNotEmpty) {
        savedAc.value = cleanAc;
        acVerified.value = true;
      }

      _saveToDisk();
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
        cfVerified.value = true;
        cfRating.value = (info['rating'] as num?)?.toInt() ?? 0;
        cfRank.value = info['rank'] ?? 'Unrated';
        cfAvatar.value = info['titlePhoto'] ?? '';
      }
    } else if (platform == 'LC') {
      savedLc.value = clean;
      lcVerified.value = true;
    } else if (platform == 'CC') {
      savedCc.value = clean;
      ccVerified.value = true;
    } else if (platform == 'AC') {
      savedAc.value = clean;
      acVerified.value = true;
    }

    _saveToDisk();

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
    } else if (platform == 'AC') {
      savedAc.value = '';
      acVerified.value = false;
    }

    _saveToDisk();

    AppSnack.show(
      title: 'Profile Removed',
      message: '$platform profile has been disconnected.',
    );
  }
}