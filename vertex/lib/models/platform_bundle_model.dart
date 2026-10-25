import 'submission_model.dart';
import 'rating_point_model.dart';

class PlatformDataBundle {
  final List<SubmissionModel> submissions;
  final List<RatingPointModel> ratings;

  PlatformDataBundle({
    required this.submissions,
    required this.ratings,
  });
}