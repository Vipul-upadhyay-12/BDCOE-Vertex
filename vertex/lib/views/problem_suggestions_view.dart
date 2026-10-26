import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/navigation/app_top_bar.dart';

class ProblemSuggestionsView extends StatelessWidget {
  const ProblemSuggestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: "Problem Suggestions", showBack: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.psychology_rounded, color: AppColors.primaryGreen, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              "Curated Recommendations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              "Weak-topic targeted problems based on your ratings.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}