# pospharmacy
Smart POS & Full Inventory Management App – Documentation
1️⃣ Project Overview
Title: Smart POS & Full Inventory Management App
Technology Stack: Flutter (Frontend), Firebase + SQLite (Backend / Offline)
Purpose: To provide a fully functional POS system with offline-first architecture, auto-sync, backup & restore, inventory, sales, customer, and ledger management.
2️⃣ Features & Functional Modules
Module	Features	Implementation
Authentication	Login, Signup, Forgot Password	Firebase Firestore, AuthProvider
Product Management	Add, Edit, Delete products, SKU, Price, Cost, Category	SQLite offline, Firestore online
Inventory Control	Stock in/out, Low stock alerts, Stock history	SQLite + Provider, low-stock dashboard widget
POS (Billing)	Cart, quantity adjust, discounts, taxes, runtime price changes	Provider + SQLite offline + Firestore sync
Customer Management	Walk-in & regular customers, purchase history	SQLite offline + Firestore sync
Ledger System	Debit/Credit, Payments, Outstanding balance	SQLite offline + Firestore sync
Reports	Daily, Monthly, Stock, Customer reports	Charts (fl_chart), Provider, Firestore
Backup System	Manual + Auto Backup, Google Drive Backup, Restore	BackupService, DriveService, NotificationService
Offline Mode	Works without Internet, queues unsynced sales/products	SQLite offline-first architecture
Sync System	Auto Sync on Internet restore, manual sync option	SyncManager + SyncPreference
Profile Management	Update Name, Email, Profile Picture	AuthProvider + Image Picker + local file storage
Theme	Dark Mode toggle	ThemeProvider + Provider
3️⃣ Project Structure
lib/
├── core/
│   ├── constants/ (app colors, strings, theme)
│   └── utils/ (internet_checker, sync_manager, date_utils)
├── models/ (product, sales, customers, ledger, backup)
├── database/ (sqlite_helper, offline_queue, tables)
├── services/ (auth_service, firestore_service, backup_service, drive_service, notification_service)
├── repositories/ (product, sales, customer, ledger)
├── providers/ (auth, cart, inventory, customer, ledger, report)
├── ui/
│   ├── auth/ (login, signup, forgot password)
│   ├── dashboard/ (dashboard screen, charts, low stock widget)
│   ├── inventory/ (inventory list, add/edit product)
│   ├── pos/ (POS screen, cart, checkout, receipt)
│   ├── customers/ (customer list, add, history)
│   ├── ledger/ (ledger list, add entry, details)
│   ├── reports/ (daily, monthly, stock, customer reports)
│   └── settings/ (settings, backup settings, restore screen, account)
├── widgets/ (primary_button, stat_card, sync_indicator, empty_state, confirm_dialog)
├── routes/ (app_routes)

4️⃣ Key Functional Implementations

A. Offline + Online Sync

All data is stored locally in SQLite for offline access.

SyncManager checks Internet connectivity via InternetChecker and syncs unsynced sales, products, and customer data to Firestore.

Auto Sync toggle allows user to enable/disable auto-sync.

B. Backup & Restore

Manual and automatic backups supported.

Local backup stored in device storage (backup.json).

Cloud backup uploaded to Google Drive using DriveService.

Restore supports both local and cloud backups.

Notifications via NotificationService for success/failure.

C. Profile Management

Update name, email (read-only), and profile picture.

Image saved to local storage; path stored in Firestore.

UI updates immediately via AuthProvider reactive state.

D. Reports & Dashboard

Dashboard shows total counts: Products, Sales, Customers, Ledger.

Charts implemented using fl_chart.

Low stock alerts show via LowStockWidget.

Reports generated for daily, monthly, stock, and customers.

E. POS & Inventory Management

Add, Edit, Delete products with SKU, price, category.

Cart system with quantity adjust, discount, and tax calculation.

Checkout saves sale in SQLite offline queue and syncs when online.

5️⃣ Data Flow

User interacts with UI → Provider handles state → SQLite for offline storage.

When online, SyncManager auto-syncs pending changes to Firestore.

BackupService handles local JSON backup → optional DriveService upload.

RestoreService fetches backup → updates SQLite → refreshes UI.

6️⃣ State Management

Provider package used for state management:

AuthProvider → Auth & Profile state

InventoryProvider → Products & stock

CartProvider → POS cart state

CustomerProvider → Customer data

LedgerProvider → Ledger entries

ReportProvider → Report data

7️⃣  Navigation

Settings → Backup Settings → Backup/Restore/Schedule

Dashboard → Counters & Charts

POS → Cart → Checkout → Receipt

Customer → Ledger → Reports
(Include screenshots for GitHub README.)
