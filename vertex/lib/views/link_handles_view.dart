import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/platform_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../core/constants/app_colors.dart';
import '../widgets/navigation/app_top_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class LinkHandlesView extends StatelessWidget {
  const LinkHandlesView({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = Get.find<PlatformController>();
    final dashboard = Get.find<DashboardController>();

    final cfCtrl = TextEditingController(text: platform.savedCf.value);
    final lcCtrl = TextEditingController(text: platform.savedLc.value);
    final ccCtrl = TextEditingController(text: platform.savedCc.value);
    final acCtrl = TextEditingController(text: platform.savedAc.value);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: "Linked Handles", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Configure CP Profiles",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Connect your handles to sync solve histories, contest schedules, and goal roadmaps.",
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  controller: cfCtrl,
                  hint: "Codeforces Handle",
                  icon: Icons.bar_chart_rounded,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: lcCtrl,
                  hint: "LeetCode Username",
                  icon: Icons.code_rounded,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: ccCtrl,
                  hint: "CodeChef Username",
                  icon: Icons.military_tech_rounded,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: acCtrl,
                  hint: "AtCoder Handle (Optional)",
                  icon: Icons.terminal_rounded,
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  label: "Save & Resync",
                  isLoading: dashboard.isLoading.value,
                  onTap: () async {
                    platform.saveHandles(
                      cf: cfCtrl.text,
                      lc: lcCtrl.text,
                      cc: ccCtrl.text,
                      ac: acCtrl.text,
                    );
                    await dashboard.syncSubmissionsAndRatings();
                    Get.back();
                    Get.snackbar(
                      "Profiles Updated",
                      "Synced latest stats across all linked platforms",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.surfaceElevated,
                      colorText: AppColors.primaryGreen,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}