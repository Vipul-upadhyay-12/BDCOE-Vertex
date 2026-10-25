import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';

class QuestionTypesCard extends StatelessWidget {
  QuestionTypesCard({super.key});

  final dashboard = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Obx(() {
        final topics = dashboard.topicCounts;
        final totalTypes = dashboard.distinctTypesCount.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Topic Mastery",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen, width: 1),
                  ),
                  child: Text(
                    "$totalTypes Question Types",
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (topics.isEmpty)
              const Text(
                "No topic tags aggregated yet.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topics.entries.take(12).map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, fontFamily: 'Inter'),
                        children: [
                          TextSpan(
                            text: "${entry.key} ",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: "${entry.value}",
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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