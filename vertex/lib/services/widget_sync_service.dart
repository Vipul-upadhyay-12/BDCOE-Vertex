import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/contest_model.dart';

class WidgetSyncService {
  static const String androidWidgetProvider = 'VertexWidgetProvider';
  static const String qualifiedAndroidName = 'com.example.vertex.VertexWidgetProvider';

  static String _formatCountdown(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return "Live Now!";
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 24) {
      return "In ${diff.inDays}d ${hours % 24}h";
    }
    return "In ${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m";
  }

  static Future<void> updateHomeScreenWidget({
    required int streakDays,
    ContestModel? nextContest,
    ContestModel? latestReminder,
  }) async {
    try {
      print("[WIDGET] Writing widget payload...");
      await HomeWidget.saveWidgetData<String>('streak_text', '🔥 $streakDays Days');

      if (nextContest != null) {
        await HomeWidget.saveWidgetData<String>('next_platform', nextContest.platform.toUpperCase());
        await HomeWidget.saveWidgetData<String>('next_name', nextContest.name);
        await HomeWidget.saveWidgetData<String>('next_countdown', _formatCountdown(nextContest.startTime));
      } else {
        await HomeWidget.saveWidgetData<String>('next_platform', 'NEXT');
        await HomeWidget.saveWidgetData<String>('next_name', 'No Upcoming Contests');
        await HomeWidget.saveWidgetData<String>('next_countdown', '--:--');
      }

      if (latestReminder != null) {
        await HomeWidget.saveWidgetData<String>('reminder_name', latestReminder.name);
        await HomeWidget.saveWidgetData<String>('reminder_countdown', _formatCountdown(latestReminder.startTime));
      } else {
        await HomeWidget.saveWidgetData<String>('reminder_name', 'No Reminder Scheduled');
        await HomeWidget.saveWidgetData<String>('reminder_countdown', '');
      }

      final result = await HomeWidget.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
        qualifiedAndroidName: qualifiedAndroidName,
      );
      print("[WIDGET] updateWidget success: $result");
    } catch (e) {
      print("[WIDGET] Error: $e");
    }
  }
}