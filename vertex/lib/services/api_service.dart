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
      final res = await http.get(Uri.parse('https://alfa-leetcode-api.onrender.com/$username'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['errors'] == null && data['username'] != null;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> checkCodeChef(String username) async {
    try {
      final res = await http.get(Uri.parse('https://codechef-api.vercel.app/handle/$username'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['success'] == true || data['currentRating'] != null;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchCodeforcesUserInfo(String handle) async {
    try {
      final res = await http.get(Uri.parse('https://codeforces.com/api/user.info?handles=$handle'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'OK' && (data['result'] as List).isNotEmpty) {
          return data['result'][0] as Map<String, dynamic>;
        }
      }
    } catch (_) {}
    return null;
  }

  // --- DATA FETCHERS ---

  // 1. Codeforces
  static Future<PlatformDataBundle> fetchCodeforcesData(String handle) async {
    List<SubmissionModel> subs = [];
    List<RatingPointModel> ratings = [];
    Set<String> seenProblems = {};

    try {
      final subRes = await http.get(Uri.parse('https://codeforces.com/api/user.status?handle=$handle'));
      if (subRes.statusCode == 200) {
        final data = jsonDecode(subRes.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          for (var item in data['result']) {
            if (item['verdict'] == 'OK') {
              final problem = item['problem'];
              if (problem == null) continue;

              final name = problem['name']?.toString() ?? 'CF Problem';
              final id = "${problem['contestId'] ?? ''}${problem['index'] ?? ''}";
              final key = id.isNotEmpty ? id : name;

              if (!seenProblems.contains(key)) {
                seenProblems.add(key);

                final sec = item['creationTimeSeconds'];
                final timeMs = sec is num ? (sec * 1000).toInt() : 0;

                List<String> tags = [];
                if (problem['tags'] != null && problem['tags'] is List) {
                  for (var t in problem['tags']) {
                    if (t != null && t.toString().trim().isNotEmpty) {
                      tags.add(t.toString().trim());
                    }
                  }
                }

                subs.add(
                  SubmissionModel(
                    problemName: name,
                    platform: 'CF',
                    solvedAt: DateTime.fromMillisecondsSinceEpoch(timeMs),
                    ratingOrDifficulty: problem['rating']?.toString(),
                    tags: tags,
                  ),
                );
              }
            }
          }
        }
      }
    } catch (_) {}

    try {
      final ratingRes = await http.get(Uri.parse('https://codeforces.com/api/user.rating?handle=$handle'));
      if (ratingRes.statusCode == 200) {
        final data = jsonDecode(ratingRes.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          for (var item in data['result']) {
            final sec = item['ratingUpdateTimeSeconds'];
            final timeMs = sec is num ? (sec * 1000).toInt() : 0;
            final r = item['newRating'];
            final ratingVal = r is num ? r.toInt() : 0;

            if (ratingVal > 0) {
              ratings.add(
                RatingPointModel(
                  date: DateTime.fromMillisecondsSinceEpoch(timeMs),
                  rating: ratingVal,
                  platform: 'CF',
                ),
              );
            }
          }
        }
      }
    } catch (_) {}

    return PlatformDataBundle(submissions: subs, ratings: ratings);
  }

  // 2. LeetCode (Powered by Open REST API)
  static Future<PlatformDataBundle> fetchLeetCodeData(String username) async {
    List<SubmissionModel> subs = [];
    List<RatingPointModel> ratings = [];
    Set<String> acProblemTitles = {};

    // 1. Real Solved Problems Feed (Exact timestamps + problem titles)
    try {
      final acRes = await http
          .get(Uri.parse('https://alfa-leetcode-api.onrender.com/$username/acSubmission?limit=50'))
          .timeout(const Duration(seconds: 5));

      if (acRes.statusCode == 200) {
        final data = jsonDecode(acRes.body);
        final List? acList = data['submission'];
        if (acList != null) {
          for (var item in acList) {
            final title = item['title']?.toString() ?? 'LeetCode Problem';
            final ts = int.tryParse(item['timestamp']?.toString() ?? '0') ?? 0;

            if (ts > 0 && !acProblemTitles.contains(title)) {
              acProblemTitles.add(title);
              subs.add(
                SubmissionModel(
                  problemName: title,
                  platform: 'LC',
                  solvedAt: DateTime.fromMillisecondsSinceEpoch(ts * 1000),
                  tags: ['LeetCode'],
                ),
              );
            }
          }
        }
      }
    } catch (_) {}

    // 2. Calendar Activity for Historical Heatmap Only (Avoids phantom "18h ago" duplicates)
    try {
      final calRes = await http
          .get(Uri.parse('https://alfa-leetcode-api.onrender.com/$username/calendar'))
          .timeout(const Duration(seconds: 5));

      if (calRes.statusCode == 200) {
        final data = jsonDecode(calRes.body);
        final rawCalendar = data['submissionCalendar'];
        if (rawCalendar != null) {
          final Map<String, dynamic> calMap =
              rawCalendar is String ? jsonDecode(rawCalendar) : rawCalendar;

          final now = DateTime.now();
          final todayMidnight = DateTime(now.year, now.month, now.day);

          calMap.forEach((tsStr, count) {
            final ts = int.tryParse(tsStr);
            if (ts != null) {
              final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
              final dateMidnight = DateTime(date.year, date.month, date.day);

              // Skip current day to prevent overwriting exact AC timestamps
              if (dateMidnight.isBefore(todayMidnight)) {
                final solveCount = count is num ? count.toInt() : 1;
                for (int i = 0; i < solveCount; i++) {
                  subs.add(
                    SubmissionModel(
                      problemName: 'LeetCode Problem',
                      platform: 'LC',
                      solvedAt: date,
                      tags: ['LeetCode'],
                    ),
                  );
                }
              }
            }
          });
        }
      }
    } catch (_) {}

    // 3. Contest History
    try {
      final contestRes = await http
          .get(Uri.parse('https://alfa-leetcode-api.onrender.com/$username/contest'))
          .timeout(const Duration(seconds: 5));

      if (contestRes.statusCode == 200) {
        final data = jsonDecode(contestRes.body);
        final List? history = data['contestHistory'];
        if (history != null) {
          for (var item in history) {
            if (item['attended'] == true && item['rating'] != null) {
              final r = (item['rating'] as num).toInt();
              final sec = item['contest']?['startTime'];
              final timeMs =
                  sec is num ? (sec * 1000).toInt() : DateTime.now().millisecondsSinceEpoch;
              ratings.add(
                RatingPointModel(
                  date: DateTime.fromMillisecondsSinceEpoch(timeMs),
                  rating: r,
                  platform: 'LC',
                ),
              );
            }
          }
        }
      }
    } catch (_) {}

    return PlatformDataBundle(submissions: subs, ratings: ratings);
  }

  // 3. CodeChef (Powered by Open REST API)
  static Future<PlatformDataBundle> fetchCodeChefData(String username) async {
    List<SubmissionModel> subs = [];
    List<RatingPointModel> ratings = [];

    try {
      final res = await http.get(Uri.parse('https://codechef-api.vercel.app/handle/$username'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // Current Rating
        final currentRating = data['currentRating'];
        if (currentRating != null && currentRating is num && currentRating > 0) {
          ratings.add(
            RatingPointModel(
              date: DateTime.now(),
              rating: currentRating.toInt(),
              platform: 'CC',
            ),
          );
        }

        // Contest Rating Graph History (if present)
        if (data['ratingData'] != null && data['ratingData'] is List) {
          for (var item in data['ratingData']) {
            final r = item['rating'];
            final year = int.tryParse(item['year']?.toString() ?? '');
            final month = int.tryParse(item['month']?.toString() ?? '');
            final day = int.tryParse(item['day']?.toString() ?? '');

            if (r != null && r is num && year != null && month != null && day != null) {
              ratings.add(
                RatingPointModel(
                  date: DateTime(year, month, day),
                  rating: r.toInt(),
                  platform: 'CC',
                ),
              );
            }
          }
        }

        // Heatmap Activity
        if (data['heatMap'] != null && data['heatMap'] is List) {
          for (var item in data['heatMap']) {
            final dateStr = item['date']?.toString();
            final value = item['value'];
            if (dateStr != null && value != null && value is num) {
              final parsedDate = DateTime.tryParse(dateStr);
              if (parsedDate != null) {
                final count = value.toInt();
                for (int i = 0; i < count; i++) {
                  subs.add(
                    SubmissionModel(
                      problemName: 'CodeChef Problem',
                      platform: 'CC',
                      solvedAt: parsedDate,
                      tags: ['CodeChef'],
                    ),
                  );
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    return PlatformDataBundle(submissions: subs, ratings: ratings);
  }
}