class SubmissionModel {
  final String problemName;
  final String platform; // 'CF', 'LC', or 'CC'
  final DateTime solvedAt;
  final String? ratingOrDifficulty;
  final List<String> tags; // <-- lowercase 'tags'

  SubmissionModel({
    required this.problemName,
    required this.platform,
    required this.solvedAt,
    this.ratingOrDifficulty,
    this.tags = const [],
  });
}