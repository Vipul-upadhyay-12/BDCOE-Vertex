import 'package:get/get.dart';
import '../models/submission_model.dart';
import '../models/rating_point_model.dart';
import '../controllers/platform_controller.dart';
import '../services/api_service.dart';

class DashboardController extends GetxController {
  final PlatformController platform = Get.find<PlatformController>();

  var isLoading = false.obs;
  var isSyncing = false.obs;

  var allSubmissions = <SubmissionModel>[].obs;
  var ratingHistory = <RatingPointModel>[].obs;
  var heatmapData = <DateTime, int>{}.obs;

  // Topic & Type counts
  var topicCounts = <String, int>{}.obs;
  var distinctTypesCount = 0.obs;

  var daysInactive = 0.obs;
  var currentStreak = 0.obs;
  var totalProblemsSolved = 0.obs;

  var peakRating = 0.obs;
  var peakPlatform = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Auto-sync whenever handles change
    ever(platform.savedCf, (_) => syncSubmissionsAndRatings());
    ever(platform.savedLc, (_) => syncSubmissionsAndRatings());
    ever(platform.savedCc, (_) => syncSubmissionsAndRatings());

    syncSubmissionsAndRatings();
  }

  Future<void> syncSubmissionsAndRatings() async {
    isSyncing.value = true;

    List<SubmissionModel> aggregatedSubmissions = [];
    List<RatingPointModel> aggregatedRatings = [];

    // 1. Codeforces
    if (platform.savedCf.value.isNotEmpty) {
      final cfData = await ApiService.fetchCodeforcesData(platform.savedCf.value);
      aggregatedSubmissions.addAll(cfData.submissions);
      aggregatedRatings.addAll(cfData.ratings);
    }

    // 2. LeetCode
    if (platform.savedLc.value.isNotEmpty) {
      final lcData = await ApiService.fetchLeetCodeData(platform.savedLc.value);
      aggregatedSubmissions.addAll(lcData.submissions);
      aggregatedRatings.addAll(lcData.ratings);
    }

    // 3. CodeChef
    if (platform.savedCc.value.isNotEmpty) {
      final ccData = await ApiService.fetchCodeChefData(platform.savedCc.value);
      aggregatedSubmissions.addAll(ccData.submissions);
      aggregatedRatings.addAll(ccData.ratings);
    }

    // STRICT SORTING: Newest solved problems first
    aggregatedSubmissions.sort((a, b) => b.solvedAt.compareTo(a.solvedAt));

    allSubmissions.assignAll(aggregatedSubmissions);
    ratingHistory.assignAll(aggregatedRatings);
    totalProblemsSolved.value = aggregatedSubmissions.length;

    _calculatePeakRating();
    _buildHeatmapDataset();
    _computeTopics();
    _evaluateInactivityAndStreak();

    isSyncing.value = false;
  }

  void _calculatePeakRating() {
    if (ratingHistory.isEmpty) {
      peakRating.value = 0;
      peakPlatform.value = '';
      return;
    }
    RatingPointModel peak = ratingHistory.reduce((curr, next) {
      return curr.rating > next.rating ? curr : next;
    });
    peakRating.value = peak.rating;
    peakPlatform.value = peak.platform;
  }

  void _buildHeatmapDataset() {
    Map<DateTime, int> counts = {};
    for (var sub in allSubmissions) {
      final dayKey = DateTime(sub.solvedAt.year, sub.solvedAt.month, sub.solvedAt.day);
      counts[dayKey] = (counts[dayKey] ?? 0) + 1;
    }
    heatmapData.assignAll(counts);
  }

  void _computeTopics() {
    Map<String, int> counts = {};
    for (var sub in allSubmissions) {
      for (var tag in sub.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topicCounts.assignAll(Map.fromEntries(sorted));
    distinctTypesCount.value = sorted.length;
  }

  void _evaluateInactivityAndStreak() {
    if (allSubmissions.isEmpty) {
      daysInactive.value = 0;
      currentStreak.value = 0;
      return;
    }

    final latestSolve = allSubmissions.first.solvedAt;
    final now = DateTime.now();

    daysInactive.value = now.difference(latestSolve).inDays;

    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    while (heatmapData.containsKey(checkDate) && heatmapData[checkDate]! > 0) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    currentStreak.value = streak;
  }
}