import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../models/contest_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class ContestController extends GetxController {
  var isLoading = false.obs;
  var allContests = <ContestModel>[].obs;
  var selectedFilter = 'ALL'.obs; // 'ALL', 'CF', 'CC'
  var activeReminderIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    syncReminders();
    loadContests();
  }

  Future<void> syncReminders() async {
    final pending = await NotificationService().getPendingNotificationIds();
    activeReminderIds.assignAll(pending);
  }

  Future<void> loadContests() async {
    isLoading.value = true;
    final results = await ApiService.fetchUpcomingContests();
    allContests.assignAll(results);
    await syncReminders();
    isLoading.value = false;
  }

  List<ContestModel> get filteredContests {
    if (selectedFilter.value == 'ALL') return allContests;
    return allContests.where((c) => c.platform == selectedFilter.value).toList();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> toggleReminder(ContestModel contest) async {
    final notifId = contest.notificationId;

    if (activeReminderIds.contains(notifId)) {
      await NotificationService().cancelReminder(notifId);
      activeReminderIds.remove(notifId);
      Get.snackbar(
        "Reminder Removed",
        "Cancelled 10-minute alert for ${contest.name}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      final success = await NotificationService().scheduleContestReminder(
        id: notifId,
        title: contest.name,
        platform: contest.platform == 'CF' ? 'Codeforces' : 'CodeChef',
        startTime: contest.startTime,
      );

      if (success) {
        activeReminderIds.add(notifId);
        Get.snackbar(
          "Reminder Set",
          "Alarm scheduled! You will receive an alert 10 minutes before round start.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surfaceElevated,
          colorText: AppColors.primaryGreen,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Cannot Set Reminder",
          "This contest starts in less than 10 minutes or has already begun.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surfaceElevated,
          colorText: Colors.white70,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }
}