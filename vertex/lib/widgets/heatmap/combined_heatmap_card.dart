import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';

class CombinedHeatmapCard extends StatelessWidget {
  CombinedHeatmapCard({super.key});

  final DashboardController controller = Get.find<DashboardController>();

  // Determine cell color based on problem count
  Color _getCellColor(int count) {
    if (count == 0) return const Color(0xFF161B20); // Default dark cell
    if (count <= 2) return const Color(0xFF064E3B); // Low activity
    if (count <= 4) return const Color(0xFF059669); // Medium activity
    if (count <= 7) return const Color(0xFF10B981); // High activity
    return AppColors.primaryGreen;                   // Peak activity (glow emerald)
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
        final heatmap = controller.heatmapData;
        final totalSolves = controller.totalProblemsSolved.value;
        final streak = controller.currentStreak.value;

        // Build list of past 16 weeks (112 days) for comfortable mobile horizontal scrolling
        final today = DateTime.now();
        final days = List.generate(112, (index) {
          final d = today.subtract(Duration(days: 111 - index));
          return DateTime(d.year, d.month, d.day);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & Quick Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Activity Heatmap",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$totalSolves total submissions across linked accounts",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
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
                        "$streak d",
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
            const SizedBox(height: 18),

            // Horizontal Scrollable Grid (7 rows = days of week)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true, // Start at today on the right
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: 110,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, // 7 days a week
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final count = heatmap[day] ?? 0;

                    return Tooltip(
                      message: "${day.day}/${day.month}/${day.year}: $count solves",
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getCellColor(count),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Legend Scale (Less -> More)
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}