import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class DBHelper {
  // Singleton pattern to ensure only one instance of the DB Helper
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _db;

  // Getter for the database instance
  Future<Database> get database async {
    if (_db != null) return _db!;
    // Initialize the database if it is null
    _db = await _initDB('task_mgmt.db');
    return _db!;
  }

  // Database initialization logic
  Future<Database> _initDB(String fileName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);

    return await openDatabase(
      path,
      version: 2, // Version 2
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {

      try {
        final tableInfo = await db.rawQuery("PRAGMA table_info(tasks);");
        final hasCompletionTime = tableInfo.any((col) => col['name'] == 'completionTime');

        if (!hasCompletionTime) {
          await db.execute("ALTER TABLE tasks ADD COLUMN completionTime TEXT;");
          print("Database updated: Added 'completionTime' column to tasks.");
        }
      } catch (e) {
        print("Error during database upgrade: $e");
      }
    }
  }

  // Create tables when the database is first created
  Future _onCreate(Database db, int version) async {
    // Task Table
    await db.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      dueDate INTEGER,
      dueTime TEXT,
      priority INTEGER DEFAULT 0,
      repeatRule TEXT,
      customDays TEXT,
      isCompleted INTEGER DEFAULT 0,
      notificationId INTEGER,
      soundAsset TEXT DEFAULT 'bell.mp3',
      completionTime TEXT 
    );
    ''');

    // Subtask Table
    await db.execute('''
    CREATE TABLE subtasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      taskId INTEGER NOT NULL,
      title TEXT NOT NULL,
      isDone INTEGER DEFAULT 0,
      FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE
    );
    ''');
  }

  // ---------------- Task CRUD ----------------

  Future<int> insertTask(Map<String, dynamic> row) async {
    final db = await database;
    final cleanedRow = row.map((k, v) => MapEntry(k, v));
    cleanedRow.removeWhere((key, value) => value == null);
    return await db.insert('tasks', cleanedRow, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getTaskById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await database;
    return await db.query(
      'tasks',
      // Order by completion status, priority, and due date
      orderBy: 'isCompleted ASC, priority DESC, dueDate IS NULL, dueDate ASC',
    );
  }


  Future<List<Map<String, dynamic>>> getCompletedTasks() async {
    final db = await database;

    return await db.query(
      'tasks',
      where: 'completionTime IS NOT NULL',
      orderBy: 'completionTime DESC',
    );
  }

  Future<int> updateTask(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('tasks', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> completeTask(int id) async {
    final db = await database;
    final String currentTime = DateTime.now().toIso8601String();

    final taskMap = await getTaskById(id);
    if (taskMap == null) return 0;

    final String? repeatRule = taskMap['repeatRule'] as String?;
    final int? oldDueDateTimestamp = taskMap['dueDate'] as int?;
    DateTime? nextDueDate = oldDueDateTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(oldDueDateTimestamp * 1000) : null;


    final Map<String, dynamic> updateMap = {
      'completionTime': currentTime,
    };
    if (repeatRule != null && repeatRule != 'None') {
      if (nextDueDate != null) {
        DateTime now = DateTime.now();
        while (nextDueDate!.isBefore(now)) {
          if (repeatRule == 'Daily') {
            nextDueDate = nextDueDate.add(const Duration(days: 1));
          } else if (repeatRule == 'Weekly') {
            nextDueDate = nextDueDate.add(const Duration(days: 7));
          } else if (repeatRule == 'Monthly') {
            nextDueDate = DateTime(nextDueDate.year, nextDueDate.month + 1, nextDueDate.day);
          } else if (repeatRule == 'CustomDay') {
            nextDueDate = nextDueDate.add(const Duration(days: 1));
          } else {
            break;
          }
        }
        updateMap['isCompleted'] = 0;
        updateMap['dueDate'] = nextDueDate.millisecondsSinceEpoch ~/ 1000;

      }

    } else {
      updateMap['isCompleted'] = 1;
    }

    return await db.update(
      'tasks',
      updateMap,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<int> resetTaskStatus(int id) async {
    final db = await database;

    return await db.update(
      'tasks',
      {
        'isCompleted': 0,
        'completionTime': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<Map<String, int>> getTaskProgress() async {
    final db = await database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final nextDayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;

    final totalResult = await db.rawQuery(
        '''
        SELECT COUNT(*) FROM tasks 
        WHERE dueDate < ?; 
        ''',
        [nextDayStart]
    );
    final int totalDueTasks = Sqflite.firstIntValue(totalResult) ?? 0;
    final completedResult = await db.rawQuery(
        'SELECT COUNT(*) FROM tasks WHERE completionTime LIKE ?',
        ['$today%']
    );
    final int completedToday = Sqflite.firstIntValue(completedResult) ?? 0;

    return {
      'total': totalDueTasks, // Denominator (e.g., 2)
      'completed': completedToday, // Numerator (e.g., 1)
    };
  }


  // ---------------- Subtask CRUD ----------------

  Future<int> insertSubtask(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('subtasks', row);
  }

  Future<List<Map<String, dynamic>>> getSubtasksForTask(int taskId) async {
    final db = await database;
    return await db.query('subtasks', where: 'taskId = ?', whereArgs: [taskId]);
  }

  Future<int> deleteSubtasksForTask(int taskId) async {
    final db = await database;
    return await db.delete(
      'subtasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
  }

  Future<int> updateSubtask(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('subtasks', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSubtask(int id) async {
    final db = await database;
    return await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }
}