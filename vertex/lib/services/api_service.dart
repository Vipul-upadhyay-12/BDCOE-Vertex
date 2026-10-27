import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vertex/models/contest_model.dart';
import 'package:vertex/models/problem_recommendation_model.dart';
import '../models/submission_model.dart';
import '../models/rating_point_model.dart';
import '../models/platform_bundle_model.dart';

class ApiService {
  // --- VERIFICATION CHECKS ---
  static const String _codeChefBaseUrl = 'https://codechef-api-virid.vercel.app';


  /// Fetch Codeforces problems matching user level & tags
  static Future<List<PracticeProblemModel>> fetchCodeforcesPractice({
    int userRating = 1300,
    String? tag,
  }) async {
    List<PracticeProblemModel> problems = [];
    final minRating = userRating;
    final maxRating = userRating + 300;

    try {
      final queryTag = (tag != null && tag != 'ALL') ? '&tags=$tag' : '';
      final url = 'https://codeforces.com/api/problemset.problems?$queryTag';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 7));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          final List probList = data['result']['problems'] ?? [];

          for (var p in probList) {
            final r = p['rating'];
            if (r is num && r >= minRating && r <= maxRating) {
              final cid = p['contestId']?.toString() ?? '';
              final idx = p['index']?.toString() ?? '';
              final name = p['name']?.toString() ?? 'Problem';
              final rawTags = (p['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];

              problems.add(
                PracticeProblemModel(
                  id: 'CF-$cid$idx',
                  title: '$idx. $name',
                  platform: 'CF',
                  rating: r.toInt(),
                  tags: rawTags,
                  url: 'https://codeforces.com/problemset/problem/$cid/$idx',
                ),
              );

              if (problems.length >= 25) break;
            }
          }
        }
      }
    } catch (_) {}

    return problems;
  }

  /// Fetch AtCoder problems with difficulty from Kenkoooo
  static Future<List<PracticeProblemModel>> fetchAtCoderProblems({
    int targetDiff = 1200,
  }) async {
    List<PracticeProblemModel> problems = [];

    try {
      // Kenkoooo problem models containing difficulty scores
      final res = await http
          .get(Uri.parse('https://kenkoooo.com/atcoder/resources/problem-models.json'))
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final Map<String, dynamic> models = jsonDecode(res.body);

        int count = 0;
        models.forEach((key, val) {
          if (count >= 20) return;
          if (val is Map && val['difficulty'] != null) {
            final diff = (val['difficulty'] as num).toInt();
            // Filter within user's target difficulty window
            if (diff >= targetDiff - 100 && diff <= targetDiff + 250) {
              final parts = key.split('_');
              final contestCode = parts.isNotEmpty ? parts[0].toUpperCase() : 'ABC';
              final problemIndex = parts.length > 1 ? parts[1].toUpperCase() : '';

              problems.add(
                PracticeProblemModel(
                  id: 'AC-$key',
                  title: '$contestCode - Problem $problemIndex',
                  platform: 'AC',
                  rating: diff,
                  tags: ['AtCoder', contestCode],
                  url: 'https://atcoder.jp/contests/${parts[0]}/tasks/$key',
                ),
              );
              count++;
            }
          }
        });
      }
    } catch (_) {}

    return problems;
  }

  static Future<List<ContestModel>> fetchUpcomingContests() async {
    List<ContestModel> contests = [];

    // 1. Codeforces Official Contest List API
    try {
      final cfRes = await http
          .get(Uri.parse('https://codeforces.com/api/contest.list?gym=false'))
          .timeout(const Duration(seconds: 6));

      if (cfRes.statusCode == 200) {
        final data = jsonDecode(cfRes.body);
        if (data['status'] == 'OK' && data['result'] is List) {
          final List list = data['result'];
          final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

          for (var c in list) {
            final startSec = c['startTimeSeconds'];
            final durSec = c['durationSeconds'] ?? 7200;

            if (c['phase'] == 'BEFORE' ||
                (startSec != null && startSec > nowSec - (durSec is num ? durSec.toInt() : 7200))) {
              final id = c['id']?.toString() ?? '';
              final name = c['name']?.toString() ?? 'Codeforces Round';

              if (startSec is num) {
                final startDt = DateTime.fromMillisecondsSinceEpoch(startSec.toInt() * 1000);
                contests.add(
                  ContestModel(
                    id: 'cf_$id',
                    name: name,
                    platform: 'CF',
                    startTime: startDt,
                    duration: Duration(seconds: durSec is num ? durSec.toInt() : 7200),
                    url: "https://codeforces.com/contestRegistration/$id",
                  ),
                );
              }
            }
          }
        }
      }
    } catch (_) {}

    // 2. CodeChef Contests via Vercel Microservice
    try {
      final ccRes = await http
          .get(Uri.parse('$_codeChefBaseUrl/handle/contests'))
          .timeout(const Duration(seconds: 6));

      if (ccRes.statusCode == 200) {
        final data = jsonDecode(ccRes.body);
        if (data['success'] == true && data['contests'] is List) {
          for (var item in data['contests']) {
            final name = item['name']?.toString() ?? 'CodeChef Contest';
            final code = item['code']?.toString() ?? '';
            final isoStr = item['start_date_iso']?.toString() ?? '';
            final durMins = item['duration'] is num ? (item['duration'] as num).toInt() : 120;
            final url = item['url']?.toString() ?? 'https://www.codechef.com/contests';

            final startDt = DateTime.tryParse(isoStr);
            if (startDt != null) {
              contests.add(
                ContestModel(
                  id: 'cc_$code',
                  name: name,
                  platform: 'CC',
                  startTime: startDt.toLocal(),
                  duration: Duration(minutes: durMins),
                  url: url,
                ),
              );
            }
          }
        }
      }
    } catch (_) {}

    // Sort chronologically by earliest round
    contests.sort((a, b) => a.startTime.compareTo(b.startTime));
    return contests;
  }

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

    try {
      final res = await http
          .get(Uri.parse('${_codeChefBaseUrl}/handle/$cleanUser'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
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

    final cleanUser = username.trim();
    if (cleanUser.isEmpty) {
      return PlatformDataBundle(submissions: subs, ratings: ratings);
    }

    // 1. Fetch Official Total Lifetime Solved Count & Difficulty Breakdown
    int totalSolvedFromProfile = 0;
    try {
      final solvedRes = await http
          .get(Uri.parse('https://alfa-leetcode-api.onrender.com/$cleanUser/solved'))
          .timeout(const Duration(seconds: 5));
      if (solvedRes.statusCode == 200) {
        final data = jsonDecode(solvedRes.body);
        if (data['solvedProblem'] != null && data['solvedProblem'] is num) {
          totalSolvedFromProfile = (data['solvedProblem'] as num).toInt();
        }
      }
    } catch (_) {}

    // 2. Fetch Recent AC Problem Titles & Timestamps
    try {
      final acRes = await http
          .get(Uri.parse('https://alfa-leetcode-api.onrender.com/$cleanUser/acSubmission?limit=50'))
          .timeout(const Duration(seconds: 5));

      if (acRes.statusCode == 200) {
        final data = jsonDecode(acRes.body);
        final List? acList = data['submission'];
        if (acList != null) {
          for (var item in acList) {
            final title = item['title']?.toString() ?? '';
            final ts = int.tryParse(item['timestamp']?.toString() ?? '0') ?? 0;

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
    } catch (_) {}

    // 3. If profile solved count is higher than recent feed, add backlog items
    // so total solved count and mastery reflect real career progress
    if (totalSolvedFromProfile > subs.length) {
      final remaining = totalSolvedFromProfile - subs.length;
      for (int i = 0; i < remaining; i++) {
        subs.add(
          SubmissionModel(
            problemName: "Solved LeetCode Problem",
            platform: 'LC',
            solvedAt: DateTime.now().subtract(Duration(days: 30 + i)),
            tags: ['LeetCode'],
          ),
        );
      }
    }

    // 4. Fetch Heatmap Calendar
    try {
      final calRes = await http
          .get(Uri.parse('https://alfa-leetcode-api.onrender.com/$cleanUser/calendar'))
          .timeout(const Duration(seconds: 5));

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
    } catch (_) {}

    // 5. Contest Ratings
    try {
      final contestRes = await http
          .get(Uri.parse('https://alfa-leetcode-api.onrender.com/$cleanUser/contest'))
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

    return PlatformDataBundle(
      submissions: subs,
      ratings: ratings,
      calendarMap: calendarActivity,
    );
  }

  // 3. CodeChef (Powered by Open REST API)
  // Make sure this is your EXACT Vercel domain without a trailing slash


  static Future<PlatformDataBundle> fetchCodeChefData(String username) async {
    List<SubmissionModel> subs = [];
    List<RatingPointModel> ratings = [];
    Map<DateTime, int> calendarActivity = {};

    final cleanUser = username.trim();
    if (cleanUser.isEmpty) {
      return PlatformDataBundle(submissions: subs, ratings: ratings);
    }

    try {
      final targetUri = Uri.parse('$_codeChefBaseUrl/handle/$cleanUser');
      final res = await http.get(targetUri).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['success'] == true) {
          // 1. Current Live Rating
          final cr = data['currentRating'];
          if (cr is num && cr > 0) {
            ratings.add(
              RatingPointModel(
                date: DateTime.now(),
                rating: cr.toInt(),
                platform: 'CC',
              ),
            );
          }

          // 2. Rating History, Heatmap Dates, and Solves Feed
          if (data['ratingData'] is List) {
            for (var item in (data['ratingData'] as List)) {
              final r = item['rating'];
              final y = int.tryParse(item['year']?.toString() ?? '');
              final m = int.tryParse(item['month']?.toString() ?? '');
              final d = int.tryParse(item['day']?.toString() ?? '');
              final name = item['name']?.toString() ?? 'CodeChef Contest';
              final code = item['code']?.toString() ?? 'CC';
              final endDateStr = item['end_date']?.toString() ?? '';

              DateTime contestDate = DateTime.now();
              if (y != null && m != null && d != null) {
                contestDate = DateTime(y, m, d);
              } else if (endDateStr.isNotEmpty) {
                final parsed = DateTime.tryParse(endDateStr);
                if (parsed != null) contestDate = parsed;
              }

              // Timeline graph point
              if (r is num) {
                ratings.add(
                  RatingPointModel(
                    date: contestDate,
                    rating: r.toInt(),
                    platform: 'CC',
                  ),
                );
              }

              // Heatmap calendar point
              final dayKey = DateTime(contestDate.year, contestDate.month, contestDate.day);
              calendarActivity[dayKey] = (calendarActivity[dayKey] ?? 0) + 4;

              // Problem feed card
              subs.add(
                SubmissionModel(
                  problemName: name,
                  platform: 'CC',
                  solvedAt: contestDate,
                  tags: [code],
                ),
              );
            }
          }

          // Optional edge heatmap points if supplied by microservice
          if (data['heatMap'] is List) {
            for (var item in (data['heatMap'] as List)) {
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
        }
      }
    } catch (_) {
      // Fail silently and return empty bundle without interrupting app flow
    }

    return PlatformDataBundle(
      submissions: subs,
      ratings: ratings,
      calendarMap: calendarActivity,
    );
  }

  /// Fetches verified AtCoder submissions via Kenkoooo public API
  static Future<List<SubmissionModel>> fetchAtCoderSubmissions(String handle) async {
    final cleanHandle = handle.trim();
    if (cleanHandle.isEmpty) return [];
    List<SubmissionModel> submissions = [];

    try {
      final url = 'https://kenkoooo.com/atcoder/atcoder-api/v3/user/submissions?user=${Uri.encodeComponent(cleanHandle)}&from_second=0';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);

        for (var item in list) {
          final result = (item['result'] ?? '').toString().toUpperCase();
          if (result == 'AC') {
            final epochSec = (item['epoch_second'] as num?)?.toInt() ?? 0;
            final problemId = item['problem_id']?.toString() ?? 'AtCoder Problem';
            final parts = problemId.split('_');
            final tag = parts.isNotEmpty ? parts[0].toUpperCase() : 'AtCoder';

            submissions.add(
              SubmissionModel(
                problemName: problemId,
                platform: 'AC',
                solvedAt: DateTime.fromMillisecondsSinceEpoch(epochSec * 1000),
                tags: ['AtCoder', tag],
              ),
            );
          }
        }
      }
    } catch (_) {}

    return submissions;
  }

  /// 2. Fetches AtCoder rating progression and current live rating
  static Future<List<RatingPointModel>> fetchAtCoderRatingHistory(String handle) async {
    final cleanHandle = handle.trim();
    if (cleanHandle.isEmpty) return [];
    List<RatingPointModel> points = [];

    try {
      final url = 'https://atcoder.jp/users/${Uri.encodeComponent(cleanHandle)}/history/json';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        for (var item in list) {
          final bool isRated = item['IsRated'] == true;
          if (isRated) {
            final int newRating = (item['NewRating'] as num?)?.toInt() ?? 0;
            final String rawDate = item['EndTime'] ?? '';
            final parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();

            points.add(
              RatingPointModel(
                rating: newRating,
                date: parsedDate,
                platform: 'AC',
              ),
            );
          }
        }
      }
    } catch (_) {}

    return points;
  }
}