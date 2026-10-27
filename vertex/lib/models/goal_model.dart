import 'package:vertex/models/submission_model.dart';

class GoalModel {
  final String id;
  final String title;
  final String topicTag;         // e.g. 'dp', 'graphs'
  final int targetCount;         // e.g. 15
  final DateTime startDate;      // Exact timestamp when goal was activated
  final DateTime? deadline;      // Optional cutoff date
  final bool onlyCountFromStart; // true = new solves only, false = all-time

  GoalModel({
    required this.id,
    required this.title,
    required this.topicTag,
    required this.targetCount,
    required this.startDate,
    this.deadline,
    this.onlyCountFromStart = true,
  });

  /// Dynamically computes progress against your live submission stream
  int calculateCurrentProgress(List<SubmissionModel> allSubmissions) {
    return allSubmissions.where((sub) {
      // 1. Tag match check
      final hasTag = sub.tags.any(
        (t) => t.toLowerCase().contains(topicTag.toLowerCase()),
      );
      if (!hasTag) return false;

      // 2. Time anchor check
      if (onlyCountFromStart && sub.solvedAt.isBefore(startDate)) {
        return false;
      }

      // 3. Deadline check (if any)
      if (deadline != null && sub.solvedAt.isAfter(deadline!)) {
        return false;
      }

      return true;
    }).length;
  }
}