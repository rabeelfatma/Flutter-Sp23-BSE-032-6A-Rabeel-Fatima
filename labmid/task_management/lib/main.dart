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
import 'notification_service.dart';

const List<String> availableSounds = ['bell.mp3', 'chime.mp3', 'soft.mp3'];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Notification service early (timezones and plugin)
  await NotificationService.instance.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

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
  String? completionTime;
  String? status;

  Task({
    this.id, required this.title, this.description, this.dueDate, this.dueTime,
    this.priority = 0, this.repeatRule, this.customDays, this.isCompleted = false,
    this.notificationId, this.soundAsset = 'bell.mp3', this.completionTime,
    this.status = 'In Progress', // Default status for new tasks
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'description': description,
    // Store as epoch seconds
    'dueDate': dueDate != null ? (dueDate!.millisecondsSinceEpoch ~/ 1000) : null,
    'dueTime': dueTime, 'priority': priority, 'repeatRule': repeatRule,
    'customDays': customDays?.join(','),
    'isCompleted': isCompleted ? 1 : 0,
    'notificationId': notificationId,
    'soundAsset': soundAsset,
    'completionTime': completionTime,
    'status': status,
  };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
    id: m['id'] as int?, title: m['title'] as String, description: m['description'] as String?,
    // Load from epoch seconds
    dueDate: m['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch((m['dueDate'] as int) * 1000) : null,
    dueTime: m['dueTime'] as String?, priority: m['priority'] ?? 0, repeatRule: m['repeatRule'] as String?,
    customDays: m['customDays'] != null && (m['customDays'] as String).isNotEmpty
        ? (m['customDays'] as String).split(',').map((e) => int.parse(e.trim())).toList() : null,
    isCompleted: (m['isCompleted'] ?? 0) == 1,
    notificationId: m['notificationId'] as int?,
    soundAsset: m['soundAsset'] ?? 'bell.mp3',
    completionTime: m['completionTime'] as String?,
    status: m['status'] as String? ?? 'In Progress',
  );

  String get derivedStatus {
    if (isCompleted) return 'Completed';
    // Use manually set status for failed/aborted
    if (status == 'Failed' || status == 'Aborted') return status!;
    if (dueDate == null) return 'In Progress';

    DateTime now = DateTime.now();
    DateTime due = dueDate!;
    if (dueTime != null) {
      final parts = dueTime!.split(':');
      due = DateTime(due.year, due.month, due.day, int.parse(parts[0]), int.parse(parts[1]));
    } else {

      due = DateTime(due.year, due.month, due.day, 23, 59, 59);
    }

    return now.isAfter(due) ? 'Delayed' : 'In Progress';
  }
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
    return Consumer<ThemeProvider>(builder: (context, theme, _) {
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
          cardTheme: CardTheme.of(context).copyWith(
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
        home: const DashboardScreen(),
      );
    });
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;
  void toggle() { _isDark = !_isDark; notifyListeners(); }
}

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  Map<String, int> _counts = {
    'today': 0, 'completed': 0, 'repeated': 0,
    'inProgress': 0, 'delayed': 0, 'failed': 0, 'aborted': 0, 'total': 0, 'pending': 0,
  };

  int get todayCount => _counts['today'] ?? 0;
  int get completedCount => _counts['completed'] ?? 0;
  int get repeatedCount => _counts['repeated'] ?? 0;
  int get inProgressCount => _counts['inProgress'] ?? 0;
  int get delayedCount => _counts['delayed'] ?? 0;
  int get failedCount => _counts['failed'] ?? 0;
  int get abortedCount => _counts['aborted'] ?? 0;
  int get totalCount => _counts['total'] ?? 0;
  int get pendingCount => _counts['pending'] ?? 0;

  Future<void> loadAllTasks() async {
    final data = await DBHelper.instance.getAllTasks();
    _tasks = data.map((e) => Task.fromMap(e)).toList();

    // Recalculate counts
    final now = DateTime.now();
    _counts['total'] = _tasks.length;

    // Status counts based on derived status (excluding completed)
    _counts['inProgress'] = _tasks.where((t) => t.derivedStatus == 'In Progress' && !t.isCompleted && t.status != 'Failed' && t.status != 'Aborted').length;
    _counts['delayed'] = _tasks.where((t) => t.derivedStatus == 'Delayed' && !t.isCompleted).length;
    // Use manual status for Failed/Aborted/Completed
    _counts['failed'] = _tasks.where((t) => t.status == 'Failed' && !t.isCompleted).length;
    _counts['aborted'] = _tasks.where((t) => t.status == 'Aborted' && !t.isCompleted).length;

    // Pending: Not completed, not failed, not aborted
    _counts['pending'] = _tasks.where((t) =>
    !t.isCompleted &&
        t.status != 'Failed' &&
        t.status != 'Aborted'
    ).length;


    // Today/Completed/Repeated counts
    _counts['today'] = _tasks.where((t) =>
    !t.isCompleted &&
        t.dueDate != null &&
        t.dueDate!.year == now.year &&
        t.dueDate!.month == now.month &&
        t.dueDate!.day == now.day
    ).length;
    _counts['completed'] = _tasks.where((t) => t.isCompleted).length;
    _counts['repeated'] = _tasks.where((t) => t.repeatRule != 'None').length;


    notifyListeners();
  }
}

