import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';

class UnifiedRecentSolvesCard extends StatelessWidget {
  UnifiedRecentSolvesCard({super.key});

  final dashboard = Get.find<DashboardController>();

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays}d ago";
    } else if (diff.inDays < 30) {
      return "${(diff.inDays / 7).floor()}w ago";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }

  Color _getPlatformColor(String platform) {
    if (platform == 'CF') return AppColors.codeforces;
    if (platform == 'LC') return AppColors.leetCode;
    return AppColors.codeChef;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Obx(() {
        final solves = dashboard.allSubmissions
            .where((s) => s.problemName != "Solved LeetCode Problem")
            .take(40)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Header Row (Eliminates Right Overflow)
            Row(
              children: [
                const Icon(Icons.history_rounded, color: AppColors.primaryGreen, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Recent Solved Feed",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    "${solves.length} solved",
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Scrollable Container - Native Touch Scroll Enabled
            SizedBox(
              height: 380,
              child: solves.isEmpty
                  ? const Center(
                      child: Text(
                        "No recent problems recorded.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    )
                  : RawScrollbar(
                      thumbVisibility: false,
                      thickness: 4,
                      radius: const Radius.circular(8),
                      thumbColor: AppColors.primaryGreen.withValues(alpha: 0.4),
                      child: ListView.separated(
                        // ClampingScrollPhysics allows natural scrolling inside nested SingleChildScrollView
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(right: 8),
                        itemCount: solves.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = solves[index];
                          final platformColor = _getPlatformColor(item.platform);
                          final timeStr = _formatTimeAgo(item.solvedAt);

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
                            ),
                            child: Row(
                              children: [
                                // Platform Tag Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: platformColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: platformColor, width: 1),
                                  ),
                                  child: Text(
                                    item.platform,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: platformColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Problem Title
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.problemName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Highlighted Time Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: timeStr.contains('h') || timeStr.contains('m')
                                          ? AppColors.primaryGreen.withValues(alpha: 0.5)
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Text(
                                    timeStr,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: timeStr.contains('h') || timeStr.contains('m')
                                          ? AppColors.primaryGreen
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}