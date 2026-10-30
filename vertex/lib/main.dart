import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';
import 'controllers/platform_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/contest_controller.dart';
import 'services/notification_service.dart';
import 'views/main_shell_view.dart';
import 'views/auth_view.dart';
import 'core/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await Firebase.initializeApp();
  await NotificationService().init();

  Get.put(AuthController(), permanent: true);
  Get.put(PlatformController(), permanent: true);
  Get.put(ContestController(), permanent: true);
  Get.put(DashboardController(), permanent: true);

  runApp(const CPProApp());
}

class CPProApp extends StatelessWidget {
  const CPProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'vertex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkEmeraldTheme,

      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            if (Get.isSnackbarOpen) {
              Get.closeCurrentSnackbar();
            }
          },
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: Obx(() => auth.currentUser.value != null
          ? MainShellView()
          : AuthView()),
    );
  }
}