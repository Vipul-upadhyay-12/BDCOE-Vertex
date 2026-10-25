import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';

class TopicAnalyticsCard extends StatelessWidget {
  TopicAnalyticsCard({super.key});

  final dashboard = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Obx(() {
        final totalSolves = dashboard.totalProblemsSolved.value;
        final topics = dashboard.topicCounts;

        // Group difficulties (e.g. 800, 900, 1000, 1100, 1200+)
        Map<String, int> difficultyMap = {};
        for (var sub in dashboard.allSubmissions) {
          if (sub.ratingOrDifficulty != null) {
            final diff = sub.ratingOrDifficulty!;
            difficultyMap[diff] = (difficultyMap[diff] ?? 0) + 1;
          }
        }

        final sortedDiffs = difficultyMap.entries.toList()
          ..sort((a, b) => (int.tryParse(a.key) ?? 0).compareTo(int.tryParse(b.key) ?? 0));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Topic Analytics & Tags",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGreen, width: 1),
                  ),
                  child: Text(
                    "${dashboard.distinctTypesCount.value} Unique Tags",
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Difficulty Buckets Strip
            if (sortedDiffs.isNotEmpty) ...[
              const Text(
                "Solved by Rating / Difficulty",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: sortedDiffs.map((diff) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Text("${diff.key}: ",
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                          Text("${diff.value}",
                              style: const TextStyle(
                                  color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.border),
              const SizedBox(height: 14),
            ],

            // Top Topic Progress Bars (CP Info Style)
            const Text(
              "Tag Distribution & Mastery",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            if (topics.isEmpty)
              const Text("No tags recorded yet.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
            else
              Column(
                children: topics.entries.take(8).map((entry) {
                  final pct = totalSolves > 0 ? (entry.value / totalSolves) : 0.0;
                  final percentageText = "${(pct * 100).toStringAsFixed(1)}%";

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12, fontFamily: 'Inter'),
                                children: [
                                  TextSpan(
                                    text: "${entry.value} solves ",
                                    style: const TextStyle(
                                        color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "($percentageText)",
                                    style: const TextStyle(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Sleek Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceElevated,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      }),
    );
  }
}