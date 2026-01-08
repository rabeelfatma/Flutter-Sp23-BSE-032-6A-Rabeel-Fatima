import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// 🔔 Simulated In-App Notification Service
import 'services/notification_service.dart';

// Core
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';

// UI Screens
import 'ui/auth/login_screen.dart';

// Routes
import 'routes/app_routes.dart';

// Providers
import 'providers/auth_provider.dart';

// 🔥 Firebase Options
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔔 Initialize simulated notification service
  await NotificationService().init();

  // ✅ Wrap app with Provider(s)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: AppRoutes.routes,
    );
  }
}


