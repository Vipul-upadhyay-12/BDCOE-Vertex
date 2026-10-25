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
    if (rating >= 2400) return const Color(0xFFFF0000); // Red
    if (rating >= 2100) return const Color(0xFFFF8C00); // Orange
    if (rating >= 1900) return const Color(0xFFAA00AA); // Violet
    if (rating >= 1600) return const Color(0xFF0055FF); // Blue
    if (rating >= 1400) return const Color(0xFF03A89E); // Cyan
    if (rating >= 1200) return const Color(0xFF008000); // Green
    return const Color(0xFF808080);                     // Gray (Newbie)
  }

  String _cleanAvatarUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('//')) return 'https:$url';
    if (!url.startsWith('http')) return 'https://$url';
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final handle = platform.savedCf.value.isNotEmpty
          ? platform.savedCf.value
          : (platform.savedLc.value.isNotEmpty ? platform.savedLc.value : "Coder");
      final rating = platform.cfRating.value;
      final rank = platform.cfRank.value;
      final avatarUrl = _cleanAvatarUrl(platform.cfAvatar.value);

      // Check if user has uploaded a custom image or if it's default
      final bool hasRealAvatar = avatarUrl.isNotEmpty &&
          !avatarUrl.contains('no-title.jpg') &&
          !avatarUrl.contains('no-avatar.jpg');

      final rankColor = _getRankColor(rating);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.greenGlow,
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar Container with Fallback Initials
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.greenGlow, blurRadius: 10, spreadRadius: 1),
                ],
              ),
              child: ClipOval(
                child: hasRealAvatar
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitials(handle),
                      )
                    : _buildInitials(handle),
              ),
            ),
            const SizedBox(width: 16),

            // Profile Data
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        handle,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: rankColor, width: 1),
                        ),
                        child: Text(
                          rank.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: rankColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("CF Rating: ",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(
                        rating > 0 ? "$rating" : "--",
                        style: TextStyle(
                          color: rating > 0 ? rankColor : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text("Streak: ",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(
                        "🔥 ${dashboard.currentStreak.value}d",
                        style: const TextStyle(
                          color: AppColors.leetCode,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text("Max Rating: ",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(
                        dashboard.peakRating.value > 0 ? "${dashboard.peakRating.value}" : "--",
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
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

  Widget _buildInitials(String handle) {
    final initials = handle.length >= 2 ? handle.substring(0, 2).toUpperCase() : "CP";
    return Container(
      color: AppColors.surfaceElevated,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primaryGreen,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}