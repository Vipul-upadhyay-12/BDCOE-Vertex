import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/platform_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';

class ProfileDrawer extends StatelessWidget {
  ProfileDrawer({super.key});

  final platform = Get.find<PlatformController>();
  final dashboard = Get.find<DashboardController>();
  final auth = Get.find<AuthController>();

  void _showEditDialog(BuildContext context, String code, String currentHandle) {
    final textCtrl = TextEditingController(text: currentHandle);

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Edit $code Profile",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your username to fetch updated stats.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "e.g. tourist",
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onPressed: () {
                      Get.back();
                      platform.updateSingleHandle(code, textCtrl.text);
                    },
                    child: const Text("Save & Sync", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmForgetDialog(String code) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Disconnect Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to forget your $code profile? Its stats will be removed from your dashboard.",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Keep", style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onPressed: () {
                      Get.back();
                      platform.forgetProfile(code);
                    },
                    child: const Text("Disconnect", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                    ),
                    child: const Icon(Icons.terminal_rounded, color: AppColors.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text("CPPRO Profile Manager",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: Obx(() => ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _profileTile(context, "CF", "Codeforces", platform.savedCf.value, AppColors.codeforces, Icons.bar_chart_rounded),
                      const SizedBox(height: 12),
                      _profileTile(context, "LC", "LeetCode", platform.savedLc.value, AppColors.leetCode, Icons.code_rounded),
                      const SizedBox(height: 12),
                      _profileTile(context, "CC", "CodeChef", platform.savedCc.value, AppColors.codeChef, Icons.restaurant_menu_rounded),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          dashboard.syncSubmissionsAndRatings();
                        },
                        icon: const Icon(Icons.sync_rounded, color: Colors.black, size: 18),
                        label: const Text("Force Re-Sync All",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  )),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text("Log Out", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
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

  Widget _profileTile(BuildContext context, String code, String name, String handle, Color color, IconData icon) {
    final bool isLinked = handle.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLinked ? color.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(
                  isLinked ? handle : "Not Connected",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isLinked ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isLinked) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
              onPressed: () => _showEditDialog(context, code, handle),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
              onPressed: () => _confirmForgetDialog(code),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGreen, size: 20),
              onPressed: () => _showEditDialog(context, code, ""),
            ),
          ],
        ],
      ),
    );
  }
}