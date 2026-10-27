import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/contest_controller.dart';
import '../core/constants/app_colors.dart';
import '../models/contest_model.dart';
import '../widgets/navigation/app_top_bar.dart';

class ContestCalendarView extends StatelessWidget {
  const ContestCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContestController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: "Contest Calendar",
        showBack: false,
        actions: [
          IconButton(
            tooltip: "Refresh Contests",
            icon: Obx(() => controller.isLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white)),
            onPressed: () => controller.loadContests(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allContests.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        final contests = controller.filteredContests;

        return RefreshIndicator(
          color: AppColors.primaryGreen,
          backgroundColor: AppColors.surface,
          onRefresh: () => controller.loadContests(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Platform Selector Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(controller, "All Contests", "ALL"),
                          const SizedBox(width: 8),
                          _buildFilterChip(controller, "Codeforces", "CF", color: AppColors.codeforces),
                          const SizedBox(width: 8),
                          _buildFilterChip(controller, "CodeChef", "CC", color: AppColors.codeChef),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (contests.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: contests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildContestCard(context, controller, contests[index]);
                        },
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip(ContestController controller, String label, String code, {Color? color}) {
    final isSelected = controller.selectedFilter.value == code;
    final chipColor = color ?? AppColors.primaryGreen;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => controller.setFilter(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withValues(alpha: 0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildContestCard(BuildContext context, ContestController controller, ContestModel contest) {
    final isCF = contest.platform == 'CF';
    final platformColor = isCF ? AppColors.codeforces : AppColors.codeChef;
    final platformName = isCF ? "Codeforces" : "CodeChef";

    final dateStr = DateFormat('EEE, d MMM yyyy').format(contest.startTime);
    final timeStr = DateFormat('h:mm a').format(contest.startTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: contest.isLive ? AppColors.primaryGreen : AppColors.border,
          width: contest.isLive ? 1.4 : 1,
        ),
        boxShadow: contest.isLive
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: platformColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: platformColor, width: 1),
                ),
                child: Text(
                  platformName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: platformColor,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: contest.isLive
                      ? AppColors.primaryGreen.withValues(alpha: 0.15)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: contest.isLive ? AppColors.primaryGreen : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      contest.isLive ? Icons.radio_button_checked : Icons.alarm_rounded,
                      size: 13,
                      color: contest.isLive ? AppColors.primaryGreen : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      contest.timeRemainingFormatted,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: contest.isLive ? AppColors.primaryGreen : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            contest.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _detailItem(Icons.calendar_month_outlined, dateStr),
              _detailItem(Icons.access_time_rounded, timeStr),
              _detailItem(Icons.timelapse_rounded, contest.durationFormatted),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Obx(() {
                final hasReminder = controller.activeReminderIds.contains(contest.notificationId);

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => controller.toggleReminder(contest),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasReminder
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          size: 16,
                          color: hasReminder ? AppColors.primaryGreen : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasReminder ? "Reminder Set (10m)" : "Remind Me",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: hasReminder ? FontWeight.bold : FontWeight.normal,
                            color: hasReminder ? AppColors.primaryGreen : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: contest.url));
                  Get.snackbar(
                    "Link Copied",
                    "Contest link copied to clipboard",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.surfaceElevated,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
                icon: const Icon(Icons.link_rounded, size: 16, color: AppColors.primaryGreen),
                label: const Text(
                  "Copy Link",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: const [
          Icon(Icons.event_busy_rounded, size: 40, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            "No upcoming contests found for this filter.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}