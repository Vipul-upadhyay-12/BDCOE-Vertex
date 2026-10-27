import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';
import 'controllers/platform_controller.dart';
import 'services/notification_service.dart';
import 'views/main_shell_view.dart';
import 'views/auth_view.dart';
import 'core/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local cache first
  try {
    await GetStorage.init();
  } catch (e) {
    debugPrint("GetStorage init error: $e");
  }

  // 2. Initialize Firebase safely
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error (check google-services.json & plugin): $e");
  }

  // 3. Initialize Notifications safely
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint("NotificationService init error: $e");
  }

  // 4. Register global controllers
  Get.put(AuthController(), permanent: true);
  Get.put(PlatformController(), permanent: true);

  // 5. Mount root application
  runApp(const CPProApp());
}

class CPProApp extends StatelessWidget {
  const CPProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'CPPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkEmeraldTheme,
      home: Obx(() => auth.currentUser.value != null
          ? MainShellView()
          : AuthView()),
    );
  }
}