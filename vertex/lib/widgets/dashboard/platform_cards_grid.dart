import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/platform_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';

class PlatformCardsGrid extends StatelessWidget {
  PlatformCardsGrid({super.key});

  final platform = Get.find<PlatformController>();
  final dashboard = Get.find<DashboardController>();

  // Self-contained CodeChef accent color to prevent undefined getter errors in AppColors
  static const Color _codeChefColor = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasCf = platform.savedCf.value.isNotEmpty;
      final hasLc = platform.savedLc.value.isNotEmpty;
      final hasCc = platform.savedCc.value.isNotEmpty;

      // Extract CodeChef metrics dynamically from existing dashboard streams
      final ccRatings = dashboard.ratingHistory.where((r) => r.platform == 'CC').toList();
      final ccRatingVal = ccRatings.isNotEmpty ? ccRatings.last.rating : 0;
      final ccSolvedVal = dashboard.allSubmissions.where((s) => s.platform == 'CC').length;

      String ccBadge = "ACTIVE";
      if (ccRatingVal >= 2500) {
        ccBadge = "7★ DIV 1";
      } else if (ccRatingVal >= 2200) {
        ccBadge = "6★ DIV 1";
      } else if (ccRatingVal >= 2000) {
        ccBadge = "5★ DIV 1";
      } else if (ccRatingVal >= 1800) {
        ccBadge = "4★ DIV 2";
      } else if (ccRatingVal >= 1600) {
        ccBadge = "3★ DIV 2";
      } else if (ccRatingVal >= 1400) {
        ccBadge = "2★ DIV 3";
      } else if (ccRatingVal > 0) {
        ccBadge = "1★ DIV 4";
      }

      final activeCards = <Widget>[];

      // 1. Codeforces Profile Card
      if (hasCf) {
        activeCards.add(
          _buildPlatformCard(
            platformName: "Codeforces",
            handle: platform.savedCf.value,
            accentColor: AppColors.codeforces,
            icon: Icons.bar_chart_rounded,
            badgeText: platform.cfRank.value.isNotEmpty
                ? platform.cfRank.value.toUpperCase()
                : "PUPIL",
            statPrimaryLabel: "CF Rating",
            statPrimaryValue: platform.cfRating.value > 0
                ? "${platform.cfRating.value}"
                : "Unrated",
            statSecondaryLabel: "Problems Solved",
            statSecondaryValue: "${dashboard.cfSolvedCount.value}",
          ),
        );
      }

      // 2. LeetCode Profile Card
      if (hasLc) {
        activeCards.add(
          _buildPlatformCard(
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
        );
      }

      // 3. CodeChef Profile Card
      if (hasCc) {
        activeCards.add(
          _buildPlatformCard(
            platformName: "CodeChef",
            handle: platform.savedCc.value,
            accentColor: _codeChefColor,
            icon: Icons.military_tech_rounded,
            badgeText: ccBadge,
            statPrimaryLabel: "CC Rating",
            statPrimaryValue: ccRatingVal > 0 ? "$ccRatingVal" : "Active",
            statSecondaryLabel: "Contests Logged",
            statSecondaryValue: "$ccSolvedVal",
          ),
        );
      }

      return Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 750;

              if (activeCards.isEmpty) {
                return const SizedBox.shrink();
              }

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < activeCards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: activeCards[i]),
                    ],
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < activeCards.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    activeCards[i],
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 10),

          // 4. Compact Summary Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem(
                  "Total Solved",
                  "${dashboard.totalProblemsSolved.value} Problems",
                  AppColors.primaryGreen,
                ),
                _summaryItem(
                  "Max Peak",
                  dashboard.peakRating.value > 0
                      ? "${dashboard.peakRating.value} (${dashboard.peakPlatform.value})"
                      : "--",
                  AppColors.codeforces,
                ),
                _summaryItem(
                  "Current Streak",
                  "🔥 ${dashboard.currentStreak.value} Days",
                  AppColors.leetCode,
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Platform Icon + Handle + Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platformName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: accentColor, width: 0.9),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),

          // Two Stat Columns
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statPrimaryLabel,
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      statPrimaryValue,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: statPrimaryValue.contains(RegExp(r'\d'))
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statSecondaryLabel,
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      statSecondaryValue,
                      style: const TextStyle(
                        fontSize: 14.5,
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
        Text(
          val,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: highlight),
        ),
        const SizedBox(height: 1),
        Text(
          title,
          style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}