<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/cb29a4f3-7a2a-45b1-b902-ce8991b6a990" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/f3183620-7467-4474-9fa3-69215aaf48a7" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/06464498-b59f-4f5d-8c01-520995866bf2" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/5fece63d-ae7e-47dc-9c8e-0f20c0b9c065" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/e7bf2c90-1d38-4f7c-9b43-9954cd4dbdc0" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/bea1b08e-93a2-439b-90fd-144d0721c4a1" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/e12e95c6-7ce7-4b01-af6b-bddfb75f3620" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/90f9f8fb-bc09-4f6a-8b2c-e70aff55034a" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/5aa9fa47-be21-4fee-ad46-db35f8dfec9a" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/c50cd0dd-5e1a-49bf-8109-cfa5d8391116" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/1f4355eb-45c8-4001-af72-fa2bb8e194ca" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/93bee5f0-f027-4314-92ed-b21e4f81b964" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/95332f6d-46cb-46f0-bcce-623a0842380a" />
<img width="200" height="4000" alt="image" src="https://github.com/user-attachments/assets/07f7b8b2-34b9-47f7-9222-c816320cb7dc" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/6e0362d6-dccb-4c2a-8b11-00c7d28bbc5e" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/bf9fc3c7-3742-41bb-9793-da9e978484b3" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/24193229-380e-462d-8c3e-14ab8c3942e0" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/a5b20ec7-5835-43e1-bbc0-4f9e88e62d29" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/97718e64-3534-4ea2-a421-dea503821e61" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/bddb2082-cfa7-4c1a-961f-242488c548e3" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/9c501a31-1e98-4232-9718-92ec4ce3ee62" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/57d56795-5506-4a5e-ae25-d6cdc17b85eb" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/e1a7d232-a0fe-44eb-b63b-9a048abeb66c" />
<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/c33bb04b-5910-44a7-9e1e-96ca9346028d" />
                              
                              ## projectPOS Inventary Demo Video ##
                             
                https://youtube.com/shorts/vN74a21N18Y?si=F6mpV5yzryp6LxKp //Short video 1 mint 13 secs
                      https://youtu.be/n9jlNdqzBqs?si=U5yvzyDoXzDV62xB // Long video 2 mints 51 secS

                              ## project POS APK ##
                             
                   https://drive.google.com/file/d/1q3OOI5Qw8P-t0KLWTlEO73acIldXoibm/view?usp=drive_link


                               ##Data_Flow_Diagram##
<img width="1062" height="400" alt="image" src="https://github.com/user-attachments/assets/f1ef76e8-a208-405f-8c73-18c5801d05d9" />



























```# pospharmacy
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

POS → Cart → Checkout → Receipt```

Customer → Ledger → Reports

