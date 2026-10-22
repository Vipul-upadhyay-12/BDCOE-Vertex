import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isSignUp = false.obs;

  void toggleMode() => isSignUp.value = !isSignUp.value;

  Future<void> signInWithEmail(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Mock network call
    isLoading.value = false;

    // Navigate to link handles on success
    Get.offNamed('/link-handles');
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Mock Google flow
    isLoading.value = false;

    Get.offNamed('/link-handles');
  }

  void signOut() {
    Get.offAllNamed('/auth');
  }
}