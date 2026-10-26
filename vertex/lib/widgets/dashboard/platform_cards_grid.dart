import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/platform_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';

class PlatformCardsGrid extends StatelessWidget {
  PlatformCardsGrid({super.key});

  final platform = Get.find<PlatformController>();
  final dashboard = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasCf = platform.savedCf.value.isNotEmpty;
      final hasLc = platform.savedLc.value.isNotEmpty;

      return Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 700;

              return Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Codeforces Profile Card
                  if (hasCf)
                    Expanded(
                      flex: isDesktop ? 1 : 0,
                      child: _buildPlatformCard(
                        platformName: "Codeforces",
                        handle: platform.savedCf.value,
                        accentColor: AppColors.codeforces,
                        icon: Icons.bar_chart_rounded,
                        badgeText: platform.cfRank.value.toUpperCase(),
                        statPrimaryLabel: "CF Rating",
                        statPrimaryValue: platform.cfRating.value > 0
                            ? "${platform.cfRating.value}"
                            : "Unrated",
                        statSecondaryLabel: "Problems Solved",
                        statSecondaryValue: "${dashboard.cfSolvedCount.value}",
                      ),
                    ),
                  if (hasCf && hasLc && isDesktop) const SizedBox(width: 14),
                  if (hasCf && hasLc && !isDesktop) const SizedBox(height: 12),

                  // 2. LeetCode Profile Card
                  if (hasLc)
                    Expanded(
                      flex: isDesktop ? 1 : 0,
                      child: _buildPlatformCard(
                        platformName: "LeetCode",
                        handle: platform.savedLc.value,
                        accentColor: AppColors.leetCode,
                        icon: Icons.code_rounded,
                        badgeText: "ACTIVE",
                        statPrimaryLabel: "Contest Rating",
                        statPrimaryValue: dashboard.lcRating.value > 0
                            ? "${dashboard.lcRating.value}"
                            : "Practicing",
                        statSecondaryLabel: "Problems Solved",
                        statSecondaryValue: "${dashboard.lcSolvedCount.value}",
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // 3. Combined Summary Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem("Total Solved", "${dashboard.totalProblemsSolved.value} Problems", AppColors.primaryGreen),
                _summaryItem("Max Peak", dashboard.peakRating.value > 0 ? "${dashboard.peakRating.value} (${dashboard.peakPlatform.value})" : "--", AppColors.codeforces),
                _summaryItem("Current Streak", "🔥 ${dashboard.currentStreak.value} Days", AppColors.leetCode),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPlatformCard({
    required String platformName,
    required String handle,
    required Color accentColor,
    required IconData icon,
    required String badgeText,
    required String statPrimaryLabel,
    required String statPrimaryValue,
    required String statSecondaryLabel,
    required String statSecondaryValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 14,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platformName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accentColor, width: 1),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),

          // Two Stat Columns
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statPrimaryLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      statPrimaryValue,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statPrimaryValue.contains(RegExp(r'\d')) ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statSecondaryLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      statSecondaryValue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, String val, Color highlight) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: highlight)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}