import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => AppModel(),
    child: const MyApp(),
  ));
}

// ----------------------------- Data Models -----------------------------
class Course {
  int id;
  String code;
  double credits;
  String grade;
  Course(
      {required this.id,
        required this.code,
        required this.credits,
        required this.grade});
}

class Semester {
  int id;
  String name;
  List<Course> courses;
  Semester({required this.id, required this.name, required this.courses});
}

// ------------------------------ App Model ------------------------------
class AppModel extends ChangeNotifier {
  List<Semester> semesters = [];
  int _semesterCounter = 1;
  int _courseCounter = 1;

  String studentName = '';
  String rollNumber = '';
  String country = 'Pakistan';
  double scale = 4.0;
  bool isDarkMode = false;
  MaterialColor accentColor = Colors.teal;

  Map<String, double> gradeMap = {
    'A+': 4.0,
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'D': 1.0,
    'F': 0.0,
  };

  void setStudentInfo(String name, String roll) {
    studentName = name;
    rollNumber = roll;
    notifyListeners();
  }

  void setCountry(String c) {
    country = c;
    if (c == 'Pakistan' || c == 'USA') scale = 4.0;
    else if (c == 'India') scale = 10.0;
    else scale = 4.0;
    _updateGradeMap();
    notifyListeners();
  }

  void setScale(double s) {
    scale = s;
    _updateGradeMap();
    notifyListeners();
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void changeAccent(MaterialColor color) {
    accentColor = color;
    notifyListeners();
  }

  void _updateGradeMap() {
    if (scale == 4.0) {
      gradeMap = {
        'A+': 4.0,
        'A': 4.0,
        'A-': 3.7,
        'B+': 3.3,
        'B': 3.0,
        'B-': 2.7,
        'C+': 2.3,
        'C': 2.0,
        'D': 1.0,
        'F': 0.0
      };
    } else if (scale == 5.0) {
      gradeMap = {
        'A+': 5.0,
        'A': 5.0,
        'A-': 4.7,
        'B+': 4.3,
        'B': 4.0,
        'B-': 3.7,
        'C+': 3.3,
        'C': 3.0,
        'D': 2.0,
        'F': 0.0
      };
    } else if (scale == 10.0) {
      gradeMap = {
        'A+': 10.0,
        'A': 10.0,
        'A-': 9.7,
        'B+': 9.3,
        'B': 9.0,
        'B-': 8.7,
        'C+': 8.3,
        'C': 8.0,
        'D': 6.0,
        'F': 0.0
      };
    }
  }

  void addSemester(String name) {
    semesters.add(Semester(id: _semesterCounter++, name: name, courses: []));
    notifyListeners();
  }

  void renameSemester(int id, String newName) {
    final sem = semesters.firstWhere((s) => s.id == id);
    sem.name = newName;
    notifyListeners();
  }

  void deleteSemester(int id) {
    semesters.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void addCourse(int semesterId, String code, double credits, String grade) {
    final sem = semesters.firstWhere((s) => s.id == semesterId);
    sem.courses.add(Course(
        id: _courseCounter++, code: code, credits: credits, grade: grade));
    notifyListeners();
  }

  void updateCourse(int semesterId, Course course) {
    final sem = semesters.firstWhere((s) => s.id == semesterId);
    final idx = sem.courses.indexWhere((c) => c.id == course.id);
    if (idx != -1) sem.courses[idx] = course;
    notifyListeners();
  }

  void deleteCourse(int semesterId, int courseId) {
    final sem = semesters.firstWhere((s) => s.id == semesterId);
    sem.courses.removeWhere((c) => c.id == courseId);
    notifyListeners();
  }

  double semesterGPA(int semesterId) {
    final sem = semesters.firstWhere((s) => s.id == semesterId);
    double totalPoints = 0, totalCredits = 0;
    for (var c in sem.courses) {
      final gp = gradeMap[c.grade] ?? 0.0;
      totalPoints += gp * c.credits;
      totalCredits += c.credits;
    }
    return totalCredits == 0 ? 0.0 : totalPoints / totalCredits;
  }

  double cumulativeCGPA() {
    double totalPoints = 0, totalCredits = 0;
    for (var s in semesters) {
      for (var c in s.courses) {
        final gp = gradeMap[c.grade] ?? 0.0;
        totalPoints += gp * c.credits;
        totalCredits += c.credits;
      }
    }
    return totalCredits == 0 ? 0.0 : totalPoints / totalCredits;
  }

  Map<String, double> summaryReport() {
    List<double> gpas =
    semesters.map((s) => semesterGPA(s.id)).where((g) => g > 0).toList();
    if (gpas.isEmpty) return {'highest': 0, 'lowest': 0, 'average': 0};
    double highest = gpas.reduce((a, b) => a > b ? a : b);
    double lowest = gpas.reduce((a, b) => a < b ? a : b);
    double avg = gpas.reduce((a, b) => a + b) / gpas.length;
    return {'highest': highest, 'lowest': lowest, 'average': avg};
  }

  int totalCourses() {
    return semesters.fold(0, (sum, s) => sum + s.courses.length);
  }

  double requiredNextGPA(double targetCGPA) {
    double totalPoints = 0, totalCredits = 0;
    for (var s in semesters) {
      for (var c in s.courses) {
        final gp = gradeMap[c.grade] ?? 0.0;
        totalPoints += gp * c.credits;
        totalCredits += c.credits;
      }
    }
    if (totalCredits == 0) return targetCGPA;
    double desiredTotalPoints = targetCGPA * (totalCredits + 3);
    return (desiredTotalPoints - totalPoints) / 3;
  }
}

// ------------------------------- UI Layer ------------------------------
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (context, model, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CGPA Calculator',
        theme: model.isDarkMode
            ? ThemeData.dark().copyWith(
            colorScheme:
            ColorScheme.fromSwatch(primarySwatch: model.accentColor))
            : ThemeData(
          primarySwatch: model.accentColor,
          scaffoldBackgroundColor: const Color(0xFFE0F7FA),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: model.accentColor,
                foregroundColor: Colors.white),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}

// ---------------------------- Home Page ----------------------------
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController nameController;
  late TextEditingController rollController;
  final targetCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final model = Provider.of<AppModel>(context, listen: false);
    nameController = TextEditingController(text: model.studentName);
    rollController = TextEditingController(text: model.rollNumber);
  }

