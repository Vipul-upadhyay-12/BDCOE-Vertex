import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/platform_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/nav_helper.dart';

class ProfileDrawer extends StatelessWidget {
  ProfileDrawer({super.key});

  final platform = Get.find<PlatformController>();
  final dashboard = Get.find<DashboardController>();
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                        ),
                        child: const Icon(Icons.terminal_rounded,
                            color: AppColors.primaryGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "CPPRO",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Connected Profiles",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Profile List Cards
            Expanded(
              child: Obx(() => ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _profileTile(
                        platform: "Codeforces",
                        handle: platform.savedCf.value,
                        accentColor: AppColors.codeforces,
                        icon: Icons.bar_chart_rounded,
                      ),
                      const SizedBox(height: 10),
                      _profileTile(
                        platform: "LeetCode",
                        handle: platform.savedLc.value,
                        accentColor: AppColors.leetCode,
                        icon: Icons.code_rounded,
                      ),
                      const SizedBox(height: 10),
                      _profileTile(
                        platform: "CodeChef",
                        handle: platform.savedCc.value,
                        accentColor: AppColors.codeChef,
                        icon: Icons.restaurant_menu_rounded,
                      ),
                      const SizedBox(height: 24),

                      // Re-link / Edit Button
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close drawer
                          Get.toNamed('/link-handles');
                        },
                        icon: const Icon(Icons.edit_rounded,
                            color: AppColors.primaryGreen, size: 18),
                        label: const Text(
                          "Manage / Edit Handles",
                          style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Force Sync Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          dashboard.syncSubmissionsAndRatings();
                        },
                        icon: const Icon(Icons.sync_rounded,
                            color: Colors.black, size: 18),
                        label: const Text(
                          "Force Sync All Data",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  )),
            ),

            // Bottom Logout Tile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text(
                  "Log Out",
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w600),
                ),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(context);
                  auth.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTile({
    required String platform,
    required String handle,
    required Color accentColor,
    required IconData icon,
  }) {
    final bool isLinked = handle.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLinked ? accentColor.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                platform,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                isLinked ? handle : "Not linked",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isLinked ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            isLinked ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
            color: isLinked ? AppColors.primaryGreen : AppColors.textSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }
}