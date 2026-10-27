import 'package:get/get.dart';
import 'package:vertex/controllers/contest_controller.dart';
import 'package:vertex/models/contest_model.dart';
import 'package:vertex/services/widget_sync_service.dart';
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

  // Platform-specific metrics
  var cfSolvedCount = 0.obs;
  var lcSolvedCount = 0.obs;
  var lcRating = 0.obs;
  var ccRating = 0.obs;
  var ccStars = '1★'.obs;
  var ccSolvedCount = 0.obs;

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
    // Reactively refresh data whenever any handle changes
    ever(platform.savedCf, (_) => syncSubmissionsAndRatings());
    ever(platform.savedLc, (_) => syncSubmissionsAndRatings());
    ever(platform.savedCc, (_) => syncSubmissionsAndRatings());
    ever(platform.savedAc, (_) => syncSubmissionsAndRatings());
    syncSubmissionsAndRatings();
  }

  Future<void> syncSubmissionsAndRatings() async {
    isSyncing.value = true;
    print("[CPPRO] Starting full sync...");
    print(
      "[CPPRO] Handles -> CF: '${platform.savedCf.value}', "
      "LC: '${platform.savedLc.value}', "
      "CC: '${platform.savedCc.value}', "
      "AC: '${platform.savedAc.value}'",
    );

    List<SubmissionModel> aggregatedSubmissions = [];
    List<RatingPointModel> aggregatedRatings = [];
    Map<DateTime, int> externalCalendarDays = {};

    int cfCount = 0;
    int lcCount = 0;

    // 1. Codeforces
    if (platform.savedCf.value.isNotEmpty) {
      final cfData = await ApiService.fetchCodeforcesData(platform.savedCf.value);
      aggregatedSubmissions.addAll(cfData.submissions);
      aggregatedRatings.addAll(cfData.ratings);
      cfCount = cfData.submissions.length;
    }

    // 2. AtCoder
    if (platform.savedAc.value.isNotEmpty) {
      final acSubs = await ApiService.fetchAtCoderSubmissions(platform.savedAc.value);
      aggregatedSubmissions.addAll(acSubs);

      for (var sub in acSubs) {
        final day = DateTime(sub.solvedAt.year, sub.solvedAt.month, sub.solvedAt.day);
        externalCalendarDays[day] = (externalCalendarDays[day] ?? 0) + 1;
      }

      final acRatings = await ApiService.fetchAtCoderRatingHistory(platform.savedAc.value);
      aggregatedRatings.addAll(acRatings);
    }

    // 3. LeetCode
    if (platform.savedLc.value.isNotEmpty) {
      final lcData = await ApiService.fetchLeetCodeData(platform.savedLc.value);
      aggregatedSubmissions.addAll(lcData.submissions);
      aggregatedRatings.addAll(lcData.ratings);
      lcCount = lcData.submissions.length;

      final lcRatings = lcData.ratings.where((r) => r.platform == 'LC').toList();
      if (lcRatings.isNotEmpty) {
        lcRating.value = lcRatings.last.rating;
      }

      lcData.calendarMap.forEach((day, count) {
        externalCalendarDays[day] = (externalCalendarDays[day] ?? 0) + count;
      });
    }

    // 4. CodeChef
    if (platform.savedCc.value.isNotEmpty) {
      final ccData = await ApiService.fetchCodeChefData(platform.savedCc.value);
      aggregatedSubmissions.addAll(ccData.submissions);
      aggregatedRatings.addAll(ccData.ratings);
      ccSolvedCount.value = ccData.submissions.length;

      final ccRatings = ccData.ratings.where((r) => r.platform == 'CC').toList();
      if (ccRatings.isNotEmpty) {
        final r = ccRatings.last.rating;
        ccRating.value = r;

        // Calculate stars based on CodeChef rating brackets
        if (r >= 2500) {
          ccStars.value = "7★";
        } else if (r >= 2200) {
          ccStars.value = "6★";
        } else if (r >= 2000) {
          ccStars.value = "5★";
        } else if (r >= 1800) {
          ccStars.value = "4★";
        } else if (r >= 1600) {
          ccStars.value = "3★";
        } else if (r >= 1400) {
          ccStars.value = "2★";
        } else {
          ccStars.value = "1★";
        }
      }

      ccData.calendarMap.forEach((day, count) {
        externalCalendarDays[day] = (externalCalendarDays[day] ?? 0) + count;
      });
    }

    cfSolvedCount.value = cfCount;
    lcSolvedCount.value = lcCount;

    // Chronological order for problem feed (newest first)
    aggregatedSubmissions.sort((a, b) => b.solvedAt.compareTo(a.solvedAt));

    allSubmissions.assignAll(aggregatedSubmissions);
    ratingHistory.assignAll(aggregatedRatings);
    totalProblemsSolved.value = aggregatedSubmissions.length;

    _calculatePeakRating();
    _buildHeatmapDataset(externalCalendarDays);
    _computeTopics();
    _evaluateInactivityAndStreak();

    // Force reactive refresh
    allSubmissions.refresh();
    ratingHistory.refresh();
    heatmapData.refresh();

    isSyncing.value = false;
    print("[CPPRO] Full sync complete! Total submissions in feed: ${allSubmissions.length}");

    // --- HOME WIDGET LIVE UPDATE ---
    ContestModel? nextContest;
    ContestModel? nextAlarm;
    try {
      final cc = Get.find<ContestController>();
      final now = DateTime.now();

      // Next upcoming contest overall
      final upcoming = cc.allContests.where((c) => c.startTime.isAfter(now)).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      if (upcoming.isNotEmpty) nextContest = upcoming.first;

      // Next scheduled alarm
      final reminded = cc.allContests
          .where((c) => cc.activeReminderIds.contains(c.notificationId) && c.startTime.isAfter(now))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      if (reminded.isNotEmpty) nextAlarm = reminded.first;
    } catch (_) {}

    await WidgetSyncService.updateHomeScreenWidget(
      streakDays: currentStreak.value,
      nextContest: nextContest,
      latestReminder: nextAlarm,
    );
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

  void _buildHeatmapDataset(Map<DateTime, int> externalDays) {
    Map<DateTime, int> counts = {};

    externalDays.forEach((dayKey, count) {
      final adjusted = count > 1 ? count - 1 : 1;
      counts[dayKey] = adjusted;
    });

    for (var sub in allSubmissions) {
      if (sub.platform != 'LC') {
        final dayKey = DateTime(sub.solvedAt.year, sub.solvedAt.month, sub.solvedAt.day);
        counts[dayKey] = (counts[dayKey] ?? 0) + 1;
      }
    }

    counts.removeWhere((key, value) => value <= 0);
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
    if (allSubmissions.isEmpty && heatmapData.isEmpty) {
      daysInactive.value = 0;
      currentStreak.value = 0;
      return;
    }

    DateTime? latestActive;
    if (allSubmissions.isNotEmpty) {
      latestActive = allSubmissions.first.solvedAt;
    }

    if (heatmapData.isNotEmpty) {
      final latestCalendarDay = heatmapData.keys.reduce((a, b) => a.isAfter(b) ? a : b);
      if (latestActive == null || latestCalendarDay.isAfter(latestActive)) {
        latestActive = latestCalendarDay;
      }
    }

    final now = DateTime.now();
    daysInactive.value = latestActive != null ? now.difference(latestActive).inDays : 0;

    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    if (!heatmapData.containsKey(checkDate) || (heatmapData[checkDate] ?? 0) == 0) {
      final yesterday = checkDate.subtract(const Duration(days: 1));
      if (heatmapData.containsKey(yesterday) && (heatmapData[yesterday] ?? 0) > 0) {
        checkDate = yesterday;
      }
    }

    while (heatmapData.containsKey(checkDate) && (heatmapData[checkDate] ?? 0) > 0) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    currentStreak.value = streak;
  }
}