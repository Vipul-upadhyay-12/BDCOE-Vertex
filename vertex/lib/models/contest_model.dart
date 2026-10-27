class ContestModel {
  final String id;
  final String name;
  final String platform; // 'CF' or 'CC'
  final DateTime startTime;
  final Duration duration;
  final String url;

  ContestModel({
    required this.id,
    required this.name,
    required this.platform,
    required this.startTime,
    required this.duration,
    required this.url,
  });

  /// Deterministic integer ID for the Android notification engine
  int get notificationId => id.hashCode.abs() % 100000;

  bool get isLive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(startTime.add(duration));
  }

  String get timeRemainingFormatted {
    final diff = startTime.difference(DateTime.now());
    if (diff.isNegative) {
      if (isLive) return "LIVE NOW";
      return "Ended";
    }
    if (diff.inDays > 0) {
      final hours = diff.inHours % 24;
      return "Starts in ${diff.inDays}d ${hours}h";
    }
    if (diff.inHours > 0) {
      final mins = diff.inMinutes % 60;
      return "Starts in ${diff.inHours}h ${mins}m";
    }
    return "Starts in ${diff.inMinutes}m";
  }

  String get durationFormatted {
    final hours = duration.inHours;
    final mins = duration.inMinutes % 60;
    if (hours > 0 && mins > 0) return "${hours}h ${mins}m";
    if (hours > 0) return "${hours} hrs";
    return "${mins} mins";
  }
}