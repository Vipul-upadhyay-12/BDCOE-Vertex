import 'submission_model.dart';
import 'rating_point_model.dart';

class PlatformDataBundle {
  final List<SubmissionModel> submissions;
  final List<RatingPointModel> ratings;
  final Map<DateTime, int> calendarMap; // <-- Add this field

  PlatformDataBundle({
    required this.submissions,
    required this.ratings,
    this.calendarMap = const {},        // <-- Add to constructor
  });
}