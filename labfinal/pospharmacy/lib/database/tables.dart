class Tables {
  static const String products = '''
  CREATE TABLE products(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    price REAL,
    stock INTEGER,
    synced INTEGER DEFAULT 0
  )
  ''';

  static const String sales = '''
  CREATE TABLE sales(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    item TEXT,
    amount REAL,
    customer_id INTEGER,
    datetime TEXT,
    synced INTEGER DEFAULT 0
  )
  ''';

  static const String customers = '''
  CREATE TABLE customers(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT,
    phone TEXT
  )
  ''';

  static const String ledger = '''
  CREATE TABLE ledger(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    description TEXT,
    amount REAL,
    date TEXT
  )
  ''';

  static const String backups = '''
  CREATE TABLE backups(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT,
    created_at TEXT
  )
  ''';
}