// ---------------- Dashboard Screen (New Home Screen) ----------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Use a single variable to track the current section view
  int _currentTaskSection = 0; // 0=Today, 1=Completed, 2=Repeated

  // Use a ScrollController for the 'Go to top' button functionality
  final ScrollController _scrollController = ScrollController();

  // --- Utility Functions for Export/Progress ---
  Future<double> _progressFor(Task t, [bool isCompletedTab = false]) async {
    if (isCompletedTab || t.isCompleted) return 1.0;

    if (t.id == null) return 0.0;
    final rows = await DBHelper.instance.getSubtasksForTask(t.id!);
    if (rows.isEmpty) return 0.0;
    final done = rows.where((r) => (r['isDone'] ?? 0) == 1).length;
    return done / rows.length;
  }

  String _priorityText(int p) => p == 2 ? 'High' : (p == 1 ? 'Medium' : 'Low');

  // Widget to display progress bar and percentage
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
      ['Title', 'Description', 'Due Date', 'Completed', 'Status']
    ];
    for (var r in rows) {
      final dueDate = r['dueDate'] != null
          ? DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch((r['dueDate'] as int) * 1000)) : 'N/A';
      data.add([r['title'] ?? '', r['description'] ?? '', dueDate, (r['isCompleted'] ?? 0) == 1 ? 'Yes' : 'No', r['status'] ?? 'N/A']);
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
        list.add(['id', 'title', 'description', 'dueDate', 'dueTime', 'isCompleted', 'status']);
        for (var r in rows) {
          final dueDate = r['dueDate'] != null
              ? DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch((r['dueDate'] as int) * 1000)) : '';
          list.add([r['id'].toString(), r['title'] ?? '', r['description'] ?? '', dueDate, r['dueTime'] ?? '', (r['isCompleted'] ?? 0) == 1 ? 'Yes' : 'No', r['status'] ?? 'N/A']);
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
        list.add(['id', 'title', 'description', 'dueDate', 'dueTime', 'isCompleted', 'status']);
        for (var r in rows) {
          final dueDate = r['dueDate'] != null
              ? DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch((r['dueDate'] as int) * 1000)) : '';
          list.add([r['id'].toString(), r['title'] ?? '', r['description'] ?? '', dueDate, r['dueTime'] ?? '', (r['isCompleted'] ?? 0) == 1 ? 'Yes' : 'No', r['status'] ?? 'N/A']);
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadAllTasks();
    });
  }
  Widget _buildStatusCard(BuildContext context, String title, int count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text('Total Count', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(count.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MyApp.primaryColor)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
          ],
        ),
      ),
    );
  }

  //  Widget for Task Information List
  Widget _buildTaskInformationList(TaskProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 5,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: const Text('Tasks Information (All Tasks)', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.playlist_add_check, color: MyApp.primaryColor),
        children: [
          _buildTaskInfoTile(
              context,
              'Add Task',
              Icons.add_box_outlined,
              MyApp.primaryColor,
                  () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddEditPage()),
                );
                if (result == true) {
                  provider.loadAllTasks();
                }
              }
          ),
          _buildTaskInfoTile(context, 'Pending Tasks', Icons.pending_actions, Colors.orange,
                  () => _openTaskListPage('Pending Tasks', Icons.pending_actions, Colors.orange)),
          _buildTaskInfoTile(context, 'In Progress', Icons.watch_later_outlined, Colors.blue,
                  () => _openTaskListPage('In Progress', Icons.watch_later_outlined, Colors.blue)),
          _buildTaskInfoTile(context, 'Delayed', Icons.timer_off_outlined, Colors.orange,
                  () => _openTaskListPage('Delayed', Icons.timer_off_outlined, Colors.orange)),
          _buildTaskInfoTile(context, 'Completed', Icons.check_circle_outline, Colors.green,
                  () => _openTaskListPage('Completed', Icons.check_circle_outline, Colors.green)),
          _buildTaskInfoTile(context, 'Failed', Icons.cancel_outlined, Colors.red,
                  () => _openTaskListPage('Failed', Icons.cancel_outlined, Colors.red)),
          _buildTaskInfoTile(context, 'Aborted', Icons.stop_circle_outlined, Colors.deepPurple,
                  () => _openTaskListPage('Aborted', Icons.stop_circle_outlined, Colors.deepPurple)),
          _buildTaskInfoTile(context, 'Task Index (All)', Icons.list_alt, Colors.grey,
                  () => _openTaskListPage('Task Index', Icons.list_alt, Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTaskInfoTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _openTaskListPage(String status, IconData icon, Color color) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskListPage(status: status, icon: icon, color: color)),
    );

    Provider.of<TaskProvider>(context, listen: false).loadAllTasks();
  }

  Future<void> _markTaskCompleted(Task t) async {
    if (t.id == null) return;
    await DBHelper.instance.markTaskCompleted(t.id!);
    if (t.notificationId != null) {
      // Cancel repeating/scheduled notification when completed
      try { await NotificationService.instance.cancelTaskNotifications(t.id!); } catch (_) {}
    }
    Provider.of<TaskProvider>(context, listen: false).loadAllTasks();
  }

  // NEW: Reset Task Functionality (for Completed list)
  Future<void> _resetTask(Task t) async {
    if (t.id == null) return;

    // 1. Update DB to reset completion status and time
    await DBHelper.instance.updateTask(t.id!, {
      'isCompleted': 0,
      'completionTime': null,
      'status': 'In Progress', // Reset status to default for recalculation
    });

    // 2. Re-schedule notification if due date/time exists
    final updatedTask = Task.fromMap((await DBHelper.instance.getTaskById(t.id!))!);
    if (updatedTask.dueDate != null && updatedTask.dueTime != null && !updatedTask.isCompleted) {
      try {
        final hour = int.parse(updatedTask.dueTime!.split(':')[0]);
        final minute = int.parse(updatedTask.dueTime!.split(':')[1]);

        DateTime scheduledTime = DateTime(
          updatedTask.dueDate!.year,
          updatedTask.dueDate!.month,
          updatedTask.dueDate!.day,
          hour,
          minute,
        );
        final now = DateTime.now();

        if (scheduledTime.isAfter(now) || updatedTask.repeatRule != 'None') {
          final newNotifId = await scheduleAdvancedNotification(
            id: updatedTask.id!,
            title: updatedTask.title,
            body: updatedTask.description ?? 'Time to complete your task.',
            scheduledTime: scheduledTime,
            soundAsset: updatedTask.soundAsset,
            repeatRule: updatedTask.repeatRule!,
            customDays: updatedTask.customDays,
          );
          await DBHelper.instance.updateTask(updatedTask.id!, {'notificationId': newNotifId});
        }
      } catch (e) {
        print('Error rescheduling notification on reset: $e');
        await DBHelper.instance.updateTask(updatedTask.id!, {'notificationId': null});
      }
    }

    Provider.of<TaskProvider>(context, listen: false).loadAllTasks();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskBoard Pro'),
        centerTitle: false,
        actions: [
          // REMOVED: Download and Person Icons
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
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            children: [
              const SizedBox(height: 16),
              // Task Information List Section
              _buildTaskInformationList(taskProvider),

              const SizedBox(height: 16),
              // Task Status Grid (Dashboard Cards)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatusCard(context, 'In Progress', taskProvider.inProgressCount, Icons.watch_later_outlined, Colors.blue),
                    _buildStatusCard(context, 'Delayed', taskProvider.delayedCount, Icons.timer_off_outlined, Colors.orange),
                    _buildStatusCard(context, 'Completed', taskProvider.completedCount, Icons.check_circle_outline, Colors.green),
                    _buildStatusCard(context, 'Total Tasks', taskProvider.totalCount, Icons.bar_chart_sharp, Colors.grey),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // Simplified Task List for Today/Completed/Repeated (Replaces old HomeScreen tabs)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSectionChip(0, 'Today', taskProvider.todayCount),
                    _buildSectionChip(1, 'Completed', taskProvider.completedCount),
                    _buildSectionChip(2, 'Repeated', taskProvider.repeatedCount),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildCurrentTaskList(taskProvider),
              ),
              const SizedBox(height: 80),
            ],
          ),

          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'goTop',
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  backgroundColor: MyApp.primaryColor,
                  child: const Icon(Icons.rocket_launch, color: MyApp.lightTextColor),
                ),
                const SizedBox(height: 4),
                const Text('Go to Top', style: TextStyle(color: MyApp.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Search Button
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'search',
              onPressed: () {
                showSearch(context: context, delegate: TaskSearchDelegate(
                    allTasks: taskProvider.tasks,
                    onTaskTap: (task) async {
                      final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditPage(task: task)));
                      if (result == true) taskProvider.loadAllTasks();
                    }
                ));
              },
              backgroundColor: MyApp.primaryColor,
              child: const Icon(Icons.search, color: MyApp.lightTextColor),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSectionChip(int index, String label, int count) {
    final isSelected = _currentTaskSection == index;
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _currentTaskSection = index);
      },
      selectedColor: MyApp.primaryColor,
      checkmarkColor: MyApp.lightTextColor,
      backgroundColor: Theme.of(context).cardColor,
      labelStyle: TextStyle(color: isSelected ? MyApp.lightTextColor : Theme.of(context).textTheme.bodyMedium?.color),
    );
  }

  Widget _buildCurrentTaskList(TaskProvider provider) {
    List<Task> list;
    String statusFilter;
    bool isCompletedSection = false;

    switch (_currentTaskSection) {
      case 0: // Today
        list = provider._tasks.where((t) {
          final now = DateTime.now();
          return !t.isCompleted &&
              t.status != 'Failed' &&
              t.status != 'Aborted' &&
              t.dueDate != null &&
              t.dueDate!.year == now.year &&
              t.dueDate!.month == now.month &&
              t.dueDate!.day == now.day;
        }).toList();
        statusFilter = 'Today';
        break;
      case 1: // Completed
        list = provider._tasks.where((t) => t.isCompleted).toList();
        statusFilter = 'Completed';
        isCompletedSection = true;
        break;
      case 2: // Repeated
        list = provider._tasks.where((t) => t.repeatRule != 'None' && !t.isCompleted).toList();
        statusFilter = 'Repeated';
        break;
      default:
        return const SizedBox.shrink();
    }

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('No $statusFilter tasks found.', style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: list.map((t) => FutureBuilder<double>(
        future: _progressFor(t, t.isCompleted),
        builder: (context, snap) {
          final progress = snap.data ?? 0.0;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(t.title, style: TextStyle(
                  decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                  fontWeight: FontWeight.bold
              )),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Priority: ${_priorityText(t.priority)}'),
                  if (t.dueDate != null)
                    Text('Due: ${DateFormat.yMMMd().format(t.dueDate!)}${t.dueTime != null ? ' at ${t.dueTime}' : ''}'),
                  // Show derived status (In Progress, Delayed)
                  Text('Status: ${t.derivedStatus}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  _buildProgressBar(progress),
                ],
              ),
              trailing: isCompletedSection
                  ? IconButton( // NEW: Reset option for completed tasks
                icon: const Icon(Icons.undo, color: Colors.blue),
                onPressed: () => _resetTask(t),
                tooltip: 'Reset Task (Mark Incomplete)',
              )
                  : IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                onPressed: () => _markTaskCompleted(t),
                tooltip: 'Mark Completed',
              ),
              onTap: () async {
                final r = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditPage(task: t)));
                if (r == true) provider.loadAllTasks();
              },
            ),
          );
        },
      )).toList(),
    );
  }
}

