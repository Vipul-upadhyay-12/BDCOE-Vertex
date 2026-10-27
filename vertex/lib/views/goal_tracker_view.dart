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
      body: SafeArea(
        child: Obx(() {
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

                    // 3. Active Sprints & Quests Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Active Sprints & Quests",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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

                    // 4. Goals List / Empty State
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
      ),
    );
  }

  Widget _buildNorthStarCard(BuildContext context) {
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
      padding: const EdgeInsets.all(16),
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
                    child: const Icon(Icons.flag_rounded, color: AppColors.primaryGreen, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "PRIMARY TARGET TIER",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showEditTargetRating(context),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    "Edit Target",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.primaryGreen,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "$plat Target: $target",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
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
              minHeight: 8,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _habitCard(
                title: "Today's Solves",
                val: "$todaySolves / 2",
                subtitle: todaySolves >= 2 ? "Goal Met! 🎯" : "${2 - todaySolves} left",
                icon: Icons.check_circle_outline_rounded,
                color: todaySolves >= 2 ? AppColors.primaryGreen : AppColors.leetCode,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _habitCard(
                title: "Daily Streak",
                val: "${dashController.currentStreak.value}d",
                subtitle: "Active habit",
                icon: Icons.local_fire_department_rounded,
                color: Colors.deepOrangeAccent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _habitCard(
                title: "Upsolve",
                val: "Pending",
                subtitle: "Last contest",
                icon: Icons.bolt_rounded,
                color: Colors.amberAccent,
              ),
            ),
          ],
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              val,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.w500),
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  g.topicTag?.toUpperCase() ?? g.platform,
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  g.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              if (g.deadline != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 4),
                  child: Text(
                    "${g.daysRemaining}d left",
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
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
              Expanded(
                child: Text(
                  "Progress: $progress / ${g.targetValue} solved (${g.platform})",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        children: const [
          Icon(Icons.track_changes_rounded, size: 36, color: AppColors.textSecondary),
          SizedBox(height: 10),
          Text(
            "No active sprints right now.\nTap 'New Sprint' to set a topic target like DP or Graphs.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  void _showEditTargetRating(BuildContext context) {
    final cfRating = platformController.cfRating.value > 0 ? platformController.cfRating.value : 1200;
    final ccRatings = dashController.ratingHistory.where((r) => r.platform == 'CC').toList();
    final ccRating = ccRatings.isNotEmpty ? ccRatings.last.rating : 1400;

    String chosenPlat = goalsController.targetPlatform.value;
    final textController = TextEditingController(text: '${goalsController.targetRating.value}');

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
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
              const SizedBox(height: 4),
              const Text(
                "Choose a platform milestone or enter a custom target:",
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _presetChip("CF: 1400 (Specialist)", () {
                    goalsController.updateRatingTarget(1400, "Codeforces");
                    Get.back();
                  }),
                  _presetChip("CF: 1600 (Expert)", () {
                    goalsController.updateRatingTarget(1600, "Codeforces");
                    Get.back();
                  }),
                  _presetChip("CC: 1600 (3★)", () {
                    goalsController.updateRatingTarget(1600, "CodeChef");
                    Get.back();
                  }),
                  _presetChip("CC: 1800 (4★)", () {
                    goalsController.updateRatingTarget(1800, "CodeChef");
                    Get.back();
                  }),
                  _presetChip("LC: 1850 (Knight)", () {
                    goalsController.updateRatingTarget(1850, "LeetCode");
                    Get.back();
                  }),
                  _presetChip("CF: +100 ($cfRating -> ${cfRating + 100})", () {
                    goalsController.updateRatingTarget(cfRating + 100, "Codeforces");
                    Get.back();
                  }),
                  _presetChip("CC: +150 ($ccRating -> ${ccRating + 150})", () {
                    goalsController.updateRatingTarget(ccRating + 150, "CodeChef");
                    Get.back();
                  }),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: chosenPlat.contains('CodeChef')
                    ? 'CodeChef'
                    : chosenPlat.contains('LeetCode')
                        ? 'LeetCode'
                        : chosenPlat.contains('AtCoder')
                            ? 'AtCoder'
                            : 'Codeforces',
                isExpanded: true,
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
                child: const Text("Save Target",
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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6.5),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
      ),
    );
  }

  /// Create practice sprint modal with adaptive layout for all phone sizes
  void _showAddGoalSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final countCtrl = TextEditingController(text: "10");
    final daysCtrl = TextEditingController(text: "14");
    String selectedTag = 'dp';
    String selectedPlat = 'All Platforms';

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;

              return Column(
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
                      hintText: "e.g. DP & Graphs Drill",
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Adaptive Platform & Topic Selector
                  if (isNarrow) ...[
                    _buildPlatformDropdown(selectedPlat, (v) => selectedPlat = v),
                    const SizedBox(height: 10),
                    _buildTopicDropdown(selectedTag, (v) => selectedTag = v),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(child: _buildPlatformDropdown(selectedPlat, (v) => selectedPlat = v)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildTopicDropdown(selectedTag, (v) => selectedTag = v)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),

                  // Count & Duration Inputs
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
                      const SizedBox(width: 10),
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformDropdown(String current, ValueChanged<String> onChanged) {
    return DropdownButtonFormField<String>(
      value: current,
      isExpanded: true,
      dropdownColor: AppColors.surfaceElevated,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: const InputDecoration(labelText: "Platform"),
      items: const [
        DropdownMenuItem(value: 'All Platforms', child: Text("All", overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(value: 'Codeforces', child: Text("Codeforces", overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(value: 'LeetCode', child: Text("LeetCode", overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(value: 'CodeChef', child: Text("CodeChef", overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(value: 'AtCoder', child: Text("AtCoder", overflow: TextOverflow.ellipsis)),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  Widget _buildTopicDropdown(String current, ValueChanged<String> onChanged) {
    return DropdownButtonFormField<String>(
      value: current,
      isExpanded: true,
      dropdownColor: AppColors.surfaceElevated,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: const InputDecoration(labelText: "Topic Tag"),
      items: const [
        DropdownMenuItem(value: 'dp', child: Text("DP", overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(value: 'graphs', child: Text("Graphs", overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(value: 'trees', child: Text("Trees", overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(value: 'greedy', child: Text("Greedy", overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(value: 'binary search', child: Text("Binary Search", overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(value: 'math', child: Text("Math", overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(value: 'number theory', child: Text("Num Theory", overflow: TextOverflow.ellipsis)),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}