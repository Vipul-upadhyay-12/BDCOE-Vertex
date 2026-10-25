import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/constants/app_colors.dart';
import 'views/auth_view.dart';
import 'views/link_handles_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CPPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primaryGreen,
      ),
      initialRoute: '/auth',
      getPages: [
        GetPage(name: '/auth', page: () => AuthView()),
        GetPage(name: '/link-handles', page: () => LinkHandlesView()),
        // Upcoming: GetPage(name: '/dashboard', page: () => DashboardView()),
      ],
    );
  }
}