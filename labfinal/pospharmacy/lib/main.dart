import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// 🔔 Notification Service
import 'services/notification_service.dart';
import 'services/backup_service.dart'; // <-- Auto Backup import

// Core
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';

// UI
import 'ui/auth/login_screen.dart';

// Routes
import 'routes/app_routes.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart'; // <-- Added CartProvider

// Firebase
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();

  // 🔥 AUTO BACKUP AT APP STARTUP
  await BackupService().autoBackupOnStartup();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<CartProvider>( // <-- Added CartProvider
          create: (_) => CartProvider(),
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      /// 🔥 THEME FIX
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: ThemeData.dark(),

      home: const LoginScreen(),
      routes: AppRoutes.routes,
    );
  }
}
