import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

// This is the core database helper class. It manages task and subtask tables
// and handles database creation and upgrades.
class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _db;
  // CRITICAL CHANGE: Keeping the version at 3, as it matches the current required schema
  static const int _databaseVersion = 3;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('task_mgmt.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    String path;
    try {
      if (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        path = join(documentsDirectory.path, fileName);
      } else {
        // Fallback for non-standard platforms or when path_provider fails
        path = join(await getDatabasesPath(), fileName);
      }
    } on MissingPluginException {
      // Fallback if path_provider fails
      path = join(await getDatabasesPath(), fileName);
    } catch (e) {
      // Fallback for other errors
      path = join(await getDatabasesPath(), fileName);
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable foreign keys for referential integrity
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Helper function to check if a column exists and add it if missing
  Future<void> _addMissingColumn(Database db, String tableName, String columnName, String definition) async {
    try {
      final tableInfo = await db.rawQuery("PRAGMA table_info($tableName);");
      final hasColumn = tableInfo.any((col) => col['name'] == columnName);
      if (!hasColumn) {
        await db.execute("ALTER TABLE $tableName ADD COLUMN $columnName $definition;");
      }
    } catch (e) {
      // Ignore errors if table doesn't exist yet (shouldn't happen in _onUpgrade)
    }
  }

  // Logic to handle database structure changes across versions
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Version 2: Adds 'completionTime'
    if (oldVersion < 2) {
      await _addMissingColumn(db, 'tasks', 'completionTime', 'TEXT');
    }

    // Version 3: Adds Task status (status and claimedBy were added here)
    if (oldVersion < 3) {
      // Updated default to 'In Progress' for consistency with front end
      await _addMissingColumn(db, 'tasks', 'status', "TEXT DEFAULT 'In Progress'");
      await _addMissingColumn(db, 'tasks', 'claimedBy', 'TEXT');
    }
    // Note: Version 4 upgrade logic is intentionally removed here.
  }

  // Initial table creation (Version 3 Schema)
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      dueDate INTEGER, -- Store as Unix timestamp (millisecondsSinceEpoch / 1000)
      dueTime TEXT,
      priority INTEGER DEFAULT 0,
      repeatRule TEXT,
      customDays TEXT,
      isCompleted INTEGER DEFAULT 0,
      notificationId INTEGER,
      soundAsset TEXT DEFAULT 'bell.mp3',
      completionTime TEXT,
      status TEXT DEFAULT 'In Progress', -- Aligned with Task model default
      claimedBy TEXT 
      -- Removed: startDate, googleSheetLink, fileAttachmentPath, isAutoComplete
    );
    ''');

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
  // --- End of Init Functions ---

  // ---------------- Task CRUD ----------------
  Future<int> insertTask(Map<String, dynamic> row) async {
    final db = await database;
    final cleanedRow = Map<String, dynamic>.from(row);

    cleanedRow.removeWhere((key, value) => value == null);

    if (!cleanedRow.containsKey('status')) {
      cleanedRow['status'] = 'In Progress'; // Default set here
    }

    return await db.insert('tasks', cleanedRow, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateTask(int id, Map<String, dynamic> row) async {
    final db = await database;
    // Note: Main.dart will handle passing the correct status/isCompleted state
    return await db.update('tasks', row, where: 'id = ?', whereArgs: [id]);
  }

  // NEW METHOD: To correctly handle status and final state updates from main.dart
  Future<int> updateTaskStatus(int id, String newStatusName) async {
    final db = await database;
    final Map<String, dynamic> updateMap = {'status': newStatusName};

    // Determine the state of 'isCompleted' based on the status name
    final isFinalState = ['Completed', 'Failed', 'Aborted'].contains(newStatusName);

    updateMap['isCompleted'] = isFinalState ? 1 : 0;
    updateMap['completionTime'] = newStatusName == 'Completed' ? DateTime.now().toIso8601String() : null;

    // Note: Delayed/In Progress will set isCompleted to 0, which is correct for active tasks.

    return await db.update(
      'tasks',
      updateMap,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // completeTask updated for robust recurrence handling
  Future<int> completeTask(int id) async {
    final db = await database;
    final String currentTime = DateTime.now().toIso8601String();
    final taskMap = await getTaskById(id);
    if (taskMap == null) return 0;

    final String? repeatRule = taskMap['repeatRule'] as String?;
    final int? oldDueDateTimestamp = taskMap['dueDate'] as int?;

    // Default map for a non-recurring task completion
    final Map<String, dynamic> updateMap = {
      'completionTime': currentTime,
      'status': 'Completed',
      'isCompleted': 1,
      'dueDate': oldDueDateTimestamp, // Keep old date if not repeating
    };

    // Handle Recurring Task Logic: If repeating, calculate next due date
    if (repeatRule != null && repeatRule != 'None' && oldDueDateTimestamp != null) {
      DateTime nextDueDate = DateTime.fromMillisecondsSinceEpoch(oldDueDateTimestamp * 1000);
      DateTime now = DateTime.now();

      // Find the next occurrence time slot (must be >= today's date)
      // Note: The notification service handles complex day-of-week logic for scheduling.
      // This simple loop ensures the DB date moves forward for the next cycle.
      while (nextDueDate.isBefore(now.subtract(const Duration(hours: 1)))) {
        if (repeatRule == 'Daily') {
          nextDueDate = nextDueDate.add(const Duration(days: 1));
        } else if (repeatRule == 'Weekly' || repeatRule == 'CustomDay') {
          // Move weekly/custom day by 7 days to ensure the day of week remains the same
          nextDueDate = nextDueDate.add(const Duration(days: 7));
        } else if (repeatRule == 'Monthly') {
          // Calculate next month correctly
          nextDueDate = DateTime(nextDueDate.year, nextDueDate.month + 1, nextDueDate.day);
        } else {
          break; // Exit if rule is unknown
        }
      }

      // If recurring, reset the status and update the due date
      // CRITICAL FIX: Store date back as Unix timestamp for consistency
      updateMap['dueDate'] = nextDueDate.millisecondsSinceEpoch ~/ 1000;
      updateMap['isCompleted'] = 0;
      updateMap['completionTime'] = currentTime; // Mark this cycle as done now
      updateMap['status'] = 'In Progress'; // Reset status for the next cycle
    }

    return await db.update(
      'tasks',
      updateMap,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // resetTaskStatus updated to use 'In Progress' status
  Future<int> resetTaskStatus(int id) async {
    final db = await database;
    return await db.update(
      'tasks',
      {
        'isCompleted': 0,
        'completionTime': null,
        'status': 'In Progress', // Setting to In Progress is safer than Pending on reset
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // getDashboardCounts updated to align with TaskBoard Pro categories
  Future<Map<String, Map<String, int>>> getDashboardCounts() async {
    final db = await database;
    // Get Unix timestamp for start of day (midnight)
    final nowTimestamp = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch ~/ 1000;
    // Get Unix timestamp for start of month
    final startOfMonthTimestamp = DateTime(DateTime.now().year, DateTime.now().month, 1).millisecondsSinceEpoch ~/ 1000;


    // A function to run queries for both ALL and MONTHLY counts
    Future<Map<String, int>> _getCounts(bool isMonthly) async {
      final counts = <String, int>{
        'InProgress': 0, 'Delayed': 0, 'Completed': 0, 'Failed': 0, 'Aborted': 0
      };

      final monthlyCondition = isMonthly
          ? ' AND (dueDate >= $startOfMonthTimestamp OR completionTime LIKE "${DateFormat('yyyy-MM-').format(DateTime.now())}%")'
          : '';

      // 1. In Progress (Active/Pending) - Not completed, not failed, not aborted, not delayed
      final inProgressResult = await db.rawQuery(
        "SELECT COUNT(*) as count FROM tasks WHERE status IN ('In Progress') AND isCompleted = 0 $monthlyCondition",
      );
      counts['InProgress'] = Sqflite.firstIntValue(inProgressResult) ?? 0;

      // 2. Delayed (Auto Overdue based on dueDate and NOT a final status)
      final delayedAutoResult = await db.rawQuery(
        """
          SELECT COUNT(*) as count FROM tasks 
          WHERE dueDate IS NOT NULL 
          AND dueDate < $nowTimestamp
          AND status NOT IN ('Completed', 'Failed', 'Aborted') 
          AND isCompleted = 0
          $monthlyCondition
        """,
      );
      // NOTE: Delayed status is derived in main.dart; here we just check for overdue tasks that aren't marked as final.
      counts['Delayed'] = Sqflite.firstIntValue(delayedAutoResult) ?? 0;

      // 3. Completed
      final completedResult = await db.rawQuery("SELECT COUNT(*) as count FROM tasks WHERE isCompleted = 1 $monthlyCondition");
      counts['Completed'] = Sqflite.firstIntValue(completedResult) ?? 0;

      // 4. Failed
      final failedResult = await db.rawQuery("SELECT COUNT(*) as count FROM tasks WHERE status = 'Failed' AND isCompleted = 0 $monthlyCondition");
      counts['Failed'] = Sqflite.firstIntValue(failedResult) ?? 0;

      // 5. Aborted
      final abortedResult = await db.rawQuery("SELECT COUNT(*) as count FROM tasks WHERE status = 'Aborted' AND isCompleted = 0 $monthlyCondition");
      counts['Aborted'] = Sqflite.firstIntValue(abortedResult) ?? 0;

      return counts;
    }

    final allTimeCounts = await _getCounts(false);
    final monthlyCounts = await _getCounts(true);

    return {'All': allTimeCounts, 'Monthly': monthlyCounts};
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
    // Order by priority and due date
    return await db.query(
      'tasks',
      orderBy: 'priority DESC, dueDate IS NULL, dueDate ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getCompletedTasks() async {
    final db = await database;
    return await db.query(
      'tasks',
      where: "isCompleted = 1",
      orderBy: 'completionTime DESC',
    );
  }
  // --- Task Progress Method ---
  Future<Map<String, int>> getTaskProgress() async {
    final db = await database;
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM tasks');
    final totalTasks = Sqflite.firstIntValue(totalResult) ?? 0;
    final completedResult = await db.rawQuery("SELECT COUNT(*) as count FROM tasks WHERE isCompleted = 1");
    final completedTasks = Sqflite.firstIntValue(completedResult) ?? 0;
    return {
      'total': totalTasks,
      'completed': completedTasks,
    };
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // NEW: Advanced Task Filtering function for TaskFilterScreen
  Future<List<Map<String, dynamic>>> getTasksByFilter(Map<String, dynamic> filters) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];
    final nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    filters.forEach((key, value) {
      if (key == 'status') {
        conditions.add('status = ?');
        args.add(value);
      } else if (key == 'isNotFinal' && value == 1) {
        // Active/In Progress only (excluding all final states)
        conditions.add("status NOT IN (?, ?, ?)");
        args.addAll(['Completed', 'Failed', 'Aborted']);
      } else if (key == 'isDueToday' && value == 1) {
        // Tasks due today or overdue
        final todayMidnightTimestamp = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch ~/ 1000;
        conditions.add("dueDate IS NOT NULL AND dueDate <= ?");
        args.add(todayMidnightTimestamp);
      } else if (key == 'isRepeating' && value == 1) {
        conditions.add("repeatRule IS NOT NULL AND repeatRule != 'None'");
      } else if (key == 'isCompleted' && value == 1) {
        conditions.add("isCompleted = 1");
      } else if (key == 'isDelayed' && value == 1) {
        // Delayed: Auto Overdue tasks that are NOT in a final state
        conditions.add("dueDate IS NOT NULL AND dueDate < ? AND status NOT IN (?, ?, ?)");
        args.add(nowTimestamp);
        args.addAll(['Completed', 'Failed', 'Aborted']);
      }
    });

    final whereClause = conditions.isEmpty ? null : conditions.join(' AND ');
    return await db.query(
      'tasks',
      where: whereClause,
      whereArgs: args,
      orderBy: 'priority DESC, dueDate IS NULL, dueDate ASC',
    );
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

  Future<int> updateSubtask(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('subtasks', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSubtask(int id) async {
    final db = await database;
    return await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }
  /// Gets a list of tasks filtered by their status.
  Future<List<Map<String, dynamic>>> getTasksByStatus(String status) async {
    final db = await instance.database;
    return await db.query(
      'tasks', // Make sure this is your table name
      where: 'status = ?',
      whereArgs: [status], // Filters tasks by the provided status
    );
  }
  /// Marks a task as completed in the database.
  Future<void> markTaskCompleted(int id) async {
    final db = await instance.database;
    await db.update(
      'tasks',
      {
        'isCompleted': 1, // Set to true
        'status': 'Completed', // Update the status text
        'completionTime': DateTime.now().toIso8601String() // Record when it was completed
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}