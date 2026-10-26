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
    final cleanUser = username.trim();
    if (cleanUser.isEmpty) return false;

    // Fast check via public proxy
    try {
      final res = await http
          .get(Uri.parse('https://codechef-api.vercel.app/$cleanUser'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true || data['currentRating'] != null) return true;
      }
    } catch (_) {}

    return cleanUser.isNotEmpty; // Fallback to allow unrated/new users
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
    Map<DateTime, int> calendarActivity = {};
    Set<String> seenProblemTitles = {};

    // 1. Fetch ONLY Real Solved Problems (NO dummy placeholder items!)
    try {
      final acRes = await http
          .get(Uri.parse('https://alfa-leetcode-api.onrender.com/$username/acSubmission?limit=50'))
          .timeout(const Duration(seconds: 6));

      if (acRes.statusCode == 200) {
        final data = jsonDecode(acRes.body);
        final List? acList = data['submission'];
        if (acList != null) {
          for (var item in acList) {
            final title = item['title']?.toString() ?? '';
            final ts = int.tryParse(item['timestamp']?.toString() ?? '0') ?? 0;

            // Only add distinct, valid solved problems
            if (title.isNotEmpty && ts > 0 && !seenProblemTitles.contains(title)) {
              seenProblemTitles.add(title);
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
    } catch (e) {
      print("LC AC Submissions error: $e");
    }

    // 2. Calendar Map strictly for the Heatmap (NEVER added to subs)
    try {
      final calRes = await http
          .get(Uri.parse('https://alfa-leetcode-api.onrender.com/$username/calendar'))
          .timeout(const Duration(seconds: 6));

      if (calRes.statusCode == 200) {
        final data = jsonDecode(calRes.body);
        final rawCalendar = data['submissionCalendar'];
        if (rawCalendar != null) {
          final Map<String, dynamic> calMap =
              rawCalendar is String ? jsonDecode(rawCalendar) : rawCalendar;

          calMap.forEach((tsStr, count) {
            final ts = int.tryParse(tsStr);
            if (ts != null) {
              final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
              final dayKey = DateTime(date.year, date.month, date.day);
              final val = count is num ? count.toInt() : 1;
              calendarActivity[dayKey] = (calendarActivity[dayKey] ?? 0) + val;
            }
          });
        }
      }
    } catch (e) {
      print("LC Calendar error: $e");
    }

    // 3. Contest Rating
    try {
      final contestRes = await http
          .get(Uri.parse('https://alfa-leetcode-api.onrender.com/$username/contest'))
          .timeout(const Duration(seconds: 6));

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

    return PlatformDataBundle(
      submissions: subs,
      ratings: ratings,
      calendarMap: calendarActivity,
    );
  }

  // 3. CodeChef (Powered by Open REST API)
  static Future<PlatformDataBundle> fetchCodeChefData(String username) async {
    List<SubmissionModel> subs = [];
    List<RatingPointModel> ratings = [];
    Map<DateTime, int> calendarActivity = {};

    final cleanUser = username.trim();
    if (cleanUser.isEmpty) {
      return PlatformDataBundle(submissions: subs, ratings: ratings);
    }

    print("[CodeChef] Starting fetch for handle: $cleanUser");
    bool parsedSuccessfully = false;

    // --- STRATEGY 1: Community Vercel Microservice (Testing both routes) ---
    final apiUrls = [
      'https://codechef-api.vercel.app/$cleanUser',
      'https://codechef-api.vercel.app/handle/$cleanUser',
    ];

    for (final url in apiUrls) {
      if (parsedSuccessfully) break;
      try {
        print("[CodeChef] Attempting API: $url");
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
        print("[CodeChef] API Response status: ${res.statusCode}");

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data is Map && (data['success'] == true || data['currentRating'] != null)) {
            // Current Rating
            final cr = data['currentRating'];
            if (cr != null && cr is num && cr > 0) {
              ratings.add(
                RatingPointModel(
                  date: DateTime.now(),
                  rating: cr.toInt(),
                  platform: 'CC',
                ),
              );
              print("[CodeChef] Found current rating: $cr");
            }

            // Contest History
            if (data['ratingData'] != null && data['ratingData'] is List) {
              for (var item in data['ratingData']) {
                final r = item['rating'];
                final y = int.tryParse(item['year']?.toString() ?? '');
                final m = int.tryParse(item['month']?.toString() ?? '');
                final d = int.tryParse(item['day']?.toString() ?? '');
                if (r != null && r is num && y != null && m != null && d != null) {
                  ratings.add(
                    RatingPointModel(
                      date: DateTime(y, m, d),
                      rating: r.toInt(),
                      platform: 'CC',
                    ),
                  );
                }
              }
              print("[CodeChef] Parsed ${data['ratingData'].length} contest rating points");
            }

            // Heatmap Activity
            if (data['heatMap'] != null && data['heatMap'] is List) {
              for (var item in data['heatMap']) {
                final dateStr = item['date']?.toString();
                final val = item['value'];
                if (dateStr != null && val is num) {
                  final dt = DateTime.tryParse(dateStr);
                  if (dt != null) {
                    final dayKey = DateTime(dt.year, dt.month, dt.day);
                    calendarActivity[dayKey] = (calendarActivity[dayKey] ?? 0) + val.toInt();
                  }
                }
              }
            }

            parsedSuccessfully = true;
          }
        }
      } catch (e) {
        print("[CodeChef] API $url failed: $e");
      }
    }

    // --- STRATEGY 2: AllOrigins JSON Proxy (Live HTML Parser) ---
    if (!parsedSuccessfully) {
      try {
        final profileUrl = 'https://www.codechef.com/users/$cleanUser';
        final proxyUrl =
            'https://api.allorigins.win/get?url=${Uri.encodeComponent(profileUrl)}';
        print("[CodeChef] Falling back to AllOrigins proxy: $proxyUrl");

        final res = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 6));
        if (res.statusCode == 200) {
          final json = jsonDecode(res.body);
          final html = json['contents']?.toString() ?? '';

          if (html.isNotEmpty && !html.contains("User doesn't exist")) {
            print("[CodeChef] HTML received (${html.length} chars). Parsing stats...");

            // 1. Current Rating
            final ratingMatch =
                RegExp(r'class="rating-number"[^>]*>(\d+)', caseSensitive: false)
                    .firstMatch(html);
            if (ratingMatch != null) {
              final r = int.tryParse(ratingMatch.group(1) ?? '0') ?? 0;
              if (r > 0) {
                ratings.add(
                  RatingPointModel(
                    date: DateTime.now(),
                    rating: r,
                    platform: 'CC',
                  ),
                );
                print("[CodeChef] HTML parsed rating: $r");
              }
            } else {
              print("[CodeChef] User appears to be unrated on CodeChef.");
            }

            // 2. Extract Solved Problems
            // Matches problem links like /status/FLOW001,dank_ladka
            final problemRegex = RegExp(
              r'href="/status/([A-Za-z0-9_]+),\s*' + RegExp.escape(cleanUser),
              caseSensitive: false,
            );
            final matches = problemRegex.allMatches(html);
            Set<String> uniqueCodes = {};

            for (var m in matches) {
              final code = m.group(1);
              if (code != null && !uniqueCodes.contains(code)) {
                uniqueCodes.add(code);
                subs.add(
                  SubmissionModel(
                    problemName: code,
                    platform: 'CC',
                    solvedAt: DateTime.now().subtract(Duration(days: uniqueCodes.length)),
                    tags: ['CodeChef'],
                  ),
                );
              }
            }

            // If individual links weren't found, check total solved count
            if (subs.isEmpty) {
              final totalMatch = RegExp(
                r'Total Problems Solved:\s*(\d+)',
                caseSensitive: false,
              ).firstMatch(html);
              if (totalMatch != null) {
                final count = int.tryParse(totalMatch.group(1) ?? '0') ?? 0;
                print("[CodeChef] Found total solved count in HTML: $count");
                for (int i = 0; i < count; i++) {
                  subs.add(
                    SubmissionModel(
                      problemName: "CodeChef Problem #${i + 1}",
                      platform: 'CC',
                      solvedAt: DateTime.now().subtract(Duration(days: i + 1)),
                      tags: ['CodeChef'],
                    ),
                  );
                }
              }
            }

            print("[CodeChef] Extracted ${subs.length} solved problems from CodeChef.");
            parsedSuccessfully = true;
          }
        }
      } catch (e) {
        print("[CodeChef] HTML proxy parsing error: $e");
      }
    }

    print("[CodeChef] Completed fetch: ${ratings.length} rating points, ${subs.length} problems.");

    return PlatformDataBundle(
      submissions: subs,
      ratings: ratings,
      calendarMap: calendarActivity,
    );
  }
}