  @override
  void dispose() {
    nameController.dispose();
    rollController.dispose();
    targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, _) {
      final cgpa = model.cumulativeCGPA();
      final report = model.summaryReport();
      return Scaffold(
        appBar: AppBar(
          title: const Text('CGPA Calculator'),
          actions: [
            IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: () => _showColorPicker(context, model)),
            IconButton(
                icon: Icon(model.isDarkMode ? Icons.wb_sunny : Icons.dark_mode),
                onPressed: () => model.toggleDarkMode()),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Student Info
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    TextField(
                      controller: nameController,
                      decoration:
                      const InputDecoration(labelText: 'Student Name'),
                      onChanged: (v) =>
                          model.setStudentInfo(v, model.rollNumber),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: rollController,
                      decoration:
                      const InputDecoration(labelText: 'Roll Number'),
                      onChanged: (v) =>
                          model.setStudentInfo(model.studentName, v),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: model.country,
                            items: ['Pakistan', 'USA', 'India', 'Other']
                                .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) =>
                                model.setCountry(v ?? 'Pakistan'),
                            decoration:
                            const InputDecoration(labelText: 'Country'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<double>(
                            value: model.scale,
                            items: [4.0, 5.0, 10.0]
                                .map((s) => DropdownMenuItem(
                                value: s, child: Text('$s Scale')))
                                .toList(),
                            onChanged: (v) => model.setScale(v ?? 4.0),
                            decoration:
                            const InputDecoration(labelText: 'Scale'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('CGPA: ${cgpa.toStringAsFixed(3)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              const SizedBox(height: 10),

              // Target GPA Predictor
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    const Text('🎯 Target GPA Predictor',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: targetCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                      const InputDecoration(labelText: 'Enter Target CGPA'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          final target = double.tryParse(targetCtrl.text);
                          if (target != null && target > 0) {
                            final req = model.requiredNextGPA(target);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'To reach CGPA $target, you need ${req.toStringAsFixed(2)} GPA next semester.')));
                          }
                        },
                        child: const Text('Predict'))
                  ]),
                ),
              ),
              const SizedBox(height: 10),

