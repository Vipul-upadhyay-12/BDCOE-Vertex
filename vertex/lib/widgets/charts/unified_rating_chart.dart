import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/platform_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../models/rating_point_model.dart';

class UnifiedRatingChart extends StatelessWidget {
  UnifiedRatingChart({super.key});

  final DashboardController dashboard = Get.find<DashboardController>();
  final PlatformController platform = Get.find<PlatformController>();

  List<FlSpot> _buildSpotsForPlatform(String platformCode) {
    final list = dashboard.ratingHistory
        .where((p) => p.platform == platformCode)
        .toList();

    if (list.isEmpty) return [];

    // Sort chronologically
    list.sort((a, b) => a.date.compareTo(b.date));

    // Map index to X, rating to Y
    return List.generate(list.length, (i) {
      return FlSpot(i.toDouble(), list[i].rating.toDouble());
    });
  }

  LineChartBarData _buildLineData({
    required List<FlSpot> spots,
    required Color color,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

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
        final peakRating = dashboard.peakRating.value;
        final peakPlatform = dashboard.peakPlatform.value;

        final cfSpots = _buildSpotsForPlatform('CF');
        final lcSpots = _buildSpotsForPlatform('LC');
        final ccSpots = _buildSpotsForPlatform('CC');

        final bool hasAnyData =
            cfSpots.isNotEmpty || lcSpots.isNotEmpty || ccSpots.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Peak Milestone Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Rating History",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (peakRating > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryGreen, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.primaryGreen, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Peak: $peakRating ($peakPlatform)",
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Platform Legend Tags (Only for linked accounts)
            Row(
              children: [
                if (platform.savedCf.value.isNotEmpty)
                  _legendDot("Codeforces", AppColors.codeforces),
                if (platform.savedLc.value.isNotEmpty)
                  _legendDot("LeetCode", AppColors.leetCode),
                if (platform.savedCc.value.isNotEmpty)
                  _legendDot("CodeChef", AppColors.codeChef),
              ],
            ),
            const SizedBox(height: 20),

            // Chart Canvas
            SizedBox(
              height: 200,
              child: hasAnyData
                  ? LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 400,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: AppColors.border,
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          if (cfSpots.isNotEmpty)
                            _buildLineData(spots: cfSpots, color: AppColors.codeforces),
                          if (lcSpots.isNotEmpty)
                            _buildLineData(spots: lcSpots, color: AppColors.leetCode),
                          if (ccSpots.isNotEmpty)
                            _buildLineData(spots: ccSpots, color: AppColors.codeChef),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text(
                        "No contest rating history found yet.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _legendDot(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}