// ---------------- Task List Page (For detailed status views) ----------------
class TaskListPage extends StatefulWidget {
  final String status;
  final IconData icon;
  final Color color;
  const TaskListPage({super.key, required this.status, required this.icon, required this.color});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    List<Task> allTasks = (await DBHelper.instance.getAllTasks()).map((r) => Task.fromMap(r)).toList();
    List<Task> filteredTasks = [];

    switch (widget.status) {
      case 'Task Index':
        filteredTasks = allTasks;
        break;
      case 'Completed':
        filteredTasks = allTasks.where((t) => t.isCompleted).toList();
        break;
      case 'Pending Tasks':
        filteredTasks = allTasks.where((t) =>
        !t.isCompleted &&
            t.status != 'Failed' &&
            t.status != 'Aborted'
        ).toList();
        break;
      case 'In Progress':
        filteredTasks = allTasks.where((t) => t.derivedStatus == 'In Progress' && !t.isCompleted && t.status != 'Failed' && t.status != 'Aborted').toList();
        break;
      case 'Delayed':
        filteredTasks = allTasks.where((t) => t.derivedStatus == 'Delayed' && !t.isCompleted).toList();
        break;
      case 'Failed':
        filteredTasks = allTasks.where((t) => t.status == 'Failed' && !t.isCompleted).toList();
        break;
      case 'Aborted':
        filteredTasks = allTasks.where((t) => t.status == 'Aborted' && !t.isCompleted).toList();
        break;
      default:

        filteredTasks = [];
        break;
    }

