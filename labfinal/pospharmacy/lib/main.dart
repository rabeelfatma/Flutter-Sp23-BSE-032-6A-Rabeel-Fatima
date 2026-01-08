import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// 🔔 Notification & Backup Services
import 'services/notification_service.dart';
import 'services/backup_service.dart'; // Auto Backup

// Core
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';

// UI
import 'ui/auth/login_screen.dart';
import 'ui/settings/backup_settings_screen.dart';
import 'ui/settings/backup_history_screen.dart';
import 'ui/settings/restore_screen.dart';

// Routes
import 'routes/app_routes.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/backup_provider.dart'; // ✅ New BackupProvider

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
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<InventoryProvider>(create: (_) => InventoryProvider()),
        ChangeNotifierProvider<BackupProvider>(create: (_) => BackupProvider()), // ✅ BackupProvider
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
      darkTheme: AppTheme.darkTheme,

      home: const LoginScreen(),

      /// ✅ ADD NEW ROUTES FOR BACKUP SCREENS
      routes: {
        ...AppRoutes.routes, // existing routes
        '/backupSettings': (_) => const BackupSettingsScreen(),
        '/backupHistory': (_) => const BackupHistoryScreen(),
        '/restoreScreen': (_) => const RestoreScreen(),
      },
    );
  }
}
