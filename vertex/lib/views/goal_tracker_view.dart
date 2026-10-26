import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/navigation/app_top_bar.dart';

class GoalTrackerView extends StatelessWidget {
  const GoalTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: "Goals & Tracker", showBack: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.codeforces.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.track_changes_rounded, color: AppColors.codeforces, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              "Goal Target & Milestones",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              "Set target ratings, daily solve counts, and milestone dates.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}