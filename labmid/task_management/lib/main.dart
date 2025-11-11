import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'db_helper.dart';
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  Future<void> init() async {}
  Future<int> scheduleNotification({
    required int id, required String title, required String body,
    required DateTime scheduledDate, required String soundAsset,
  }) async => id + 1000;
  Future<void> cancel(int id) async {}
}

Future<int> scheduleAdvancedNotification({
  required int id, required String title, required String body,
  required DateTime scheduledTime, required String soundAsset,
}) async {
  final notifId = await NotificationService.instance.scheduleNotification(
    id: id, title: title, body: body, scheduledDate: scheduledTime, soundAsset: soundAsset,
  );
  return notifId;
}

const List<String> availableSounds = ['bell.mp3', 'chime.mp3', 'soft.mp3'];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MyApp());
}

// ---------------- Models ----------------
class Task {
  int? id;
  String title;
  String? description;
  DateTime? dueDate;
  String? dueTime;
  int priority;
  String? repeatRule;
  List<int>? customDays;
  bool isCompleted;
  int? notificationId;
  String soundAsset;
  String? completionTime; // NEW: Added in previous step

  Task({
    this.id, required this.title, this.description, this.dueDate, this.dueTime,
    this.priority = 0, this.repeatRule, this.customDays, this.isCompleted = false,
    this.notificationId, this.soundAsset = 'bell.mp3', this.completionTime,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'description': description,
    'dueDate': dueDate != null ? (dueDate!.millisecondsSinceEpoch ~/ 1000) : null,
    'dueTime': dueTime, 'priority': priority, 'repeatRule': repeatRule,
    'customDays': customDays?.join(','),
    'isCompleted': isCompleted ? 1 : 0,
    'notificationId': notificationId,
    'soundAsset': soundAsset,
    'completionTime': completionTime, // NEW
  };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
    id: m['id'] as int?, title: m['title'] as String, description: m['description'] as String?,
    dueDate: m['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch((m['dueDate'] as int) * 1000) : null,
    dueTime: m['dueTime'] as String?, priority: m['priority'] ?? 0, repeatRule: m['repeatRule'] as String?,
    customDays: m['customDays'] != null && (m['customDays'] as String).isNotEmpty
        ? (m['customDays'] as String).split(',').map((e) => int.parse(e.trim())).toList() : null,
    isCompleted: (m['isCompleted'] ?? 0) == 1,
    notificationId: m['notificationId'] as int?,
    soundAsset: m['soundAsset'] ?? 'bell.mp3',
    completionTime: m['completionTime'] as String?, // NEW
  );
}

class Subtask {
  int? id;
  int taskId;
  String title;
  bool isDone;

  Subtask({this.id, required this.taskId, required this.title, this.isDone = false});

  Map<String, dynamic> toMap() => {
    'id': id, 'taskId': taskId, 'title': title, 'isDone': isDone ? 1 : 0,
  };

  factory Subtask.fromMap(Map<String, dynamic> m) => Subtask(
    id: m['id'] as int?, taskId: m['taskId'] as int, title: m['title'] as String,
    isDone: (m['isDone'] ?? 0) == 1,
  );
}

// ---------------- Theme & Provider ----------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color primaryColor = Color(0xFF00ADB5);
  static const Color accentColor = Color(0xFFEEEEEE);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightCardColor = Colors.white;
  static const Color lightTextColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(builder: (context, theme, _) {
        final isDark = theme.isDark;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Task Management',
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: isDark ? Brightness.dark : Brightness.light,
              background: isDark ? darkBackgroundColor : lightBackgroundColor,
              surface: isDark ? darkCardColor : lightCardColor,
              primary: primaryColor,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: isDark ? darkBackgroundColor : lightBackgroundColor,
            appBarTheme: const AppBarTheme(
              backgroundColor: primaryColor,
              foregroundColor: lightTextColor,
              elevation: 4,
            ),
            cardTheme: CardThemeData(
              color: isDark ? darkCardColor : lightCardColor,
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: primaryColor,
              foregroundColor: lightTextColor,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: lightTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: primaryColor, width: 2),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
              labelStyle: TextStyle(color: isDark ? accentColor : Colors.grey.shade700),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: isDark ? darkCardColor : Colors.white,
              selectedItemColor: primaryColor,
              unselectedItemColor: isDark ? Colors.grey.shade500 : Colors.black54,
              elevation: 8,
            ),
            checkboxTheme: CheckboxThemeData(
              fillColor: MaterialStateProperty.all(primaryColor),
              checkColor: MaterialStateProperty.all(lightTextColor),
            ),
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: isDark ? accentColor : Colors.black87),
              titleMedium: TextStyle(color: isDark ? accentColor : Colors.black87),
              titleLarge: TextStyle(color: isDark ? accentColor : Colors.black87),
            ),
            iconTheme: IconThemeData(
              color: isDark ? accentColor : Colors.black87,
            ),
          ),
          home: const HomeScreen(),
        );
      }),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;
  void toggle() { _isDark = !_isDark; notifyListeners(); }
}

