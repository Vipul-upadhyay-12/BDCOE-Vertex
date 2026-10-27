import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/practice_controller.dart';
import '../core/constants/app_colors.dart';
import '../models/problem_recommendation_model.dart';
import '../widgets/navigation/app_top_bar.dart';

class PracticeView extends StatelessWidget {
  const PracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PracticeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: "Adaptive Practice",
        showBack: false,
        actions: [
          IconButton(
            tooltip: "Refresh Problems",
            icon: Obx(() => controller.isLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white)),
            onPressed: () => controller.loadPracticeProblems(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.problems.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        return RefreshIndicator(
          color: AppColors.primaryGreen,
          backgroundColor: AppColors.surface,
          onRefresh: () => controller.loadPracticeProblems(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Platform Filter Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterPill(controller, "All Platforms", "ALL"),
                          const SizedBox(width: 8),
                          _filterPill(controller, "Codeforces", "CF", color: AppColors.codeforces),
                          const SizedBox(width: 8),
                          _filterPill(controller, "AtCoder (Kenkoooo)", "AC", color: Colors.deepOrangeAccent),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Topic Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: controller.topics.map((t) {
                          final isSel = controller.selectedTopic.value == t;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(t.toUpperCase()),
                              selected: isSel,
                              selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSel ? AppColors.primaryGreen : AppColors.border,
                                ),
                              ),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                color: isSel ? AppColors.primaryGreen : AppColors.textSecondary,
                              ),
                              onSelected: (_) => controller.setTopic(t),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 1: UPSOLVING QUEUE
                    if (controller.upsolveProblems.isNotEmpty) ...[
                      Row(
                        children: const [
                          Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 20),
                          SizedBox(width: 6),
                          Text(
                            "Contest Upsolving Queue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Problems you missed or couldn't reach in your recent contests.",
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      ...controller.upsolveProblems.map((p) => _problemCard(p, isUpsolve: true)),
                      const SizedBox(height: 24),
                    ],

                    // SECTION 2: ADAPTIVE PRACTICE (Target Level)
                    Row(
                      children: [
                        const Icon(Icons.psychology_rounded, color: AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          "Recommended for Rating ~${controller.effectiveUserRating}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Targeted difficulty range (+100 to +300) to raise your contest ceiling.",
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.problems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) => _problemCard(controller.problems[idx]),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _filterPill(PracticeController c, String label, String key, {Color? color}) {
    final isSelected = c.selectedPlatform.value == key;
    final activeColor = color ?? AppColors.primaryGreen;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => c.setPlatform(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _problemCard(PracticeProblemModel p, {bool isUpsolve = false}) {
    Color platColor;
    if (p.platform == 'CF') {
      platColor = AppColors.codeforces;
    } else if (p.platform == 'AC') {
      platColor = Colors.deepOrangeAccent;
    } else {
      platColor = AppColors.codeChef;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUpsolve ? Colors.amberAccent.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Platform Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: platColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: platColor, width: 1),
            ),
            child: Text(
              p.platform,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: platColor),
            ),
          ),
          const SizedBox(width: 12),

          // Problem info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Difficulty Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        "★ ${p.difficultyLabel}",
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    ...p.tags.take(2).map(
                          (t) => Text(
                            "#$t",
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),

          // Copy Link Button
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primaryGreen),
            tooltip: "Copy Problem Link",
            onPressed: () {
              Clipboard.setData(ClipboardData(text: p.url));
              Get.snackbar(
                "Link Copied",
                "Opened/copied problem link to clipboard",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.surfaceElevated,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
    );
  }
}