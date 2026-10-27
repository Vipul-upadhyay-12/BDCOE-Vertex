class PracticeProblemModel {
  final String id;
  final String title;
  final String platform; // 'CF', 'AC' (AtCoder), 'CC'
  final int rating; // Difficulty / Kenkoooo difficulty
  final List<String> tags;
  final String url;
  final bool isUpsolve;

  PracticeProblemModel({
    required this.id,
    required this.title,
    required this.platform,
    required this.rating,
    required this.tags,
    required this.url,
    this.isUpsolve = false,
  });

  String get difficultyLabel {
    if (rating <= 0) return 'Unrated';
    return '$rating';
  }
}