              // Summary Report
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📊 Summary Report',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text('Highest GPA: ${report['highest']!.toStringAsFixed(2)}'),
                        Text('Lowest GPA: ${report['lowest']!.toStringAsFixed(2)}'),
                        Text('Average GPA: ${report['average']!.toStringAsFixed(2)}'),
                        Text('Total Courses: ${model.totalCourses()}'),
                      ]),
                ),
              ),
              const SizedBox(height: 10),

              ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Semester'),
                  onPressed: () => _showAddSemesterDialog(context)),

              const SizedBox(height: 10),
              ...model.semesters.map((sem) => SemesterTile(semester: sem))
            ],
          ),
        ),
      );
    });
  }

  void _showAddSemesterDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Add Semester'),
          content: TextField(controller: ctrl),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  final name = ctrl.text.trim();
                  if (name.isNotEmpty) {
                    Provider.of<AppModel>(context, listen: false)
                        .addSemester(name);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'))
          ],
        ));
  }

  void _showColorPicker(BuildContext context, AppModel model) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Choose Accent Color'),
          content: Wrap(
            spacing: 10,
            children: [
              _colorOption(context, model, Colors.teal),
              _colorOption(context, model, Colors.blue),
              _colorOption(context, model, Colors.deepPurple),
              _colorOption(context, model, Colors.orange),
              _colorOption(context, model, Colors.pink),
            ],
          ),
        ));
  }

  Widget _colorOption(BuildContext context, AppModel model, MaterialColor color) {
    return GestureDetector(
      onTap: () {
        model.changeAccent(color);
        Navigator.pop(context);
      },
      child: CircleAvatar(backgroundColor: color, radius: 20),
    );
  }
}

// ------------------------ Semester Tile & Course List ------------------------
class SemesterTile extends StatelessWidget {
  final Semester semester;
  const SemesterTile({Key? key, required this.semester}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, _) {
      final gpa = model.semesterGPA(semester.id);
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 4,
        child: ExpansionTile(
          title: Text(semester.name),
          subtitle: Text('GPA: ${gpa.toStringAsFixed(3)}'),
          children: [
            CourseList(semester: semester),
            ButtonBar(
              children: [
                TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Rename'),
                    onPressed: () => _showRenameSemesterDialog(context, semester)),
                TextButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    onPressed: () => model.deleteSemester(semester.id)),
              ],
            )
          ],
        ),
      );
    });
  }

  void _showRenameSemesterDialog(BuildContext context, Semester s) {
    final ctrl = TextEditingController(text: s.name);
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Rename Semester'),
          content: TextField(controller: ctrl),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  final newName = ctrl.text.trim();
                  if (newName.isNotEmpty) {
                    Provider.of<AppModel>(context, listen: false)
                        .renameSemester(s.id, newName);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'))
          ],
        ));
  }
}

class CourseList extends StatelessWidget {
  final Semester semester;
  const CourseList({Key? key, required this.semester}) : super(key: key);
  static const gradeOptions = ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'D', 'F'];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(builder: (context, model, _) {
      return Column(
        children: [
          ...semester.courses.map((c) => ListTile(
            title: Text('${c.code} (${c.credits} cr)'),
            subtitle: Text('Grade: ${c.grade}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditCourseDialog(context, model, c)),
              IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => model.deleteCourse(semester.id, c.id)),
            ]),
          )),
          ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Course'),
              onPressed: () => _showAddCourseDialog(context, model)),
        ],
      );
    });
  }

  void _showAddCourseDialog(BuildContext context, AppModel model) {
    final codeCtrl = TextEditingController();
    final creditCtrl = TextEditingController();
    String grade = 'A';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Add Course'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Course Code')),
            TextField(
                controller: creditCtrl,
                decoration: const InputDecoration(labelText: 'Credits'),
                keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              value: grade,
              items: gradeOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => grade = v ?? 'A',
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  final code = codeCtrl.text.trim();
                  final credits = double.tryParse(creditCtrl.text) ?? 0;
                  if (code.isNotEmpty && credits > 0) {
                    model.addCourse(semester.id, code, credits, grade);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'))
          ],
        ));
  }

  void _showEditCourseDialog(BuildContext context, AppModel model, Course course) {
    final codeCtrl = TextEditingController(text: course.code);
    final creditCtrl = TextEditingController(text: course.credits.toString());
    String grade = course.grade;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Course'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Course Code')),
            TextField(
                controller: creditCtrl,
                decoration: const InputDecoration(labelText: 'Credits'),
                keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              value: grade,
              items: gradeOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => grade = v ?? 'A',
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  final code = codeCtrl.text.trim();
                  final credits = double.tryParse(creditCtrl.text) ?? 0;
                  if (code.isNotEmpty && credits > 0) {
                    model.updateCourse(
                        semester.id,
                        Course(
                            id: course.id,
                            code: code,
                            credits: credits,
                            grade: grade));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'))
          ],
        ));
  }
}
