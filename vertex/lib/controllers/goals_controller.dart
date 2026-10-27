import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants/app_colors.dart';
import '../models/goal_model.dart';
import 'dashboard_controller.dart';
import 'platform_controller.dart';

class GoalsController extends GetxController {
  final _box = GetStorage();
  var goals = <GoalModel>[].obs;

  var targetRating = 1400.obs;
  var targetPlatform = 'Codeforces'.obs;

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  void loadGoals() {
    final rawRating = _box.read('targetRating');
    final rawPlat = _box.read('targetPlatform');
    if (rawRating is int) targetRating.value = rawRating;
    if (rawPlat is String) targetPlatform.value = rawPlat;

    final rawGoals = _box.read<List>('custom_goals');
    if (rawGoals != null) {
      goals.assignAll(
        rawGoals.map((g) => GoalModel.fromJson(Map<String, dynamic>.from(g))).toList(),
      );
    } else {
      // Default starting DP sprint
      goals.assignAll([
        GoalModel(
          id: 'default_dp_sprint',
          title: 'Master DP Transitions',
          type: GoalType.topicSprint,
          platform: 'All Platforms',
          targetValue: 10,
          topicTag: 'dp',
          startDate: DateTime.now(),
          deadline: DateTime.now().add(const Duration(days: 14)),
          onlyCountFromStart: true,
        ),
      ]);
      saveGoals();
    }
  }

  void saveGoals() {
    _box.write('targetRating', targetRating.value);
    _box.write('targetPlatform', targetPlatform.value);
    _box.write('custom_goals', goals.map((g) => g.toJson()).toList());
  }

  void updateRatingTarget(int newRating, String platform) {
    targetRating.value = newRating;
    targetPlatform.value = platform;
    saveGoals();
  }

  void addGoal({
    required String title,
    required GoalType type,
    required String platform,
    required int targetValue,
    String? topicTag,
    DateTime? deadline,
    bool onlyCountFromStart = true,
  }) {
    final newGoal = GoalModel(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: type,
      platform: platform,
      targetValue: targetValue,
      topicTag: topicTag,
      startDate: DateTime.now(),
      deadline: deadline,
      onlyCountFromStart: onlyCountFromStart,
    );

    goals.add(newGoal);
    saveGoals();
    Get.snackbar(
      "Goal Created",
      "Goal '$title' activated and monitoring new solves.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.surfaceElevated,
      colorText: AppColors.primaryGreen,
    );
  }

  void deleteGoal(String id) {
    goals.removeWhere((g) => g.id == id);
    saveGoals();
  }

  /// Map friendly platform names to submission platform codes
  String _normalizePlatform(String name) {
    switch (name.toLowerCase()) {
      case 'codeforces':
      case 'cf':
        return 'CF';
      case 'leetcode':
      case 'lc':
        return 'LC';
      case 'codechef':
      case 'cc':
        return 'CC';
      case 'atcoder':
      case 'ac':
        return 'AC';
      default:
        return 'ALL';
    }
  }

  int getProgress(GoalModel goal) {
    try {
      final dash = Get.find<DashboardController>();

      if (goal.type == GoalType.dailySolves) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        return dash.allSubmissions.where((s) => s.solvedAt.isAfter(todayStart)).length;
      }

      if (goal.type == GoalType.topicSprint) {
        final tag = goal.topicTag?.toLowerCase() ?? '';
        final targetCode = _normalizePlatform(goal.platform);

        return dash.allSubmissions.where((sub) {
          // 1. Platform check
          if (targetCode != 'ALL' && sub.platform != targetCode) return false;

          // 2. Tag match check
          final matchesTag = tag.isEmpty ||
              sub.tags.any((t) => t.toLowerCase().contains(tag)) ||
              sub.problemName.toLowerCase().contains(tag);
          if (!matchesTag) return false;

          // 3. Time anchor check: exclude solves before sprint creation
          if (goal.onlyCountFromStart && sub.solvedAt.isBefore(goal.startDate)) {
            return false;
          }

          // 4. Deadline cutoff
          if (goal.deadline != null && sub.solvedAt.isAfter(goal.deadline!)) {
            return false;
          }

          return true;
        }).length;
      }
    } catch (_) {}

    return 0;
  }
}