// ---------------- HomeScreen ----------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final List<Widget> _pages = [
    const TodayTab(),
    const CompletedTab(),
    const RepeatedTab(),
  ];

  // NEW: Future to hold the overall progress data for the header
  Future<Map<String, int>>? _overallProgressFuture;

  @override
  void initState() {
    super.initState();
    _loadOverallProgress();
  }

  // NEW: Function to load overall progress
  void _loadOverallProgress() {
    setState(() {
      _overallProgressFuture = DBHelper.instance.getTaskProgress();
    });
  }

  // --- Utility Functions for Export/Progress ---
  Future<double> _progressFor(Task t, [bool isCompletedTab = false]) async {
    if (isCompletedTab) return 1.0;

    if (t.id == null) return 0.0;
    final rows = await DBHelper.instance.getSubtasksForTask(t.id!);
    if (rows.isEmpty) return 0.0;
    final done = rows.where((r) => (r['isDone'] ?? 0) == 1).length;
    return done / rows.length;
  }

  String _priorityText(int p) => p == 2 ? 'High' : (p == 1 ? 'Medium' : 'Low');

  // Widget to display progress bar and percentage (NEW: Unified function)
  Widget _buildProgressBar(double progress) {
    if (progress >= 0.0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              color: MyApp.primaryColor,
              minHeight: 6,
              backgroundColor: MyApp.primaryColor.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Progress: ${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: MyApp.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  // --- Export and Utility Methods (Same as before) ---

  Future<String> _getDownloadPath() async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      if (dir != null) { return dir.path; }
    }
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<Uint8List> _generatePdfBytes() async {
    final doc = pw.Document();
    final rows = await DBHelper.instance.getAllTasks();
    final data = <List<String>>[
      ['Title', 'Description', 'Due Date', 'Completed']
    ];
    for (var r in rows) {
      final dueDate = r['dueDate'] != null
          ? DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch((r['dueDate'] as int) * 1000)) : 'N/A';
      data.add([r['title'] ?? '', r['description'] ?? '', dueDate, (r['isCompleted'] ?? 0) == 1 ? 'Yes' : 'No']);
    }

    doc.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (ctx) => [
      pw.Header(level: 0, child: pw.Text('Task Management Export')),
      pw.Table.fromTextArray(
        headers: data[0], data: data.sublist(1), border: pw.TableBorder.all(),
      ),
    ]));
    return doc.save();
  }

  Future<void> _handleDownload(String type) async {
    try {
      final path = await _getDownloadPath();
      final prefix = 'tasks_download';
      final fileName = '${prefix}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.$type';
      final file = File(p.join(path, fileName));

      if (type == 'pdf') {
        final bytes = await _generatePdfBytes();
        await file.writeAsBytes(bytes);
      } else if (type == 'csv') {
        final rows = await DBHelper.instance.getAllTasks();
        final list = <List<String>>[];
        list.add(['id', 'title', 'description', 'dueDate', 'dueTime', 'isCompleted']);
        for (var r in rows) {
          final dueDate = r['dueDate'] != null
              ? DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch((r['dueDate'] as int) * 1000)) : '';
          list.add([r['id'].toString(), r['title'] ?? '', r['description'] ?? '', dueDate, r['dueTime'] ?? '', (r['isCompleted'] ?? 0) == 1 ? 'Yes' : 'No',]);
        }
        await file.writeAsString(const ListToCsvConverter().convert(list));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${type.toUpperCase()} file successfully saved to: ${path.split('/').last}/$fileName'),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not download $type: ${e.toString()}')));
      }
    }
  }

  Future<void> _handleShare(String type) async {
    try {
      if (type == 'print_pdf') {
        final bytes = await _generatePdfBytes();
        await Printing.layoutPdf(onLayout: (format) async => bytes);
        return;
      }

      final dir = await getTemporaryDirectory();
      String? path;
      String fileType = type.split('_').last;

      if (fileType == 'pdf') {
        final bytes = await _generatePdfBytes();
        final fileName = 'tasks_share_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
        final file = File(p.join(dir.path, fileName));
        await file.writeAsBytes(bytes);
        path = file.path;
      } else if (fileType == 'csv') {
        final rows = await DBHelper.instance.getAllTasks();
        final list = <List<String>>[];
        list.add(['id', 'title', 'description', 'dueDate', 'dueTime', 'isCompleted']);
        for (var r in rows) {
          final dueDate = r['dueDate'] != null
              ? DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch((r['dueDate'] as int) * 1000)) : '';
          list.add([r['id'].toString(), r['title'] ?? '', r['description'] ?? '', dueDate, r['dueTime'] ?? '', (r['isCompleted'] ?? 0) == 1 ? 'Yes' : 'No',]);
        }
        final fileName = 'tasks_share_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
        final file = File(p.join(dir.path, fileName));
        await file.writeAsString(const ListToCsvConverter().convert(list));
        path = file.path;
      }

      if (path != null) {
        await Share.shareXFiles([XFile(path)], text: 'My exported tasks in ${fileType.toUpperCase()} format.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not share: ${e.toString()}')));
      }
    }
  }
  // --- End of Export and Utility Methods ---

  // FIX: Widget to display overall progress at the top of the body
  Widget _buildOverallProgressHeader() {
    // Only show the header on the Today tab
    if (_index != 0) return const SizedBox.shrink();

    return FutureBuilder<Map<String, int>>(
      future: _overallProgressFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: LinearProgressIndicator(color: MyApp.primaryColor),
          );
        }

        final data = snapshot.data ?? {'total': 0, 'completed': 0};
        final total = data['total']!;
        final completed = data['completed']!;

        // FIX: Use total as the denominator for the progress bar
        final denominator = total;

        final progress = (denominator > 0) ? completed / denominator : 0.0;
        final percentage = (progress * 100).toStringAsFixed(0);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FIX: Display goal correctly using the total tasks due today
                Text(
                  'Today\'s Goal: $completed of $denominator Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                _buildProgressBar(progress), // Use the existing progress bar widget
                Text(
                  'Current Progress: $percentage%',
                  style: const TextStyle(
                    color: MyApp.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleDownload,
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem<String>(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, color: MyApp.primaryColor), SizedBox(width: 8), Text('Download PDF')])),
              PopupMenuItem<String>(value: 'csv', child: Row(children: [Icon(Icons.table_chart, color: MyApp.primaryColor), SizedBox(width: 8), Text('Download CSV')])),
            ],
            icon: const Icon(Icons.download),
            tooltip: 'Download Reports',
            color: Theme.of(context).cardColor,
          ),

          PopupMenuButton<String>(
            onSelected: _handleShare,
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem<String>(value: 'share_pdf', child: Row(children: [Icon(Icons.share, color: MyApp.primaryColor), SizedBox(width: 8), Text('Share PDF')])),
              PopupMenuItem<String>(value: 'share_csv', child: Row(children: [Icon(Icons.table_chart, color: MyApp.primaryColor), SizedBox(width: 8), Text('Share CSV')])),
              PopupMenuItem<String>(value: 'print_pdf', child: Row(children: [Icon(Icons.print, color: MyApp.primaryColor), SizedBox(width: 8), Text('Print PDF')])),
            ],
            icon: const Icon(Icons.share),
            tooltip: 'Share/Print Reports',
            color: Theme.of(context).cardColor,
          ),

          Consumer<ThemeProvider>(builder: (context, theme, _) => IconButton(
            icon: Icon(theme.isDark ? Icons.sunny : Icons.dark_mode),
            onPressed: () => theme.toggle(),
            tooltip: 'Toggle Theme',
          )),
        ],
      ),
      body: Column( // Use Column to place the header above the tab content
        children: [
          _buildOverallProgressHeader(), // NEW: Progress Header
          Expanded(child: _pages[_index]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index, onTap: (i) => setState(() {
        _index = i;
        // Refresh progress only when switching to Today tab or refreshing
        if (i == 0) _loadOverallProgress();
      }),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Completed'),
          BottomNavigationBarItem(icon: Icon(Icons.repeat), label: 'Repeated'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final r = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditPage()));
          if (r == true) {
            // Force reload of all tabs and progress bar if a change was made
            _loadOverallProgress();
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------- Today Tab ----------------
class TodayTab extends StatefulWidget {
  const TodayTab({super.key});
  @override
  State<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  List<Task> _tasks = [];

  // Access utility methods from parent state
  _HomeScreenState get parentState => context.findAncestorStateOfType<_HomeScreenState>()!;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final rows = await DBHelper.instance.getAllTasks();
    final today = DateTime.now();
    final todayDateString = DateFormat('yyyy-MM-dd').format(today); // e.g., '2025-11-11'

    bool isTaskDueToday(Task t) {
      if (t.dueDate == null) return false;

      final todayDateOnly = DateTime(today.year, today.month, today.day);
      final taskDateOnly = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      final isDueTodayOrOverdue = taskDateOnly.isAtSameMomentAs(todayDateOnly) || taskDateOnly.isBefore(todayDateOnly);
      final wasCompletedToday = t.completionTime != null &&
          t.completionTime!.startsWith(todayDateString);

      final isRepeating = t.repeatRule != null && t.repeatRule!.isNotEmpty && t.repeatRule != 'None';

      // --- Non-Repeating Tasks ---
      if (!isRepeating) {
        return isDueTodayOrOverdue && !t.isCompleted;
      }

      // --- Repeating Tasks ---
      if (wasCompletedToday) {
        return false;
      }

      if (t.repeatRule == 'Daily') return true;
      if (t.repeatRule == 'Weekly') {
        return t.dueDate!.weekday == today.weekday;
      }
      if (t.repeatRule == 'Monthly') {
        return t.dueDate!.day == today.day;
      }
      if (t.repeatRule == 'CustomDay' && t.customDays != null) {
        return t.customDays!.contains(today.weekday);
      }

      return false; // Default case
    }

    // Filter tasks due today
    final list = rows.map((r) => Task.fromMap(r)).where((t) => isTaskDueToday(t)).toList();
    list.sort((a, b) => b.priority.compareTo(a.priority));

    setState(() => _tasks = list);
    parentState._loadOverallProgress(); // Refresh overall progress after loading tasks
  }
  void _handleTaskCompletion(Task t, bool isCompleted) async {
    if (isCompleted) {

      await DBHelper.instance.completeTask(t.id!);
      if (t.notificationId != null && (t.repeatRule == null || t.repeatRule == 'None')) {
        try { await NotificationService.instance.cancel(t.notificationId!); } catch (_) {}
      }

    } else {

      await DBHelper.instance.resetTaskStatus(t.id!);
    }
    await _load();
    parentState._loadOverallProgress();
  }


  void _openEditPage(Task t) async {
    final r = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditPage(task: t)));
    if (r == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load, color: MyApp.primaryColor,
      child: _tasks.isEmpty
          ? const Center(child: Text('No tasks due today!', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (c, i) {
          final t = _tasks[i];
          final isRepeating = t.repeatRule != null && t.repeatRule != 'None';
          final todayDateString = DateFormat('yyyy-MM-dd').format(DateTime.now());

          // Check completion status for today
          bool isCompletedForToday = false;
          if (isRepeating) {
            // Repeating: Check if completed today (based on the completionTime field starting with today's date)
            isCompletedForToday = t.completionTime != null && t.completionTime!.startsWith(todayDateString);
          } else {
            // Non-repeating task uses the main isCompleted flag
            isCompletedForToday = t.isCompleted;
          }

          final Color priorityColor = t.priority == 2 ? Colors.redAccent : (t.priority == 1 ? Colors.amber : Colors.green);

          return FutureBuilder<double>(
            // Progress is calculated normally for Today Tab (subtasks only)
            future: parentState._progressFor(t),
            builder: (context, snap) {
              final progress = snap.data ?? 0.0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 8),
                  title: Text(t.title, style: TextStyle(
                    decoration: isCompletedForToday ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  )),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (t.description != null && t.description!.isNotEmpty) Text(t.description!),
                      const SizedBox(height: 8),
                      Text('Priority: ${parentState._priorityText(t.priority)}', style: TextStyle(color: priorityColor, fontWeight: FontWeight.w600)),
                      parentState._buildProgressBar(progress), // Progress Bar
                      Text('Due: ${t.dueDate != null ? DateFormat.yMMMd().format(t.dueDate!) : '—'} ${t.dueTime ?? ''}'),
                      if (isRepeating) Text('Repeats: ${t.repeatRule}', style: const TextStyle(color: MyApp.primaryColor, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // NEW: Checkbox/Complete Button
                      if (isCompletedForToday)
                        IconButton(
                          // Reset Button (Undo Completion)
                          icon: const Icon(Icons.undo, color: Colors.grey),
                          tooltip: 'Undo Completion',
                          onPressed: () => _handleTaskCompletion(t, false),
                        )
                      else
                        IconButton(
                          // Mark Complete Button
                          icon: const Icon(Icons.check_circle, color: MyApp.primaryColor),
                          tooltip: 'Mark Complete',
                          onPressed: () => _handleTaskCompletion(t, true),
                        ),

                      // Delete Button (Original Code)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: 'Delete Task',
                        onPressed: () async {
                          if (t.notificationId != null) { try { await NotificationService.instance.cancel(t.notificationId!); } catch (_) {} }
                          await DBHelper.instance.deleteTask(t.id!);
                          _load();
                        },
                      ),
                    ],
                  ),
                  onTap: () => _openEditPage(t),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------- Completed Tab ----------------
class CompletedTab extends StatefulWidget {
  const CompletedTab({super.key});
  @override
  State<CompletedTab> createState() => _CompletedTabState();
}

class _CompletedTabState extends State<CompletedTab> {
  List<Task> _tasks = [];
  _HomeScreenState get parentState => context.findAncestorStateOfType<_HomeScreenState>()!;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final rows = await DBHelper.instance.getCompletedTasks();
    final list = rows.map((r) => Task.fromMap(r)).toList();
    setState(() => _tasks = list);
    parentState._loadOverallProgress();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load, color: MyApp.primaryColor,
      child: _tasks.isEmpty
          ? const Center(child: Text('No completed tasks yet!', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (c, i) {
          final t = _tasks[i];
          final Color priorityColor = t.priority == 2 ? Colors.redAccent : (t.priority == 1 ? Colors.amber : Colors.green);

          return FutureBuilder<double>(
            future: parentState._progressFor(t, true),
            builder: (context, snap) {
              final progress = snap.data ?? 0.0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(t.title, style: TextStyle(decoration: TextDecoration.lineThrough, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.description ?? ''),
                      const SizedBox(height: 8),
                      // NEW: Show completion time
                      if (t.completionTime != null)
                        Text('Completed: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(t.completionTime!))}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      Text('Priority: ${parentState._priorityText(t.priority)}', style: TextStyle(color: priorityColor, fontWeight: FontWeight.w600)),
                      parentState._buildProgressBar(progress), // Progress Bar (will be 100%)
                    ],
                  ),
                  onTap: () async {
                    final r = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditPage(task: t)));
                    if (r == true) _load();
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // RESET Button (Mark as Uncompleted/Undo)
                      IconButton(
                        icon: const Icon(Icons.undo, color: MyApp.primaryColor), tooltip: 'Mark as Uncompleted',
                        onPressed: () async {
                          await DBHelper.instance.resetTaskStatus(t.id!);

                          _load();
                          parentState._loadOverallProgress();
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent), tooltip: 'Delete Task',
                        onPressed: () async {
                          if (t.notificationId != null) { try { await NotificationService.instance.cancel(t.notificationId!); } catch (_) {} }
                          await DBHelper.instance.deleteTask(t.id!);
                          _load();
                          parentState._loadOverallProgress();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------- Repeated Tab ----------------
class RepeatedTab extends StatefulWidget {
  const RepeatedTab({super.key});
  @override
  State<RepeatedTab> createState() => _RepeatedTabState();
}

class _RepeatedTabState extends State<RepeatedTab> {
  List<Task> _tasks = [];

  // Access utility methods from parent state
  _HomeScreenState get parentState => context.findAncestorStateOfType<_HomeScreenState>()!;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final rows = await DBHelper.instance.getAllTasks();
    final list = rows.map((r) => Task.fromMap(r)).where((t) => t.repeatRule != null && t.repeatRule!.isNotEmpty && t.repeatRule != 'None').toList();
    setState(() => _tasks = list);
    parentState._loadOverallProgress(); // Refresh overall progress
  }

  String _daysToString(List<int> days) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => dayNames[d - 1]).join(', ');
  }

  void _openEditPage(Task t) async {
    final r = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditPage(task: t)));
    if (r == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load, color: MyApp.primaryColor,
      child: _tasks.isEmpty
          ? const Center(child: Text('No repeating tasks!', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (c, i) {
          final t = _tasks[i];
          String repeatInfo = 'Repeats: ${t.repeatRule}';
          if (t.repeatRule == 'CustomDay' && t.customDays != null && t.customDays!.isNotEmpty) {
            repeatInfo += ' (${_daysToString(t.customDays!)})';
          }
          final Color priorityColor = t.priority == 2 ? Colors.redAccent : (t.priority == 1 ? Colors.amber : Colors.green);

          return FutureBuilder<double>(
            // FIX 3: Explicitly pass false/omit parameter to ensure subtask progress is shown
            future: parentState._progressFor(t, false),
            builder: (context, snap) {
              final progress = snap.data ?? 0.0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(t.title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Starting from: ${t.dueDate != null ? DateFormat.yMMMd().format(t.dueDate!) : '—'}'),
                      Text('Priority: ${parentState._priorityText(t.priority)}', style: TextStyle(color: priorityColor, fontWeight: FontWeight.w600)),
                      Text(repeatInfo, style: const TextStyle(color: MyApp.primaryColor, fontStyle: FontStyle.italic)),
                      parentState._buildProgressBar(progress), // Progress Bar
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // No completion/reset button here, as the task is always active in the Repeated tab
                      const Icon(Icons.repeat, color: MyApp.primaryColor),
                      // Delete Button (Original Code)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent), tooltip: 'Delete Task',
                        onPressed: () async {
                          if (t.notificationId != null) { try { await NotificationService.instance.cancel(t.notificationId!); } catch (_) {} }
                          await DBHelper.instance.deleteTask(t.id!);
                          _load();
                          parentState._loadOverallProgress();
                        },
                      ),
                    ],
                  ),
                  onTap: () => _openEditPage(t),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------- Add/Edit Page ----------------
class AddEditPage extends StatefulWidget {
  final Task? task;
  const AddEditPage({super.key, this.task});
  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String? _description;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  int _priority = 0;
  String _repeatRule = 'None';
  List<int> _customDays = [];
  late String _soundAsset;
  List<Subtask> _subtasks = [];
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _soundAsset = availableSounds.first;
    if (task != null) {
      _title = task.title;
      _description = task.description;
      _dueDate = task.dueDate;
      _dueTime = task.dueTime != null ? TimeOfDay(
        hour: int.parse(task.dueTime!.split(':')[0]),
        minute: int.parse(task.dueTime!.split(':')[1]),
      ) : null;
      _priority = task.priority;
      _repeatRule = task.repeatRule ?? 'None';
      _customDays = task.customDays ?? [];
      _soundAsset = task.soundAsset;
      if (task.id != null) {
        _loadSubtasks(task.id!);
      }
    } else {
      _title = '';
      _description = null;
    }
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _loadSubtasks(int taskId) async {
    final rows = await DBHelper.instance.getSubtasksForTask(taskId);
    setState(() {
      _subtasks = rows.map((r) => Subtask.fromMap(r)).toList();
    });
  }

  // --- Date/Time Picker Handlers ---

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _dueTime = time);
  }

  void _addSubtask() {
    if (_subtaskController.text.trim().isNotEmpty) {
      setState(() {
        _subtasks.add(Subtask(
          taskId: widget.task?.id ?? -1,
          title: _subtaskController.text.trim(),
          isDone: false,
        ));
      });
      _subtaskController.clear();
    }
  }

  void _toggleSubtaskDone(int index) {
    setState(() {
      _subtasks[index].isDone = !_subtasks[index].isDone;
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  // --- SAVE TASK FUNCTION (Including Notification Logic) ---
  Future<void> _saveTask() async {
    // FIX 3: Custom Day Validation
    if (_repeatRule == 'CustomDay' && _customDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one custom day for repetition.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final isEditing = widget.task != null;
    Task taskToSave = Task(
      id: isEditing ? widget.task!.id : null,
      title: _title,
      description: _description,
      dueDate: _dueDate,
      dueTime: _dueTime != null ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}' : null,
      priority: _priority,
      repeatRule: _repeatRule,
      // Pass null if customDays is empty or rule is not CustomDay
      customDays: _repeatRule == 'CustomDay' && _customDays.isNotEmpty ? _customDays : null,
      isCompleted: isEditing ? widget.task!.isCompleted : false,
      notificationId: isEditing ? widget.task!.notificationId : null,
      soundAsset: _soundAsset,
      completionTime: isEditing ? widget.task!.completionTime : null, // Preserve completion time if editing
    );

    // 1. Cancel existing notification
    if (taskToSave.notificationId != null) {
      try {
        await NotificationService.instance.cancel(taskToSave.notificationId!);
        taskToSave.notificationId = null; // Clear old ID
      } catch (e) {
        print('Error canceling old notification: $e');
      }
    }

    // 2. Save/Update task in DB to get a valid ID if it's new
    int taskId;
    if (isEditing) {
      final Map<String, dynamic> updateMap = taskToSave.toMap();
      updateMap.remove('id');
      await DBHelper.instance.updateTask(widget.task!.id!, updateMap);
      taskId = widget.task!.id!;
    } else {
      taskId = await DBHelper.instance.insertTask(taskToSave.toMap());
      taskToSave.id = taskId;
    }

    // 3. Handle NEW Notification Scheduling
    if (taskToSave.dueDate != null && taskToSave.dueTime != null && !taskToSave.isCompleted) {
      try {
        final hour = int.parse(taskToSave.dueTime!.split(':')[0]);
        final minute = int.parse(taskToSave.dueTime!.split(':')[1]);

        DateTime scheduledTime = DateTime(
          taskToSave.dueDate!.year,
          taskToSave.dueDate!.month,
          taskToSave.dueDate!.day,
          hour,
          minute,
        );

        final now = DateTime.now();
        final isRepeating = taskToSave.repeatRule != null && taskToSave.repeatRule != 'None';

        if (scheduledTime.isAfter(now) || isRepeating) {
          final newNotifId = await scheduleAdvancedNotification(
            id: taskId,
            title: taskToSave.title,
            body: taskToSave.description ?? 'Time to complete your task.',
            scheduledTime: scheduledTime,
            soundAsset: taskToSave.soundAsset,
          );
          // Update the task in DB with the new notification ID
          await DBHelper.instance.updateTask(taskId, {'notificationId': newNotifId});
        }
      } catch (e) {
        print('Error scheduling notification: $e');
        // If scheduling fails, ensure notificationId is null in DB
        await DBHelper.instance.updateTask(taskId, {'notificationId': null});
      }
    }
    final existingSubtaskRows = await DBHelper.instance.getSubtasksForTask(taskId);
    final existingSubtaskIds = existingSubtaskRows.map((e) => e['id'] as int).toSet();
    final currentSubtaskIds = <int>{};

    // B. Insert/Update current subtasks
    for (var subtask in _subtasks) {
      final subtaskMap = subtask.toMap();
      subtaskMap['taskId'] = taskId;

      if (subtask.id != null && existingSubtaskIds.contains(subtask.id!)) {
        // Update existing subtask
        await DBHelper.instance.updateSubtask(subtask.id!, subtaskMap);
        currentSubtaskIds.add(subtask.id!);
      } else {
        // Insert new subtask
        final newId = await DBHelper.instance.insertSubtask(subtaskMap);
        currentSubtaskIds.add(newId);
      }
    }

    // C. Delete subtasks that were removed from the UI list
    final deletedIds = existingSubtaskIds.difference(currentSubtaskIds);
    for (var id in deletedIds) {
      await DBHelper.instance.deleteSubtask(id); // Using the new deleteSubtask
    }


    if (mounted) Navigator.pop(context, true);
  }

  // --- UI Pickers / Builders ---

  Widget _buildDatePicker() => Row(
    children: [
      Expanded(
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Due Date'),
          child: Text(_dueDate == null ? 'No Date Set' : DateFormat.yMMMd().format(_dueDate!), style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
      IconButton(onPressed: _pickDate, icon: const Icon(Icons.calendar_today, color: MyApp.primaryColor)),
      if (_dueDate != null) IconButton(onPressed: () => setState(() => _dueDate = null), icon: const Icon(Icons.delete, color: Colors.red)),
    ],
  );

  Widget _buildTimePicker() => Row(
    children: [
      Expanded(
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Due Time'),
          child: Text(_dueTime == null ? 'No Time Set' : _dueTime!.format(context), style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
      IconButton(onPressed: _pickTime, icon: const Icon(Icons.access_time, color: MyApp.primaryColor)),
      if (_dueTime != null) IconButton(onPressed: () => setState(() => _dueTime = null), icon: const Icon(Icons.delete, color: Colors.red)),
    ],
  );

  Widget _buildRepeatRule() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Repeat Rule'),
      value: _repeatRule,
      items: const ['None', 'Daily', 'Weekly', 'Monthly', 'CustomDay'].map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) setState(() {
          _repeatRule = newValue;
          // Clear custom days if switching away from CustomDay
          if (newValue != 'CustomDay') _customDays = [];
        });
      },
    );
  }

  Widget _buildCustomDaysPicker() {
    if (_repeatRule != 'CustomDay') return const SizedBox.shrink();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Hint for custom day selection
    final bool hasSelectionError = _repeatRule == 'CustomDay' && _customDays.isEmpty && _formKey.currentState?.validate() == false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasSelectionError)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('Please select at least one day.', style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
        Wrap(
          spacing: 8.0,
          children: List.generate(7, (index) {
            final dayIndex = index + 1;
            final isSelected = _customDays.contains(dayIndex);
            return FilterChip(
              label: Text(days[index]),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _customDays.add(dayIndex);
                  } else {
                    _customDays.remove(dayIndex);
                  }
                });
              },
              selectedColor: MyApp.primaryColor,
              checkmarkColor: MyApp.lightTextColor,
              backgroundColor: Theme.of(context).cardColor,
              labelStyle: TextStyle(color: isSelected ? MyApp.lightTextColor : Theme.of(context).textTheme.bodyMedium?.color),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPriorityPicker() {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Priority'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPriorityChip(0, 'Low', Colors.green),
          _buildPriorityChip(1, 'Medium', Colors.amber),
          _buildPriorityChip(2, 'High', Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(int value, String label, Color color) {
    return ChoiceChip(
      label: Text(label),
      selected: _priority == value,
      selectedColor: color,
      onSelected: (selected) {
        if (selected) setState(() => _priority = value);
      },
      labelStyle: TextStyle(color: _priority == value ? MyApp.lightTextColor : Theme.of(context).textTheme.bodyMedium?.color),
    );
  }

  Widget _buildSoundPicker() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Notification Sound'),
      value: _soundAsset,
      items: availableSounds.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value.replaceAll('.mp3', '')));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) setState(() => _soundAsset = newValue);
      },
    );
  }

  Widget _buildSubtaskInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _subtaskController,
                decoration: const InputDecoration(
                  labelText: 'Add Subtask',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (_) => _addSubtask(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addSubtask,
              icon: const Icon(Icons.add_box, color: MyApp.primaryColor),
              tooltip: 'Add Subtask',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_subtasks.isNotEmpty) ...[
          const Text('Subtasks List:', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._subtasks.asMap().entries.map((entry) {
            final index = entry.key;
            final subtask = entry.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                subtask.title,
                style: TextStyle(
                  decoration: subtask.isDone ? TextDecoration.lineThrough : null,
                  color: subtask.isDone ? Colors.grey : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              leading: Checkbox(
                value: subtask.isDone,
                onChanged: (_) => _toggleSubtaskDone(index),
                fillColor: MaterialStateProperty.all(MyApp.primaryColor),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeSubtask(index),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create New Task' : 'Edit Task'),
        actions: widget.task != null ? [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            tooltip: 'Delete Task',
            onPressed: () async {
              if (widget.task!.notificationId != null) {
                await NotificationService.instance.cancel(widget.task!.notificationId!);
              }
              await DBHelper.instance.deleteTask(widget.task!.id!);
              if (mounted) Navigator.pop(context, true);
            },
          )
        ] : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: widget.task?.title,
              decoration: const InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
              validator: (v) => v!.trim().isEmpty ? 'Title cannot be empty' : null,
              onSaved: (v) => _title = v!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.task?.description,
              decoration: const InputDecoration(labelText: 'Description (Optional)'),
              maxLines: 3,
              textInputAction: TextInputAction.done,
              onSaved: (v) => _description = v!.trim().isEmpty ? null : v.trim(),
            ),
            const SizedBox(height: 16),
            _buildPriorityPicker(),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildTimePicker(),
            const SizedBox(height: 16),
            _buildRepeatRule(),
            const SizedBox(height: 16),
            _buildCustomDaysPicker(),
            const SizedBox(height: 16),
            _buildSoundPicker(),
            const SizedBox(height: 24),
            _buildSubtaskInput(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(widget.task == null ? 'CREATE TASK' : 'UPDATE TASK'),
            ),
          ],
        ),
      ),
    );
  }
}