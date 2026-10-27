import 'dart:math';
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

  // Map dates continuously across timeline (X = day delta from global start)
  List<FlSpot> _buildTimelineSpots(
    List<RatingPointModel> platformPoints,
    DateTime globalMinDate,
  ) {
    if (platformPoints.isEmpty) return [];

    final sorted = List<RatingPointModel>.from(platformPoints)
      ..sort((a, b) => a.date.compareTo(b.date));

    return sorted.map((p) {
      final daysDiff = p.date.difference(globalMinDate).inDays.toDouble();
      return FlSpot(daysDiff, p.rating.toDouble());
    }).toList();
  }

  LineChartBarData _buildLineData({
    required List<FlSpot> spots,
    required Color color,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: spots.length > 2,
      curveSmoothness: 0.25,
      color: color,
      barWidth: 2.2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: spots.length < 15,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 2.2,
            color: color,
            strokeWidth: 0,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.16),
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

        // 1. Gather all valid points and sort globally
        final allRatings = List<RatingPointModel>.from(dashboard.ratingHistory)
          ..sort((a, b) => a.date.compareTo(b.date));

        if (allRatings.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: Text(
                "No contest rating history found yet.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          );
        }

        final globalMinDate = allRatings.first.date;
        final globalMaxDate = allRatings.last.date;
        final totalDays = max(1, globalMaxDate.difference(globalMinDate).inDays).toDouble();

        // 2. Separate points by platform
        final cfList = allRatings.where((p) => p.platform == 'CF').toList();
        final lcList = allRatings.where((p) => p.platform == 'LC').toList();
        final ccList = allRatings.where((p) => p.platform == 'CC').toList();
        final acList = allRatings.where((p) => p.platform == 'AC').toList();

        // 3. Build time-proportional spots
        final cfSpots = _buildTimelineSpots(cfList, globalMinDate);
        final lcSpots = _buildTimelineSpots(lcList, globalMinDate);
        final ccSpots = _buildTimelineSpots(ccList, globalMinDate);
        final acSpots = _buildTimelineSpots(acList, globalMinDate);

        // 4. Calculate dynamic Y-axis bounds
        final allY = allRatings.map((p) => p.rating).toList();
        final minY = ((allY.reduce(min) - 80) ~/ 100) * 100.0;
        final maxY = ((allY.reduce(max) + 120) ~/ 100) * 100.0;

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
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.primaryGreen,
                          size: 14,
                        ),
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

            // Platform Legend Tags
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (platform.savedCf.value.isNotEmpty && cfSpots.isNotEmpty)
                  _legendDot("Codeforces", AppColors.codeforces),
                if (platform.savedCc.value.isNotEmpty && ccSpots.isNotEmpty)
                  _legendDot("CodeChef", AppColors.codeChef),
                if (platform.savedLc.value.isNotEmpty && lcSpots.isNotEmpty)
                  _legendDot("LeetCode", AppColors.leetCode),
                if (platform.savedAc.value.isNotEmpty && acSpots.isNotEmpty)
                  _legendDot("AtCoder", AppColors.atCoder),
              ],
            ),
            const SizedBox(height: 18),

            // Chart Canvas
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: totalDays,
                  minY: max(0.0, minY),
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 200,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: AppColors.border,
                      strokeWidth: 0.9,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: totalDays > 0 ? totalDays : 1,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                "${globalMinDate.month}/${globalMinDate.year}",
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          if (value >= totalDays - 1) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                "${globalMaxDate.month}/${globalMaxDate.year}",
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.surfaceElevated,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            spot.y.toInt().toString(),
                            TextStyle(
                              color: spot.bar.color ?? Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    if (cfSpots.isNotEmpty)
                      _buildLineData(spots: cfSpots, color: AppColors.codeforces),
                    if (ccSpots.isNotEmpty)
                      _buildLineData(spots: ccSpots, color: AppColors.codeChef),
                    if (lcSpots.isNotEmpty)
                      _buildLineData(spots: lcSpots, color: AppColors.leetCode),
                    if (acSpots.isNotEmpty)
                      _buildLineData(spots: acSpots, color: AppColors.atCoder),
                  ],
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
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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