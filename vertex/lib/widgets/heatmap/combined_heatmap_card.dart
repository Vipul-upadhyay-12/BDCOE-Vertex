import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';

class CombinedHeatmapCard extends StatelessWidget {
  CombinedHeatmapCard({super.key});

  final DashboardController controller = Get.find<DashboardController>();

  Color _getCellColor(int count) {
    if (count == 0) return const Color(0xFF161B20);
    if (count <= 2) return const Color(0xFF064E3B);
    if (count <= 4) return const Color(0xFF059669);
    if (count <= 7) return const Color(0xFF10B981);
    return AppColors.primaryGreen;
  }

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
        final heatmap = controller.heatmapData;
        final totalSolves = controller.totalProblemsSolved.value;
        final streak = controller.currentStreak.value;

        // Generate 52 weeks (364 days) leading up to today
        final today = DateTime.now();
        final days = List.generate(364, (index) {
          final d = today.subtract(Duration(days: 363 - index));
          return DateTime(d.year, d.month, d.day);
        });

        List<List<DateTime>> weeks = [];
        for (int i = 0; i < 52; i++) {
          weeks.add(days.sublist(i * 7, (i + 1) * 7));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Annual Activity Heatmap",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$totalSolves total submissions across all accounts",
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: AppColors.leetCode, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "$streak Days",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Horizontal Scrollable Container with Months and 52 Columns
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true, // Scroll to recent date on the right
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Labels Row
                  Padding(
                    padding: const EdgeInsets.only(left: 28, bottom: 6),
                    child: Row(
                      children: List.generate(12, (index) {
                        final monthDate = DateTime(today.year, today.month - 11 + index);
                        final label = DateFormat('MMM').format(monthDate);
                        return Container(
                          width: 68,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Days Grid with Left Day-of-Week Indicators
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mon / Wed / Fri column
                      Padding(
                        padding: const EdgeInsets.only(right: 8, top: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Mon", style: TextStyle(color: AppColors.textSecondary, fontSize: 9)),
                            SizedBox(height: 12),
                            Text("Wed", style: TextStyle(color: AppColors.textSecondary, fontSize: 9)),
                            SizedBox(height: 12),
                            Text("Fri", style: TextStyle(color: AppColors.textSecondary, fontSize: 9)),
                          ],
                        ),
                      ),

                      // 52 Columns of Weeks
                      Row(
                        children: weeks.map((week) {
                          return Column(
                            children: week.map((day) {
                              final count = heatmap[day] ?? 0;
                              final formatted = "${day.day} ${DateFormat('MMM yyyy').format(day)}";
                              return Tooltip(
                                message: "$formatted: $count solves",
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: _getCellColor(count),
                                    borderRadius: BorderRadius.circular(2.5),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Less", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(width: 6),
                _legendSquare(const Color(0xFF161B20)),
                _legendSquare(const Color(0xFF064E3B)),
                _legendSquare(const Color(0xFF059669)),
                _legendSquare(const Color(0xFF10B981)),
                _legendSquare(AppColors.primaryGreen),
                const SizedBox(width: 6),
                const Text("More", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _legendSquare(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }
}