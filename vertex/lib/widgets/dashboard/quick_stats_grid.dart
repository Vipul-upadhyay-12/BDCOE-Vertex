import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';

class QuickStatsGrid extends StatelessWidget {
  QuickStatsGrid({super.key});

  final dashboard = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          _buildStatCard(
            title: "Total Solved",
            value: "${dashboard.totalProblemsSolved.value}",
            icon: Icons.check_circle_outline_rounded,
            accentColor: AppColors.primaryGreen,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            title: "Peak Rating",
            value: dashboard.peakRating.value > 0 ? "${dashboard.peakRating.value}" : "--",
            icon: Icons.auto_graph_rounded,
            accentColor: AppColors.codeforces,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            title: "Active Days",
            value: "${dashboard.heatmapData.length}",
            icon: Icons.calendar_month_outlined,
            accentColor: AppColors.leetCode,
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}