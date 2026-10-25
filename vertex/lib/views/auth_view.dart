import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../core/constants/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/custom_text_field.dart';

class AuthView extends StatelessWidget {
  AuthView({super.key});

  final auth = Get.put(AuthController());
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.terminal_rounded, color: AppColors.primaryGreen, size: 48),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      "CPPRO",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),

                  CustomTextField(controller: emailCtrl, hint: "Email", icon: Icons.email_outlined),
                  const SizedBox(height: 14),
                  CustomTextField(controller: passCtrl, hint: "Password", icon: Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 20),

                  PrimaryButton(
                    label: auth.isSignUp.value ? "Create Account" : "Sign In",
                    isLoading: auth.isLoading.value,
                    onTap: () => auth.signInWithEmail(emailCtrl.text, passCtrl.text),
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: auth.isLoading.value ? null : auth.signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 28),
                    label: const Text("Continue with Google", style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        auth.isSignUp.value ? "Already registered? " : "New to CPPro? ",
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: auth.toggleMode,
                        child: Text(
                          auth.isSignUp.value ? "Sign In" : "Sign Up",
                          style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}