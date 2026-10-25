class SubmissionModel {
  final String problemName;
  final String platform; // 'CF', 'LC', or 'CC'
  final DateTime solvedAt;
  final String? ratingOrDifficulty;

  SubmissionModel({
    required this.problemName,
    required this.platform,
    required this.solvedAt,
    this.ratingOrDifficulty,
  });
}