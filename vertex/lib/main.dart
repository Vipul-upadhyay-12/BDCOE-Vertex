import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/constants/app_colors.dart';
import 'controllers/platform_controller.dart';
import 'controllers/auth_controller.dart';
import 'views/auth_view.dart';
import 'views/link_handles_view.dart';
import 'views/dashboard_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register controllers permanently so they never disappear on screen transitions
  Get.put(PlatformController(), permanent: true);
  Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CPPRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primaryGreen,
      ),
      initialRoute: '/auth',
      getPages: [
        GetPage(name: '/auth', page: () => AuthView()),
        GetPage(name: '/link-handles', page: () => LinkHandlesView()),
        GetPage(name: '/dashboard', page: () => DashboardView()),
      ],
    );
  }
}