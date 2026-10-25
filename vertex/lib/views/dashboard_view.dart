import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/platform_controller.dart';
import '../core/constants/app_colors.dart';
import '../widgets/navigation/app_top_bar.dart';
import '../widgets/dashboard/profile_drawer.dart';
import '../widgets/dashboard/inactivity_banner.dart';
import '../widgets/dashboard/profile_hero_card.dart';
import '../widgets/dashboard/quick_stats_grid.dart';
import '../widgets/heatmap/combined_heatmap_card.dart';
import '../widgets/charts/unified_rating_chart.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final dashboard = Get.put(DashboardController());
  final platform = Get.find<PlatformController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: ProfileDrawer(),
      appBar: AppTopBar(
        title: "CPPRO",
        showBack: false,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            tooltip: "Refresh Data",
            icon: Obx(() => dashboard.isSyncing.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primaryGreen),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white)),
            onPressed: () => dashboard.syncSubmissionsAndRatings(),
          ),
        ],
      ),
      body: Obx(() {
        if (dashboard.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryGreen,
          backgroundColor: AppColors.surface,
          onRefresh: () => dashboard.syncSubmissionsAndRatings(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InactivityBanner(),
                ProfileHeroCard(),
                const SizedBox(height: 14),
                QuickStatsGrid(),
                const SizedBox(height: 18),
                CombinedHeatmapCard(),
                const SizedBox(height: 18),
                UnifiedRatingChart(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}