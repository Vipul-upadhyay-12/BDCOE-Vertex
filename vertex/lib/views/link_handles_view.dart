import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/platform_controller.dart';
import '../core/constants/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/platform_input_card.dart';
import '../widgets/navigation/app_top_bar.dart';

class LinkHandlesView extends StatelessWidget {
  LinkHandlesView({super.key});

  final platform = Get.find<PlatformController>();

  final TextEditingController cfCtrl = TextEditingController();
  final TextEditingController lcCtrl = TextEditingController();
  final TextEditingController ccCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Pre-populate with current values if editing
    cfCtrl.text = platform.savedCf.value;
    lcCtrl.text = platform.savedLc.value;
    ccCtrl.text = platform.savedCc.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: "Connect Profiles", showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Configure Coding Handles",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Enter at least one username. Leave blank if you don't use that platform.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // .value eliminates the red squiggly lines:
                PlatformInputCard(
                  title: "Codeforces",
                  hint: "e.g. tourist",
                  controller: cfCtrl,
                  accentColor: AppColors.codeforces,
                  icon: Icons.bar_chart_rounded,
                  isVerified: platform.cfVerified.value,
                ),
                PlatformInputCard(
                  title: "LeetCode",
                  hint: "e.g. neetcode",
                  controller: lcCtrl,
                  accentColor: AppColors.leetCode,
                  icon: Icons.code_rounded,
                  isVerified: platform.lcVerified.value,
                ),
                PlatformInputCard(
                  title: "CodeChef",
                  hint: "e.g. chef_master",
                  controller: ccCtrl,
                  accentColor: AppColors.codeChef,
                  icon: Icons.restaurant_menu_rounded,
                  isVerified: platform.ccVerified.value,
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  label: "Save & Continue →",
                  isLoading: platform.isChecking.value,
                  onTap: () {
                    platform.verifyAllHandles(
                      cfCtrl.text,
                      lcCtrl.text,
                      ccCtrl.text,
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