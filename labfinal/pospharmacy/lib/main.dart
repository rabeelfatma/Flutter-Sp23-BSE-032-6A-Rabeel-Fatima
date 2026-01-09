import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // ✅ Required for connectivity checks

// 🔔 Notification & Backup Services
import 'services/notification_service.dart';
import 'services/backup_service.dart'; // Auto Backup

// 🔄 SYNC MANAGER
import 'core/utils/sync_manager.dart'; // ✅ Correct path as per your project

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
import 'providers/backup_provider.dart';

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
        ChangeNotifierProvider<BackupProvider>(create: (_) => BackupProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// 🔥 CHANGED FROM StatelessWidget → StatefulWidget (SYNC NEEDS THIS)
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    // ✅ AUTO SYNC WHEN APP STARTS
    SyncManager.syncAll();

    // ✅ AUTO SYNC WHEN INTERNET RESTORES
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        SyncManager.syncAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      /// 🔥 THEME SETTINGS
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      home: const LoginScreen(),

      /// ✅ ROUTES INCLUDING BACKUP SCREENS
      routes: {
        ...AppRoutes.routes,
        '/backupSettings': (_) => const BackupSettingsScreen(),
        '/backupHistory': (_) => const BackupHistoryScreen(),
        '/restoreScreen': (_) => const RestoreScreen(),
      },
    );
  }
}
