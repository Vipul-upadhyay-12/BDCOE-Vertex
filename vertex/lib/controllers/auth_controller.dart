import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  var isLoading = false.obs;
  var isSignUp = false.obs; // Toggle between Sign In and Sign Up
  var currentUser = Rxn<User>();

  bool get isAuthenticated => currentUser.value != null;
  RxBool get isLoggedIn => (currentUser.value != null).obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(_auth.authStateChanges());
  }

  void toggleAuthMode() {
    isSignUp.toggle();
  }

  /// Handles Email/Password Authentication (Sign In & Sign Up)
  Future<void> signInWithEmail(String email, String password) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      Get.snackbar(
        "Required Fields",
        "Please enter both email and password.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: Colors.redAccent,
      );
      return;
    }

    try {
      isLoading.value = true;

      if (isSignUp.value) {
        // Register new account
        final cred = await _auth.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: cleanPassword,
        );
        currentUser.value = cred.user;
        Get.snackbar(
          "Account Created",
          "Welcome to CPPro!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surfaceElevated,
          colorText: AppColors.primaryGreen,
        );
      } else {
        // Log in to existing account
        final cred = await _auth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: cleanPassword,
        );
        currentUser.value = cred.user;
        Get.snackbar(
          "Welcome Back",
          "Signed in successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surfaceElevated,
          colorText: AppColors.primaryGreen,
        );
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        isSignUp.value ? "Registration Error" : "Sign In Error",
        e.message ?? "Authentication failed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: Colors.redAccent,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong. Please check your credentials.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Triggers native Google Sign-In prompt
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      currentUser.value = userCredential.user;

      Get.snackbar(
        "Welcome!",
        "Signed in as ${currentUser.value?.displayName ?? 'Coder'}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.primaryGreen,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Google Sign-In Error",
        e.message ?? "Failed to authenticate with Google",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: Colors.redAccent,
      );
    } catch (_) {
      Get.snackbar(
        "Sign-In Failed",
        "Could not establish Google session.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Signs out of Firebase and Google
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _googleSignIn.signOut();
      await _auth.signOut();
      currentUser.value = null;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}