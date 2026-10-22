import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Check if Codeforces handle exists
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

  // Check if LeetCode user exists
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

  // Check if CodeChef user exists
  static Future<bool> checkCodeChef(String username) async {
    try {
      final res = await http.get(Uri.parse('https://www.codechef.com/users/$username'));
      return res.statusCode == 200 && !res.body.contains("User doesn't exist");
    } catch (_) {
      return false;
    }
  }
}