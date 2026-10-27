enum GoalType { ratingTarget, topicSprint, dailySolves }

class GoalModel {
  final String id;
  final String title;
  final GoalType type;
  final String platform; // 'CF', 'CC', 'LC', 'AC', 'ALL'
  final int targetValue;
  final String? topicTag;
  final DateTime startDate;
  final DateTime? deadline;
  final bool onlyCountFromStart;

  GoalModel({
    required this.id,
    required this.title,
    required this.type,
    required this.platform,
    required this.targetValue,
    this.topicTag,
    required this.startDate,
    this.deadline,
    this.onlyCountFromStart = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'platform': platform,
        'targetValue': targetValue,
        'topicTag': topicTag,
        'startDate': startDate.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'onlyCountFromStart': onlyCountFromStart,
      };

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        type: GoalType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => GoalType.topicSprint,
        ),
        platform: json['platform'] ?? 'ALL',
        targetValue: json['targetValue'] ?? 0,
        topicTag: json['topicTag'],
        startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
        deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
        onlyCountFromStart: json['onlyCountFromStart'] ?? true,
      );

  bool get isExpired => deadline != null && DateTime.now().isAfter(deadline!);

  int get daysRemaining {
    if (deadline == null) return 0;
    final diff = deadline!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }
}