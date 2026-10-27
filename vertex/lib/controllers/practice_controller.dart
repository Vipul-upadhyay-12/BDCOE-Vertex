import 'package:get/get.dart';
import '../models/problem_recommendation_model.dart';
import '../services/api_service.dart';
import 'dashboard_controller.dart';

class PracticeController extends GetxController {
  var isLoading = false.obs;
  var problems = <PracticeProblemModel>[].obs;
  var upsolveProblems = <PracticeProblemModel>[].obs;

  var selectedPlatform = 'ALL'.obs; // 'ALL', 'CF', 'AC'
  var selectedTopic = 'ALL'.obs;

  final List<String> topics = [
    'ALL',
    'dp',
    'graphs',
    'trees',
    'number theory',
    'greedy',
    'binary search',
    'data structures',
    'math',
  ];

  @override
  void onInit() {
    super.onInit();
    loadPracticeProblems();
  }

  int get effectiveUserRating {
    // Read user's rating from DashboardController if available
    try {
      final dash = Get.find<DashboardController>();
      if (dash.peakRating.value > 0) return dash.peakRating.value;
    } catch (_) {}
    return 1300; // baseline default
  }

  Future<void> loadPracticeProblems() async {
    isLoading.value = true;
    List<PracticeProblemModel> list = [];

    final rating = effectiveUserRating;

    // 1. Codeforces Recommendations
    if (selectedPlatform.value == 'ALL' || selectedPlatform.value == 'CF') {
      final cfProbs = await ApiService.fetchCodeforcesPractice(
        userRating: rating,
        tag: selectedTopic.value == 'ALL' ? null : selectedTopic.value,
      );
      list.addAll(cfProbs);
    }

    // 2. AtCoder (Kenkoooo) Recommendations
    if (selectedPlatform.value == 'ALL' || selectedPlatform.value == 'AC') {
      final acProbs = await ApiService.fetchAtCoderProblems(targetDiff: rating);
      list.addAll(acProbs);
    }

    // Shuffle slightly to give fresh options on refresh
    list.shuffle();
    problems.assignAll(list);

    // Mock/extract upsolving queue from latest contested problems
    _buildUpsolvingQueue(rating);

    isLoading.value = false;
  }

  void _buildUpsolvingQueue(int baseRating) {
    upsolveProblems.assignAll([
      PracticeProblemModel(
        id: 'CF-2032C',
        title: 'C. Trinity',
        platform: 'CF',
        rating: baseRating + 150,
        tags: ['greedy', 'sortings', 'two pointers'],
        url: 'https://codeforces.com/contest/2032/problem/C',
        isUpsolve: true,
      ),
      PracticeProblemModel(
        id: 'CC-START261D_P3',
        title: 'Problem 3 (Missed in Starters 261)',
        platform: 'CC',
        rating: baseRating + 100,
        tags: ['CodeChef', 'Upsolve'],
        url: 'https://www.codechef.com',
        isUpsolve: true,
      ),
    ]);
  }

  void setPlatform(String plat) {
    selectedPlatform.value = plat;
    loadPracticeProblems();
  }

  void setTopic(String t) {
    selectedTopic.value = t;
    loadPracticeProblems();
  }
}