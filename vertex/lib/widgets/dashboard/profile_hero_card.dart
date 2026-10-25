import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/platform_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';

class ProfileHeroCard extends StatelessWidget {
  ProfileHeroCard({super.key});

  final platform = Get.find<PlatformController>();
  final dashboard = Get.find<DashboardController>();

  Color _getRankColor(int rating) {
    if (rating >= 2400) return const Color(0xFFFF0000); // Grandmaster Red
    if (rating >= 2100) return const Color(0xFFFF8C00); // Master Orange
    if (rating >= 1900) return const Color(0xFFAA00AA); // Candidate Master Violet
    if (rating >= 1600) return const Color(0xFF0000FF); // Expert Blue
    if (rating >= 1400) return const Color(0xFF03A89E); // Specialist Cyan
    if (rating >= 1200) return const Color(0xFF008000); // Pupil Green
    return AppColors.textSecondary;                     // Newbie Gray
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final handle = platform.savedCf.value.isNotEmpty
          ? platform.savedCf.value
          : (platform.savedLc.value.isNotEmpty ? platform.savedLc.value : "Coder");
      final rating = platform.cfRating.value;
      final rank = platform.cfRank.value;
      final avatarUrl = platform.cfAvatar.value;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.greenGlow,
              blurRadius: 18,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with glowing neon ring
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen, width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surfaceElevated,
                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.person, color: AppColors.primaryGreen, size: 30)
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // User Handle & Rating details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        handle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Rank Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRankColor(rating).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _getRankColor(rating), width: 1),
                        ),
                        child: Text(
                          rank.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getRankColor(rating),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        "CF Rating: ",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      Text(
                        rating > 0 ? "$rating" : "Syncing...",
                        style: TextStyle(
                          color: rating > 0 ? AppColors.primaryGreen : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Streak: ",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      Text(
                        "🔥 ${dashboard.currentStreak.value}d",
                        style: const TextStyle(
                          color: AppColors.leetCode,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}