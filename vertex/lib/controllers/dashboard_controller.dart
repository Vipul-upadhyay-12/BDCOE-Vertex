import 'package:get/get.dart';
import '../models/submission_model.dart';
import '../models/rating_point_model.dart';
import '../controllers/platform_controller.dart';
import '../services/api_service.dart';

class DashboardController extends GetxController {
  final PlatformController platform = Get.find<PlatformController>();

  // State flags
  var isLoading = false.obs;
  var isSyncing = false.obs;

  // Aggregated data collections
  var allSubmissions = <SubmissionModel>[].obs;
  var ratingHistory = <RatingPointModel>[].obs;
  var heatmapData = <DateTime, int>{}.obs; // Date -> Total Solves Count

  // Key metrics
  var daysInactive = 0.obs;
  var currentStreak = 0.obs;
  var totalProblemsSolved = 0.obs;

  // Peak milestone stats
  var peakRating = 0.obs;
  var peakPlatform = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    await syncSubmissionsAndRatings();
    isLoading.value = false;
  }

  Future<void> syncSubmissionsAndRatings() async {
    isSyncing.value = true;

    List<SubmissionModel> aggregatedSubmissions = [];
    List<RatingPointModel> aggregatedRatings = [];

    // 1. Fetch Codeforces (if linked)
    if (platform.savedCf.value.isNotEmpty) {
      final cfData = await ApiService.fetchCodeforcesData(platform.savedCf.value);
      aggregatedSubmissions.addAll(cfData.submissions);
      aggregatedRatings.addAll(cfData.ratings);
    }

    // 2. Fetch LeetCode (if linked)
    if (platform.savedLc.value.isNotEmpty) {
      final lcData = await ApiService.fetchLeetCodeData(platform.savedLc.value);
      aggregatedSubmissions.addAll(lcData.submissions);
      aggregatedRatings.addAll(lcData.ratings);
    }

    // 3. Fetch CodeChef (if linked)
    if (platform.savedCc.value.isNotEmpty) {
      final ccData = await ApiService.fetchCodeChefData(platform.savedCc.value);
      aggregatedSubmissions.addAll(ccData.submissions);
      aggregatedRatings.addAll(ccData.ratings);
    }

    // Assign reactive lists
    allSubmissions.assignAll(aggregatedSubmissions);
    ratingHistory.assignAll(aggregatedRatings);
    totalProblemsSolved.value = aggregatedSubmissions.length;

    // Process computed views
    _calculatePeakRating();
    _buildHeatmapDataset();
    _evaluateInactivityAndStreak();

    isSyncing.value = false;
  }

  // Find the single best rating achieved across all linked platforms
  void _calculatePeakRating() {
    if (ratingHistory.isEmpty) return;

    RatingPointModel peak = ratingHistory.reduce((curr, next) {
      return curr.rating > next.rating ? curr : next;
    });

    peakRating.value = peak.rating;
    peakPlatform.value = peak.platform;
  }

  // Aggregate submissions by date (stripping time) for the green chart
  void _buildHeatmapDataset() {
    Map<DateTime, int> counts = {};

    for (var sub in allSubmissions) {
      // Normalize to midnight UTC/Local so days align correctly
      final dayKey = DateTime(sub.solvedAt.year, sub.solvedAt.month, sub.solvedAt.day);
      counts[dayKey] = (counts[dayKey] ?? 0) + 1;
    }

    heatmapData.assignAll(counts);
  }

  // Inactivity logic: Checks if gap from the latest solve is >= 4 days
  void _evaluateInactivityAndStreak() {
    if (allSubmissions.isEmpty) {
      daysInactive.value = 0;
      currentStreak.value = 0;
      return;
    }

    // Sort submissions descending (newest first)
    allSubmissions.sort((a, b) => b.solvedAt.compareTo(a.solvedAt));
    final latestSolve = allSubmissions.first.solvedAt;
    final now = DateTime.now();

    final differenceInDays = now.difference(latestSolve).inDays;
    daysInactive.value = differenceInDays;

    // Streak calculation
    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    while (heatmapData.containsKey(checkDate) && heatmapData[checkDate]! > 0) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    currentStreak.value = streak;

    // Trigger 4-day inactivity alarm check
    if (daysInactive.value >= 4) {
      _triggerInactivityWarning();
    }
  }

  void _triggerInactivityWarning() {
    // Shows user feedback when app is open; background worker handles push notifications
    Get.snackbar(
      '⚠️ Inactivity Alert',
      'No submissions detected in the last ${daysInactive.value} days across your linked accounts.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }
}