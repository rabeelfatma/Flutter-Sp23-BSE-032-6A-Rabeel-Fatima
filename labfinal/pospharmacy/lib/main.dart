import 'package:flutter/material.dart';

// 🔔 Simulated In-App Notification Service
import 'services/notification_service.dart';

// Core
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';

// UI Screens
import 'ui/auth/login_screen.dart';

// Routes
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔔 Initialize simulated notification service
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // ✅ Global Theme
      theme: AppTheme.lightTheme,

      // ✅ Initial Screen (Login first)
      home: const LoginScreen(),

      // ✅ Centralized named routes
      routes: AppRoutes.routes,
    );
  }
}
