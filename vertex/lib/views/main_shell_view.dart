import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vertex/views/practice_view.dart';
import '../controllers/navigation_controller.dart';
import '../core/constants/app_colors.dart';
import 'dashboard_view.dart';
import 'problem_suggestions_view.dart';
import 'contest_calendar_view.dart';
import 'goal_tracker_view.dart';

class MainShellView extends StatelessWidget {
  MainShellView({super.key});

  final nav = Get.put(NavigationController());

  final List<Widget> _pages = [
    DashboardView(),
    const PracticeView(),
    const ContestCalendarView(),
    GoalTrackerView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = nav.currentIndex.value;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1.2),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.15),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  );
                }
                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: AppColors.primaryGreen, size: 24);
                }
                return const IconThemeData(color: AppColors.textSecondary, size: 22);
              }),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => nav.changePage(index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: "Dashboard",
                ),
                NavigationDestination(
                  icon: Icon(Icons.lightbulb_outline_rounded),
                  selectedIcon: Icon(Icons.lightbulb_rounded),
                  label: "Problems",
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: "Contests",
                ),
                NavigationDestination(
                  icon: Icon(Icons.flag_outlined),
                  selectedIcon: Icon(Icons.flag_rounded),
                  label: "Goals",
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}