    setState(() {
      _tasks = filteredTasks;
      _isLoading = false;
    });
  }

  String _priorityText(int p) => p == 2 ? 'High' : (p == 1 ? 'Medium' : 'Low');

  Future<double> _progressFor(Task t) async {
    if (t.isCompleted) return 1.0;
    if (t.id == null) return 0.0;
    final rows = await DBHelper.instance.getSubtasksForTask(t.id!);
    if (rows.isEmpty) return 0.0;
    final done = rows.where((r) => (r['isDone'] ?? 0) == 1).length;
    return done / rows.length;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.status),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MyApp.lightTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MyApp.primaryColor))
          : RefreshIndicator(
        onRefresh: _loadTasks,
        color: MyApp.primaryColor,
        child: _tasks.isEmpty
            ? Center(child: Text('No ${widget.status} tasks.', style: const TextStyle(fontSize: 18, color: Colors.grey)))
            : ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (c, i) {
            final t = _tasks[i];
            final Color priorityColor = t.priority == 2 ? Colors.redAccent : (t.priority == 1 ? Colors.amber : Colors.green);

            return FutureBuilder<double>(
              future: _progressFor(t),
              builder: (context, snap) {
                final progress = snap.data ?? 0.0;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(widget.icon, color: widget.color),
                    title: Text(t.title, style: TextStyle(
                        decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.bold
                    )),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.description ?? ''),
                        if (t.dueDate != null)
                          Text('Due: ${DateFormat.yMMMd().format(t.dueDate!)}${t.dueTime != null ? ' at ${t.dueTime}' : ''}'), // NEW: Show time
                        Text('Priority: ${_priorityText(t.priority)}', style: TextStyle(color: priorityColor, fontWeight: FontWeight.w600)),
                        Text('Status: ${t.derivedStatus}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                        _buildProgressBar(progress),
                      ],
                    ),
                    trailing: t.isCompleted ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    onTap: () async {
                      final r = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditPage(task: t)));
                      if (r == true) _loadTasks();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ---------------- Search Delegate ----------------
class StatusFilter {
  final String statusName;
  final String queryKey;
  final IconData icon;
  final Color color;

  const StatusFilter(this.statusName, this.queryKey, this.icon, this.color);
}

// List of all status filters for the search suggestions
const List<StatusFilter> taskStatusFilters = [
  StatusFilter('Pending Tasks', 'pending', Icons.pending_actions, Colors.orange),
  StatusFilter('In Progress', 'in progress', Icons.watch_later_outlined, Colors.blue),
  StatusFilter('Delayed', 'delayed', Icons.timer_off_outlined, Colors.orange),
  StatusFilter('Completed', 'completed', Icons.check_circle_outline, Colors.green),
  StatusFilter('Failed', 'failed', Icons.cancel_outlined, Colors.red),
  StatusFilter('Aborted', 'aborted', Icons.stop_circle_outlined, Colors.deepPurple),
  StatusFilter('Task Index (All)', 'all tasks', Icons.list_alt, Colors.grey),
];


class TaskSearchDelegate extends SearchDelegate<Task?> {
  final List<Task> allTasks;
  final Function(Task) onTaskTap;

  TaskSearchDelegate({required this.allTasks, required this.onTaskTap});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: MyApp.primaryColor,
        foregroundColor: MyApp.lightTextColor,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: MyApp.lightTextColor.withOpacity(0.7)),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: MyApp.lightTextColor),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: MyApp.lightTextColor),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Task> results = _filterTasks(allTasks, query);
    final matchedStatus = taskStatusFilters.firstWhere(
            (f) => f.queryKey == query.toLowerCase(),
        orElse: () => const StatusFilter('', '', Icons.task_alt, Colors.grey)
    );

    if (matchedStatus.queryKey.isNotEmpty) {
      return _buildTaskList(context, results, matchedStatus.icon, matchedStatus.color);
    }

    // Default search results
    return _buildTaskList(context, results, Icons.task_alt, Theme.of(context).iconTheme.color!);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return ListView(
        children: taskStatusFilters.map((filter) {
          return ListTile(
            leading: Icon(filter.icon, color: filter.color),
            title: Text(filter.statusName, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
            onTap: () {
              query = filter.queryKey;
              showResults(context);
            },
          );
        }).toList(),
      );
    }
    final suggestions = allTasks.where((task) =>
    task.title.toLowerCase().contains(query.toLowerCase()) ||
        (task.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
    final displaySuggestions = suggestions.take(10).toList();

    return _buildTaskList(context, displaySuggestions, Icons.search, MyApp.primaryColor);
  }
  List<Task> _filterTasks(List<Task> tasks, String query) {
    final lowerQuery = query.toLowerCase();

    switch (lowerQuery) {
      case 'pending':
        return tasks.where((t) =>
        !t.isCompleted &&
            t.status != 'Failed' &&
            t.status != 'Aborted'
        ).toList();
      case 'in progress':
        return tasks.where((t) => t.derivedStatus == 'In Progress' && !t.isCompleted && t.status != 'Failed' && t.status != 'Aborted').toList();
      case 'delayed':
        return tasks.where((t) => t.derivedStatus == 'Delayed' && !t.isCompleted).toList();
      case 'completed':
        return tasks.where((t) => t.isCompleted).toList();
      case 'failed':
        return tasks.where((t) => t.status == 'Failed' && !t.isCompleted).toList();
      case 'aborted':
        return tasks.where((t) => t.status == 'Aborted' && !t.isCompleted).toList();
      case 'all tasks':
        return tasks;
      default:
        return tasks.where((task) =>
        task.title.toLowerCase().contains(lowerQuery) ||
            (task.description?.toLowerCase().contains(lowerQuery) ?? false)
        ).toList();
    }
  }

  Widget _buildTaskList(BuildContext context, List<Task> tasks, IconData defaultIcon, Color defaultIconColor) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('No tasks found for "$query".', style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        IconData icon;
        Color iconColor;

        if (task.isCompleted) {
          icon = Icons.check_circle;
          iconColor = Colors.green;
        } else if (task.status == 'Failed') {
          icon = Icons.cancel_outlined;
          iconColor = Colors.red;
        } else if (task.status == 'Aborted') {
          icon = Icons.stop_circle_outlined;
          iconColor = Colors.deepPurple;
        } else if (task.derivedStatus == 'Delayed') {
          icon = Icons.timer_off_outlined;
          iconColor = Colors.orange;
        } else {
          // Use priority icon for In Progress/Pending if specific status icon isn't set
          switch (task.priority) {
            case 2: // High
              icon = Icons.priority_high;
              iconColor = Colors.redAccent;
              break;
            case 1: // Medium
              icon = Icons.warning_amber;
              iconColor = Colors.amber;
              break;
            case 0: // Low/Default
            default:
              icon = Icons.task_alt;
              iconColor = MyApp.primaryColor;
              break;
          }
        }

        String subtitleText = task.description ?? 'No description';
        if (task.dueDate != null) {
          subtitleText += ' | Due: ${DateFormat.yMMMd().format(task.dueDate!)}${task.dueTime != null ? ' at ${task.dueTime}' : ''}'; // NEW: Show time
        }


        return ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitleText),
              // Show the dynamic derived status
              Text('Status: ${task.derivedStatus}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
          onTap: () {
            onTaskTap(task);
            close(context, task);
          },
        );
      },
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
  late String _status;
  List<Subtask> _subtasks = [];
  final TextEditingController _subtaskController = TextEditingController();

  static const List<String> manualStatuses = ['Completed', 'Failed', 'Aborted'];


  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _soundAsset = availableSounds.first;
    _status = 'In Progress';

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
      if (manualStatuses.contains(task.status)) {
        _status = task.status!;
      } else {
        _status = 'In Progress';
      }

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

  // --- SAVE TASK FUNCTION ---
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final isEditing = widget.task != null;

    // Determine completion status based on manual _status selection
    final bool markAsCompleted = _status == 'Completed';

    Task taskToSave = Task(
      id: isEditing ? widget.task!.id : null,
      title: _title,
      description: _description,
      dueDate: _dueDate,
      dueTime: _dueTime != null ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}' : null,
      priority: _priority,
      repeatRule: _repeatRule,
      customDays: _repeatRule == 'CustomDay' && _customDays.isNotEmpty ? _customDays : null,
      // If manually marked completed, use that. Otherwise, retain previous state unless editing.
      isCompleted: markAsCompleted,
      notificationId: isEditing ? widget.task!.notificationId : null,
      soundAsset: _soundAsset,
      completionTime: markAsCompleted ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()) : null,
      // Status is the selected manual status, or 'In Progress' if no manual status was selected.
      status: _status,
    );

    // 1. Cancel existing notification
    if (taskToSave.id != null) {
      try {
        await NotificationService.instance.cancelTaskNotifications(taskToSave.id!);
        taskToSave.notificationId = null; // Prepare for potential update
      } catch (e) {
        print('Error canceling old notification: $e');
      }
    }
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
    if (taskToSave.dueDate != null && taskToSave.dueTime != null && !taskToSave.isCompleted && taskToSave.status != 'Failed' && taskToSave.status != 'Aborted') {
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

        // Calling the correctly imported function from notification_service.dart
        if (scheduledTime.isAfter(now) || isRepeating) {
          final newNotifId = await scheduleAdvancedNotification(
            id: taskId,
            title: taskToSave.title,
            body: taskToSave.description ?? 'Time to complete your task.',
            scheduledTime: scheduledTime,
            soundAsset: taskToSave.soundAsset,
            repeatRule: taskToSave.repeatRule!,
            customDays: taskToSave.customDays,
          );
          await DBHelper.instance.updateTask(taskId, {'notificationId': newNotifId});
        }
      } catch (e) {
        print('Error scheduling notification: $e');
        await DBHelper.instance.updateTask(taskId, {'notificationId': null});
      }
    } else if (taskToSave.id != null) {
      // Ensure notificationId is explicitly cleared if criteria are no longer met
      await DBHelper.instance.updateTask(taskId, {'notificationId': null});
    }

    // 4. Handle Subtask Saving
    final existingSubtaskRows = await DBHelper.instance.getSubtasksForTask(taskId);
    final existingSubtaskIds = existingSubtaskRows.map((e) => e['id'] as int).toSet();
    final currentSubtaskIds = <int>{};

    for (var subtask in _subtasks) {
      final subtaskMap = subtask.toMap();
      subtaskMap['taskId'] = taskId;

      if (subtask.id != null && existingSubtaskIds.contains(subtask.id!)) {
        await DBHelper.instance.updateSubtask(subtask.id!, subtaskMap);
        currentSubtaskIds.add(subtask.id!);
      } else {
        final newId = await DBHelper.instance.insertSubtask(subtaskMap);
        currentSubtaskIds.add(newId);
      }
    }

    final deletedIds = existingSubtaskIds.difference(currentSubtaskIds);
    for (var id in deletedIds) {
      await DBHelper.instance.deleteSubtask(id);
    }

    if (mounted) {
      Provider.of<TaskProvider>(context, listen: false).loadAllTasks();
      Navigator.pop(context, true);
    }
  }

  // UPDATED: Status Picker Widget (Completely removes 'In Progress' from options)
  Widget _buildStatusPicker() {
    final bool isManualStatusSet = manualStatuses.contains(_status);
    String? displayValue = isManualStatusSet ? _status : null;

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Manual Status',
        hintText: 'Select a final status (Current: In Progress/Delayed)',
      ),
      value: displayValue,
      items: manualStatuses.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) setState(() {
          _status = newValue;
          if (widget.task != null) {
            // Update the isCompleted flag if Completed is selected
            widget.task!.isCompleted = newValue == 'Completed';
          }
        });
      },
      style: TextStyle(color: isManualStatusSet ? MyApp.primaryColor : Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold),
    );
  }


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
    const repeatOptions = ['None', 'Daily', 'CustomDay'];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Repeat Rule'),
      value: _repeatRule,
      items: repeatOptions.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) setState(() {
          _repeatRule = newValue;
          if (newValue != 'CustomDay') _customDays = [];
        });
      },
    );
  }

  Widget _buildCustomDaysPicker() {
    if (_repeatRule != 'CustomDay') return const SizedBox.shrink();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // NOTE: Removed validation/error message display
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                await NotificationService.instance.cancelTaskNotifications(widget.task!.id!);
              }
              await DBHelper.instance.deleteTask(widget.task!.id!);
              if (mounted) {
                Provider.of<TaskProvider>(context, listen: false).loadAllTasks();
                Navigator.pop(context, true);
              }
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
            _buildStatusPicker(), // UPDATED: Status Picker
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