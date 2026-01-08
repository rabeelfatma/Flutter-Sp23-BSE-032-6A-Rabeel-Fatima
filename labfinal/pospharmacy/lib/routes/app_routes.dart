import 'package:flutter/material.dart';

// Auth
import '../ui/auth/login_screen.dart';
import '../ui/auth/signup_screen.dart';
import '../ui/auth/forgot_password_screen.dart';

// Dashboard
import '../ui/dashboard/dashboard_screen.dart';

// Inventory
import '../ui/inventory/inventory_list_screen.dart';
import '../ui/inventory/add_product_screen.dart';
import '../ui/inventory/edit_product_screen.dart';
import '../ui/inventory/product_detail_screen.dart';

// POS
import '../ui/pos/pos_screen.dart';

// Customers
import '../ui/customers/customer_list_screen.dart';
import '../ui/customers/add_customer_screen.dart';

// Ledger
import '../ui/ledger/ledger_screen.dart';
import '../ui/ledger/add_ledger_entry_screen.dart';
import '../ui/ledger/ledger_detail_screen.dart';

// Reports
import '../ui/reports/reports_home_screen.dart';

// Settings
import '../ui/settings/settings_screen.dart';
import '../ui/settings/backup_settings_screen.dart';
import '../ui/settings/restore_screen.dart';
import '../ui/settings/account_screen.dart';
import '../ui/settings/profile_edit_screen.dart';
import '../ui/settings/change_password_screen.dart';
import '../ui/settings/notification_settings_screen.dart';
import '../ui/settings/backup_history_screen.dart';

// Models
import '../models/product_model.dart';
import '../models/ledger_model.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    // Auth
    '/login': (_) => const LoginScreen(),
    '/signup': (_) => const SignupScreen(),
    '/forgot-password': (_) => const ForgotPasswordScreen(),

    // Dashboard
    '/dashboard': (_) => const DashboardScreen(),

    // POS
    '/pos': (_) => const POSScreen(),

    // Inventory
    '/inventory': (_) => const InventoryListScreen(),
    '/add-product': (_) => const AddProductScreen(),

    // Customers
    '/customers': (_) => const CustomerListScreen(),
    '/add-customer': (_) => const AddCustomerScreen(),

    // Ledger
    '/ledger': (_) => const LedgerScreen(),
    '/add-ledger-entry': (_) => const AddLedgerEntryScreen(),

    // Reports
    '/reports': (_) => const ReportsHomeScreen(),

    // Settings
    '/settings': (_) => const SettingsScreen(),
    '/backup-settings': (_) => const BackupSettingsScreen(),
    '/restore-settings': (_) => const RestoreScreen(),
    '/backup-history': (_) => const BackupHistoryScreen(),
    '/account': (_) => const AccountScreen(),
    '/profile-edit': (_) => const ProfileEditScreen(),
    '/change-password': (_) => const ChangePasswordScreen(),
    '/notification-settings': (_) => const NotificationSettingsScreen(),
  };

  // Dynamic routes with arguments
  static Route<dynamic> editProduct(ProductModel product) {
    return MaterialPageRoute(
      builder: (_) => EditProductScreen(product: product),
    );
  }

  static Route<dynamic> productDetail(ProductModel product) {
    return MaterialPageRoute(
      builder: (_) => ProductDetailScreen(product: product),
    );
  }

  static Route<dynamic> ledgerDetail(LedgerModel entry) {
    return MaterialPageRoute(
      builder: (_) => LedgerDetailScreen(entry: entry),
    );
  }
}
