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
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sku TEXT,
        name TEXT,
        price REAL,
        cost REAL,
        category TEXT,
        stock INTEGER,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        change INTEGER,
        type TEXT,  -- in/out
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        customer_id INTEGER,
        datetime TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER,
        product_id INTEGER,
        quantity INTEGER,
        price REAL
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
        date TEXT,
        type TEXT DEFAULT "debit"
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

  /// Handle upgrades
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ledger ADD COLUMN type TEXT DEFAULT "debit"',
      );
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sale_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_id INTEGER,
          product_id INTEGER,
          quantity INTEGER,
          price REAL
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS stock_history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER,
          change INTEGER,
          type TEXT,
          date TEXT
        )
      ''');
    }
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

  static Future<int> updateProductStock(int productId, int newStock) async {
    final db = await database;
    return db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // ---------------- STOCK HISTORY ----------------
  static Future<int> insertStockHistory(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('stock_history', row);
  }

  static Future<List<Map<String, dynamic>>> getStockHistory(int productId) async {
    final db = await database;
    return db.query(
      'stock_history',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'date DESC',
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

  static Future<int> insertSaleItem(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('sale_items', row);
  }

  static Future<List<Map<String, dynamic>>> getSaleItemsBySale(int saleId) async {
    final db = await database;
    return db.query('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
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
    return db.query(
      'sales',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'datetime DESC',
    );
  }

  static Future<List<Map<String, dynamic>>> getWalkInSales() async {
    final db = await database;
    return db.query(
      'sales',
      where: 'customer_id IS NULL',
      orderBy: 'datetime DESC',
    );
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

  static Future<double> getOutstandingBalance() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END) AS totalDebit,
        SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END) AS totalCredit
      FROM ledger
    ''');

    double debit = (result[0]['totalDebit'] as num?)?.toDouble() ?? 0;
    double credit = (result[0]['totalCredit'] as num?)?.toDouble() ?? 0;
    return debit - credit;
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
