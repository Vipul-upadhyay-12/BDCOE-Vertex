import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/goals_controller.dart';
import '../controllers/platform_controller.dart';
import '../core/constants/app_colors.dart';
import '../models/goal_model.dart';
import '../widgets/navigation/app_top_bar.dart';

class GoalTrackerView extends StatelessWidget {
  GoalTrackerView({super.key});

  final GoalsController goalsController = Get.put(GoalsController());
  final DashboardController dashController = Get.find<DashboardController>();
  final PlatformController platformController = Get.find<PlatformController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: "Goals & Roadmap",
        showBack: false,
        actions: [
          IconButton(
            tooltip: "Add New Goal",
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGreen),
            onPressed: () => _showAddGoalSheet(context),
          ),
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Primary Target Tier Card
                  _buildNorthStarCard(context),
                  const SizedBox(height: 18),

                  // 2. Daily & Weekly Habit Loops
                  _buildHabitRow(),
                  const SizedBox(height: 22),

                  // 3. Active Sprints & Quests
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Active Sprints & Quests",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddGoalSheet(context),
                        icon: const Icon(Icons.add, size: 16, color: AppColors.primaryGreen),
                        label: const Text(
                          "New Sprint",
                          style: TextStyle(fontSize: 12, color: AppColors.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (goalsController.goals.isEmpty)
                    _buildEmptyGoals()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: goalsController.goals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final g = goalsController.goals[index];
                        return _buildGoalCard(g);
                      },
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNorthStarCard(BuildContext context) {
    // Current rating based on chosen target platform
    int currentRating = 1200;
    final plat = goalsController.targetPlatform.value;

    if (plat.toLowerCase().contains('codeforces')) {
      currentRating = platformController.cfRating.value > 0 ? platformController.cfRating.value : 1200;
    } else if (plat.toLowerCase().contains('codechef')) {
      final ccRatings = dashController.ratingHistory.where((r) => r.platform == 'CC').toList();
      currentRating = ccRatings.isNotEmpty ? ccRatings.last.rating : 1400;
    } else if (plat.toLowerCase().contains('leetcode')) {
      currentRating = dashController.lcRating.value > 0 ? dashController.lcRating.value : 1500;
    } else {
      currentRating = dashController.peakRating.value > 0 ? dashController.peakRating.value : 1200;
    }

    final target = goalsController.targetRating.value;
    final delta = target - currentRating;
    final progress = (currentRating / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flag_rounded, color: AppColors.primaryGreen, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "PRIMARY TARGET TIER",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showEditTargetRating(context),
                child: const Text(
                  "Choose Platform / Target",
                  style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "$plat Target: $target",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            delta > 0
                ? "+$delta rating needed (~${(delta / 45).ceil()} solid contest rounds)"
                : "Target Reached! Push to the next tier.",
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Current: $currentRating", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text("${(progress * 100).toInt()}%",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              Text("Goal: $target", style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitRow() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todaySolves = dashController.allSubmissions.where((s) => s.solvedAt.isAfter(todayStart)).length;

    return Row(
      children: [
        Expanded(
          child: _habitCard(
            title: "Today's Solves",
            val: "$todaySolves / 2",
            subtitle: todaySolves >= 2 ? "Goal Met! 🎯" : "${2 - todaySolves} more to target",
            icon: Icons.check_circle_outline_rounded,
            color: todaySolves >= 2 ? AppColors.primaryGreen : AppColors.leetCode,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _habitCard(
            title: "Daily Streak",
            val: "${dashController.currentStreak.value} Days",
            subtitle: "Non-zero practice",
            icon: Icons.local_fire_department_rounded,
            color: Colors.deepOrangeAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _habitCard(
            title: "Weekly Upsolve",
            val: "Pending",
            subtitle: "1 round missed task",
            icon: Icons.bolt_rounded,
            color: Colors.amberAccent,
          ),
        ),
      ],
    );
  }

  Widget _habitCard({
    required String title,
    required String val,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 1),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(GoalModel g) {
    final progress = goalsController.getProgress(g);
    final ratio = (progress / g.targetValue).clamp(0.0, 1.0);
    final isDone = progress >= g.targetValue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? AppColors.primaryGreen.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  g.topicTag?.toUpperCase() ?? g.platform,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  g.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              if (g.deadline != null)
                Text(
                  "${g.daysRemaining}d left",
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                onPressed: () => goalsController.deleteGoal(g.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? AppColors.primaryGreen : Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress: $progress / ${g.targetValue} solved (${g.platform})",
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                isDone ? "Completed! ✓" : "${(ratio * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDone ? AppColors.primaryGreen : Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGoals() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: const [
          Icon(Icons.track_changes_rounded, size: 38, color: AppColors.textSecondary),
          SizedBox(height: 10),
          Text(
            "No active sprints right now.\nCreate a topic sprint like 'Solve 10 DP Problems' to get started.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Choose target rating directly from connected platforms or custom input
  void _showEditTargetRating(BuildContext context) {
    // Current live ratings
    final cfRating = platformController.cfRating.value > 0 ? platformController.cfRating.value : 1200;
    final ccRatings = dashController.ratingHistory.where((r) => r.platform == 'CC').toList();
    final ccRating = ccRatings.isNotEmpty ? ccRatings.last.rating : 1400;
    final lcRating = dashController.lcRating.value > 0 ? dashController.lcRating.value : 1500;

    String chosenPlat = goalsController.targetPlatform.value;
    final textController = TextEditingController(text: '${goalsController.targetRating.value}');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Select Rating Target",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                "Choose a platform milestone based on your current rating:",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Quick Tier Presets
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _presetChip("Codeforces: 1400 (Specialist)", () {
                    goalsController.updateRatingTarget(1400, "Codeforces");
                    Get.back();
                  }),
                  _presetChip("Codeforces: 1600 (Expert)", () {
                    goalsController.updateRatingTarget(1600, "Codeforces");
                    Get.back();
                  }),
                  _presetChip("CodeChef: 1600 (3★)", () {
                    goalsController.updateRatingTarget(1600, "CodeChef");
                    Get.back();
                  }),
                  _presetChip("CodeChef: 1800 (4★)", () {
                    goalsController.updateRatingTarget(1800, "CodeChef");
                    Get.back();
                  }),
                  _presetChip("LeetCode: 1850 (Knight)", () {
                    goalsController.updateRatingTarget(1850, "LeetCode");
                    Get.back();
                  }),
                  _presetChip("Codeforces: +100 from current ($cfRating -> ${cfRating + 100})", () {
                    goalsController.updateRatingTarget(cfRating + 100, "Codeforces");
                    Get.back();
                  }),
                  _presetChip("CodeChef: +150 from current ($ccRating -> ${ccRating + 150})", () {
                    goalsController.updateRatingTarget(ccRating + 150, "CodeChef");
                    Get.back();
                  }),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),

              const Text("Or Set Custom Rating Target", style: TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: chosenPlat.contains('CodeChef')
                    ? 'CodeChef'
                    : chosenPlat.contains('LeetCode')
                        ? 'LeetCode'
                        : 'Codeforces',
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Platform"),
                items: const [
                  DropdownMenuItem(value: 'Codeforces', child: Text("Codeforces")),
                  DropdownMenuItem(value: 'CodeChef', child: Text("CodeChef")),
                  DropdownMenuItem(value: 'LeetCode', child: Text("LeetCode")),
                  DropdownMenuItem(value: 'AtCoder', child: Text("AtCoder")),
                ],
                onChanged: (v) {
                  if (v != null) chosenPlat = v;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Target Rating",
                  hintText: "e.g. 1500",
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  final val = int.tryParse(textController.text);
                  if (val != null && val > 0) {
                    goalsController.updateRatingTarget(val, chosenPlat);
                  }
                  Get.back();
                },
                child: const Text("Save Custom Target",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _presetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: Colors.white),
        ),
      ),
    );
  }

  /// Create practice sprint modal with friendly platform names
  void _showAddGoalSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final countCtrl = TextEditingController(text: "10");
    final daysCtrl = TextEditingController(text: "14");
    String selectedTag = 'dp';
    String selectedPlat = 'All Platforms';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Create Practice Sprint",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Sprint Name",
                  hintText: "e.g. DP & Tree Traversals",
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedPlat,
                      dropdownColor: AppColors.surfaceElevated,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Platform"),
                      items: const [
                        DropdownMenuItem(value: 'All Platforms', child: Text("All Platforms")),
                        DropdownMenuItem(value: 'Codeforces', child: Text("Codeforces")),
                        DropdownMenuItem(value: 'LeetCode', child: Text("LeetCode")),
                        DropdownMenuItem(value: 'CodeChef', child: Text("CodeChef")),
                        DropdownMenuItem(value: 'AtCoder', child: Text("AtCoder")),
                      ],
                      onChanged: (v) {
                        if (v != null) selectedPlat = v;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedTag,
                      dropdownColor: AppColors.surfaceElevated,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Topic Tag"),
                      items: ['dp', 'graphs', 'trees', 'greedy', 'binary search', 'math', 'number theory']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) selectedTag = v;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: countCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Target Solves"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: daysCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Duration (Days)"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  final title = titleCtrl.text.trim().isEmpty ? "Topic Sprint" : titleCtrl.text.trim();
                  final target = int.tryParse(countCtrl.text) ?? 10;
                  final days = int.tryParse(daysCtrl.text) ?? 14;

                  goalsController.addGoal(
                    title: title,
                    type: GoalType.topicSprint,
                    platform: selectedPlat,
                    targetValue: target,
                    topicTag: selectedTag,
                    deadline: DateTime.now().add(Duration(days: days)),
                    onlyCountFromStart: true,
                  );
                  Get.back();
                },
                child: const Text(
                  "Activate Sprint",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}