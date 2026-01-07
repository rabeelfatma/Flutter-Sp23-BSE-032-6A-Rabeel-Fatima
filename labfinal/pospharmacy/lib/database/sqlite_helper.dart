import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteHelper {
  static Database? _database;

  /// Singleton database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize DB
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pospharmacy.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create tables
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        stock INTEGER,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item TEXT,
        amount REAL,
        customer_id INTEGER,
        datetime TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        phone TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ledger(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        amount REAL,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE backups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filename TEXT,
        created_at TEXT
      )
    ''');
  }

  // ---------------- PRODUCTS ----------------
  static Future<int> insertProduct(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('products', row);
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return db.query('products');
  }

  static Future<int> updateProduct(int id, Map<String, dynamic> row) async {
    final db = await database;
    return db.update('products', row, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedProducts() async {
    final db = await database;
    return db.query('products', where: 'synced = 0');
  }

  static Future<int> markProductAsSynced(int id) async {
    final db = await database;
    return db.update('products', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  /// Update stock after sale
  static Future<int> updateProductStock(int productId, int newStock) async {
    final db = await database;
    return db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // ---------------- SALES ----------------
  static Future<int> insertSale(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('sales', row);
  }

  static Future<List<Map<String, dynamic>>> getSales() async {
    final db = await database;
    return db.query('sales', orderBy: 'datetime DESC');
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedSales() async {
    final db = await database;
    return db.query('sales', where: 'synced = 0');
  }

  static Future<int> markSaleAsSynced(int id) async {
    final db = await database;
    return db.update('sales', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- CUSTOMERS ----------------
  static Future<int> insertCustomer(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('customers', row);
  }

  static Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await database;
    return db.query('customers', orderBy: 'name ASC');
  }

  static Future<int> deleteCustomer(int id) async {
    final db = await database;
    return db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getCustomerHistory(int customerId) async {
    final db = await database;
    return db.query('sales', where: 'customer_id = ?', whereArgs: [customerId]);
  }

  // ---------------- LEDGER ----------------
  static Future<int> insertLedgerEntry(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('ledger', row);
  }

  static Future<List<Map<String, dynamic>>> getLedgerEntries() async {
    final db = await database;
    return db.query('ledger', orderBy: 'date DESC');
  }

  static Future<int> updateLedgerEntry(int id, Map<String, dynamic> row) async {
    final db = await database;
    return db.update('ledger', row, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteLedgerEntry(int id) async {
    final db = await database;
    return db.delete('ledger', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- BACKUPS ----------------
  static Future<int> insertBackup(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('backups', row);
  }

  static Future<List<Map<String, dynamic>>> getBackups() async {
    final db = await database;
    return db.query('backups', orderBy: 'created_at DESC');
  }
}
