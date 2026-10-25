import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/submission_model.dart';
import '../models/rating_point_model.dart';
import '../models/platform_bundle_model.dart';

class ApiService {
  // --- VERIFICATION CHECKS ---

  static Future<bool> checkCodeforces(String handle) async {
    try {
      final res = await http.get(Uri.parse('https://codeforces.com/api/user.info?handles=$handle'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['status'] == 'OK';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> checkLeetCode(String username) async {
    try {
      final query = 'query { matchedUser(username: "$username") { username } }';
      final res = await http.post(
        Uri.parse('https://leetcode.com/graphql'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data']?['matchedUser'] != null;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> checkCodeChef(String username) async {
    try {
      final res = await http.get(Uri.parse('https://www.codechef.com/users/$username'));
      return res.statusCode == 200 && !res.body.contains("User doesn't exist");
    } catch (_) {
      return false;
    }
  }

  // --- FULL DATA FETCHERS (Resolves your red lines) ---

  // 1. Codeforces Submissions + Rating History
  static Future<PlatformDataBundle> fetchCodeforcesData(String handle) async {
    List<SubmissionModel> subs = [];
    List<RatingPointModel> ratings = [];

    try {
      // Submissions
      final subRes = await http.get(
        Uri.parse('https://codeforces.com/api/user.status?handle=$handle&from=1&count=100'),
      );
      if (subRes.statusCode == 200) {
        final data = jsonDecode(subRes.body);
        if (data['status'] == 'OK') {
          for (var item in data['result']) {
            if (item['verdict'] == 'OK') {
              subs.add(
                SubmissionModel(
                  problemName: item['problem']['name'] ?? 'CF Problem',
                  platform: 'CF',
                  solvedAt: DateTime.fromMillisecondsSinceEpoch(
                    (item['creationTimeSeconds'] as int) * 1000,
                  ),
                  ratingOrDifficulty: item['problem']['rating']?.toString(),
                ),
              );
            }
          }
        }
      }

      // Rating Changes
      final ratingRes = await http.get(
        Uri.parse('https://codeforces.com/api/user.rating?handle=$handle'),
      );
      if (ratingRes.statusCode == 200) {
        final data = jsonDecode(ratingRes.body);
        if (data['status'] == 'OK') {
          for (var item in data['result']) {
            ratings.add(
              RatingPointModel(
                date: DateTime.fromMillisecondsSinceEpoch(
                  (item['ratingUpdateTimeSeconds'] as int) * 1000,
                ),
                rating: item['newRating'] as int,
                platform: 'CF',
              ),
            );
          }
        }
      }
    } catch (_) {}

    return PlatformDataBundle(submissions: subs, ratings: ratings);
  }

  // 2. LeetCode Submissions + Ratings
  static Future<PlatformDataBundle> fetchLeetCodeData(String username) async {
    List<SubmissionModel> subs = [];
    List<RatingPointModel> ratings = [];

    try {
      final query = '''
      query getUserProfile(\$username: String!) {
        matchedUser(username: \$username) {
          userCalendar {
            submissionCalendar
          }
        }
        userContestRanking(username: \$username) {
          rating
        }
      }
      ''';

      final res = await http.post(
        Uri.parse('https://leetcode.com/graphql'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query, 'variables': {'username': username}}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawCalendar = data['data']?['matchedUser']?['userCalendar']?['submissionCalendar'];
        
        // Parse unix timestamps map from LeetCode calendar
        if (rawCalendar != null) {
          final Map<String, dynamic> calMap = jsonDecode(rawCalendar);
          calMap.forEach((timestampStr, count) {
            final ts = int.tryParse(timestampStr);
            if (ts != null) {
              final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
              for (int i = 0; i < (count as int); i++) {
                subs.add(SubmissionModel(
                  problemName: 'LeetCode Problem',
                  platform: 'LC',
                  solvedAt: date,
                ));
              }
            }
          });
        }

        // Contest rating if user participates
        final contestRating = data['data']?['userContestRanking']?['rating'];
        if (contestRating != null) {
          ratings.add(
            RatingPointModel(
              date: DateTime.now(),
              rating: (contestRating as num).round(),
              platform: 'LC',
            ),
          );
        }
      }
    } catch (_) {}

    return PlatformDataBundle(submissions: subs, ratings: ratings);
  }

  // 3. CodeChef Submissions + Ratings
  static Future<PlatformDataBundle> fetchCodeChefData(String username) async {
    List<SubmissionModel> subs = [];
    List<RatingPointModel> ratings = [];

    try {
      final res = await http.get(Uri.parse('https://www.codechef.com/users/$username'));
      if (res.statusCode == 200) {
        // Scrapes rating number from html
        final ratingMatch = RegExp(r'class="rating-number">(\d+)<\/div>').firstMatch(res.body);
        if (ratingMatch != null) {
          final rating = int.tryParse(ratingMatch.group(1) ?? '0') ?? 0;
          if (rating > 0) {
            ratings.add(
              RatingPointModel(
                date: DateTime.now(),
                rating: rating,
                platform: 'CC',
              ),
            );
          }
        }
      }
    } catch (_) {}

    return PlatformDataBundle(submissions: subs, ratings: ratings);
  }
}