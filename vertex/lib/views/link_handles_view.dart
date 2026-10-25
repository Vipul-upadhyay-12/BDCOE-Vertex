import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/platform_controller.dart';
import '../core/constants/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/platform_input_card.dart';

class LinkHandlesView extends StatelessWidget {
  LinkHandlesView({super.key});

  final platform = Get.put(PlatformController());

  final cfCtrl = TextEditingController();
  final lcCtrl = TextEditingController();
  final ccCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Link Profiles", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Connect Coding Handles",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Connect Codeforces, LeetCode, and CodeChef to aggregate your progress.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),

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
                const SizedBox(height: 20),

                PrimaryButton(
                  label: "Verify & Continue →",
                  isLoading: platform.isChecking.value,
                  onTap: () => platform.verifyAllHandles(cfCtrl.text, lcCtrl.text, ccCtrl.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}