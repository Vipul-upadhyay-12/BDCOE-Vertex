import 'package:home_widget/home_widget.dart';
import '../models/contest_model.dart';

class WidgetSyncService {
  static const String appGroupId = 'group.cppro';
  static const String androidWidgetProvider = 'CPProWidgetProvider';

  static Future<void> updateHomeScreenWidget({
    required int streakDays,
    required int solvesIn24h,
    ContestModel? nextContest,
  }) async {
    try {
      // 1. Write streak & solves data
      await HomeWidget.saveWidgetData<String>(
        'streak_text',
        '🔥 $streakDays Days',
      );
      await HomeWidget.saveWidgetData<String>(
        'solves_text',
        '$solvesIn24h Solved (24h)',
      );

      // 2. Write next contest info
      if (nextContest != null) {
        final diff = nextContest.startTime.difference(DateTime.now());
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        final countdownStr = diff.isNegative
            ? "Live Now!"
            : "Starts in: ${hours}h ${minutes}m";

        await HomeWidget.saveWidgetData<String>(
          'contest_name',
          nextContest.name,
        );
        await HomeWidget.saveWidgetData<String>(
          'countdown_text',
          countdownStr,
        );
      } else {
        await HomeWidget.saveWidgetData<String>(
          'contest_name',
          'No Contest Alarms Set',
        );
        await HomeWidget.saveWidgetData<String>(
          'countdown_text',
          'All clear',
        );
      }

      // 3. Trigger native widget update
      await HomeWidget.updateWidget(
        name: 'VertexWidgetProvider',
        androidName: 'VertexWidgetProvider',
        qualifiedAndroidName: 'com.example.vertex.VertexWidgetProvider',
      );
    } catch (_) {}
  }
}