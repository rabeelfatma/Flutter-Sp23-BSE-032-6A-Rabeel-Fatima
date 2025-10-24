
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(CommitteeApp());

class CommitteeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Committee Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.blueAccent,
          surface: Colors.black,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: LoginScreen(),
    );
  }
}

/// ---------------- MODELS ----------------
class Member {
  String name;
  bool hasPaid;
  double amountPaid;
  Member(this.name, {this.hasPaid = false, this.amountPaid = 0});
  Map<String, dynamic> toJson() =>
      {'name': name, 'hasPaid': hasPaid, 'amountPaid': amountPaid};
  static Member fromJson(Map<String, dynamic> json) => Member(json['name'],
      hasPaid: json['hasPaid'] ?? false, amountPaid: json['amountPaid'] ?? 0);
}

class Committee {
  String name;
  DateTime startDate;
  DateTime endDate;
  double totalAmount;
  List<Member> members;
  Committee(this.name, this.members,
      {DateTime? start, DateTime? end, this.totalAmount = 0})
      : startDate = start ?? DateTime.now(),
        endDate = end ?? DateTime.now().add(Duration(days: 30));
  Map<String, dynamic> toJson() => {
    'name': name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'totalAmount': totalAmount,
    'members': members.map((m) => m.toJson()).toList()
  };
  static Committee fromJson(Map<String, dynamic> json) => Committee(
    json['name'],
    (json['members'] as List<dynamic>?)
        ?.map((m) => Member.fromJson(m as Map<String, dynamic>))
        .toList() ??
        [],
    start:
    json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
    end: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    totalAmount: json['totalAmount'] != null
        ? (json['totalAmount'] as num).toDouble()
        : 0,
  );
}

class Message {
  String sender;
  String receiver;
  String content;
  DateTime timestamp;
  Message(this.sender, this.receiver, this.content, this.timestamp);
  Map<String, dynamic> toJson() => {
    'sender': sender,
    'receiver': receiver,
    'content': content,
    'timestamp': timestamp.toIso8601String()
  };
  static Message fromJson(Map<String, dynamic> json) => Message(
      json['sender'] ?? '',
      json['receiver'] ?? '',
      json['content'] ?? '',
      DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()));
}

class Meeting {
  String title;
  DateTime dateTime;
  String description;
  Meeting(this.title, this.dateTime, this.description);
  Map<String, dynamic> toJson() => {
    'title': title,
    'dateTime': dateTime.toIso8601String(),
    'description': description
  };
  static Meeting fromJson(Map<String, dynamic> json) => Meeting(
      json['title'] ?? '',
      DateTime.parse(json['dateTime'] ?? DateTime.now().toIso8601String()),
      json['description'] ?? '');
}

/// ---------------- SHARED KEYS ----------------
const String kAdminEmailKey = 'admin_email';
const String kAdminPassKey = 'admin_pass';
const String kCommitteesKey = 'committees_v6';
const String kMessagesKey = 'messages_v6';
const String kMeetingsKey = 'meetings_v6';

/// ---------------- LOGIN SCREEN ----------------
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool loading = true;
  String savedEmail = '';
  String savedPass = '';

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedEmail = prefs.getString(kAdminEmailKey) ?? 'admin';
      savedPass = prefs.getString(kAdminPassKey) ?? 'admin';
      loading = false;
    });
  }

  Future<void> _createAccount() async {
    final email = _emailController.text;
    final pass = _passController.text;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kAdminEmailKey, email);
    await prefs.setString(kAdminPassKey, pass);
    setState(() {
      savedEmail = email;
      savedPass = pass;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Admin account created')));
  }

  void _login() {
    if (_emailController.text == savedEmail &&
        _passController.text == savedPass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credentials do not match saved admin.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: Center(
        child: Container(
          width: 340,
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.groups, color: Colors.blueAccent, size: 60),
              SizedBox(height: 15),
              Text("Committee Management System",
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    minimumSize: Size(double.infinity, 45)),
                onPressed: _login,
                child: Text("Login as Admin",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: _createAccount,
                child: Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- DASHBOARD ----------------
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Committee> committees = [];
  List<Message> messages = [];
  List<Meeting> meetings = [];
  List<Member> drawnMembers = [];
  bool excludeAlreadyDrawn = true;
  String lastDraw = '';
  String selectedAccount = '';

  final _committeeController = TextEditingController();
  final _memberController = TextEditingController();
  final _amountController = TextEditingController();
  final _meetingController = TextEditingController();
  final _msgController = TextEditingController();

  String _msgReceiver = '';
  Committee? _selectedCommitteeForMember;

  @override
  void initState() {
    super.initState();
    _loadData();
    Timer.periodic(Duration(minutes: 1), (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reminder: Pre-draw pending!")));
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? comStr = prefs.getString(kCommitteesKey);
    String? msgStr = prefs.getString(kMessagesKey);
    String? meetStr = prefs.getString(kMeetingsKey);

    setState(() {
      committees = comStr != null
          ? (jsonDecode(comStr) as List)
          .map((c) => Committee.fromJson(c))
          .toList()
          : [];
      messages = msgStr != null
          ? (jsonDecode(msgStr) as List)
          .map((m) => Message.fromJson(m))
          .toList()
          : [];
      meetings = meetStr != null
          ? (jsonDecode(meetStr) as List)
          .map((m) => Meeting.fromJson(m))
          .toList()
          : [];
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        kCommitteesKey, jsonEncode(committees.map((c) => c.toJson()).toList()));
    await prefs.setString(
        kMessagesKey, jsonEncode(messages.map((m) => m.toJson()).toList()));
    await prefs.setString(
        kMeetingsKey, jsonEncode(meetings.map((m) => m.toJson()).toList()));
  }

  List<Member> _getUndrawnMembers() {
    List<Member> allMembers = committees.expand((c) => c.members).toList();
    return excludeAlreadyDrawn
        ? allMembers.where((m) => !drawnMembers.contains(m)).toList()
        : allMembers;
  }

  void _drawMember(Member Function(List<Member>) selector, String type) {
    List<Member> undrawn = _getUndrawnMembers();
    if (undrawn.isEmpty) return;
    setState(() {
      Member selected = selector(undrawn);
      drawnMembers.add(selected);
      lastDraw = '$type: ${selected.name}';
    });
  }

  void _drawRandom() =>
      _drawMember((u) => u[Random().nextInt(u.length)], "Random");
  void _drawFirst() => _drawMember((u) => u.first, "First");
  void _drawNeediest() => _drawMember((u) => u.last, "Neediest");

  void _drawSpinner() {
    List<Member> undrawn = _getUndrawnMembers();
    if (undrawn.isEmpty) return;
    final rand = Random();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (timer.tick > 10) {
        timer.cancel();
        setState(() {
          Member selected = undrawn[rand.nextInt(undrawn.length)];
          drawnMembers.add(selected);
          lastDraw = 'Spinner: ${selected.name}';
        });
      }
    });
  }

  void _showCommitteeDialog() {
    final _nameController = TextEditingController();
    final _totalController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Create Committee"),
          content: StatefulBuilder(
              builder: (context, setStateDialog) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: _nameController,
                      decoration:
                      InputDecoration(labelText: "Committee Name")),
                  SizedBox(height: 10),
                  TextField(
                      controller: _totalController,
                      keyboardType: TextInputType.number,
                      decoration:
                      InputDecoration(labelText: "Total Amount")),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (date != null) {
                              setStateDialog(() => startDate = date);
                            }
                          },
                          child: Text(startDate == null
                              ? "Select Start Date"
                              : startDate!
                              .toLocal()
                              .toString()
                              .split(' ')[0])),
                      SizedBox(width: 10),
                      TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                                context: context,
                                initialDate:
                                startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (date != null) {
                              setStateDialog(() => endDate = date);
                            }
                          },
                          child: Text(endDate == null
                              ? "Select End Date"
                              : endDate!
                              .toLocal()
                              .toString()
                              .split(' ')[0])),
                    ],
                  ),
                ],
              )),
          actions: [
            ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isEmpty) return;
                  setState(() {
                    committees.add(Committee(
                        _nameController.text,
                        [],
                        start: startDate,
                        end: endDate,
                        totalAmount:
                        double.tryParse(_totalController.text) ?? 0));
                  });
                  _saveData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Committee Created Successfully")));
                },
                child: Text("Create"))
          ],
        ));
  }

  void _addMember() {
    if (_selectedCommitteeForMember == null ||
        _memberController.text.trim().isEmpty) return;
    setState(() {
      double amount = double.tryParse(_amountController.text) ?? 0;
      _selectedCommitteeForMember!.members.add(Member(_memberController.text,
          hasPaid: amount > 0, amountPaid: amount));
    });
    _memberController.clear();
    _amountController.clear();
    _saveData();
  }

  void _togglePayment(Member member) {
    setState(() {
      member.hasPaid = !member.hasPaid;
    });
    _saveData();
  }

  void _createMeeting(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      meetings.add(Meeting(title, DateTime.now(), "Scheduled meeting"));
    });
    _meetingController.clear();
    _saveData();
  }

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty || _msgReceiver.isEmpty) return;
    setState(() {
      messages.add(Message(
          "Admin", _msgReceiver, _msgController.text, DateTime.now()));
    });
    _msgController.clear();
    _msgReceiver = '';
    _saveData();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Message Sent Successfully")));
  }

  void _showPaymentDialog() {
    final _dialogName = TextEditingController();
    final _dialogAccount = TextEditingController();
    final _dialogAmount = TextEditingController();

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Send Payment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _dialogName,
                  decoration: InputDecoration(labelText: "Member Name")),
              TextField(
                  controller: _dialogAccount,
                  decoration:
                  InputDecoration(labelText: "Account Number")),
              TextField(
                  controller: _dialogAmount,
                  decoration: InputDecoration(labelText: "Amount")),
            ],
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  if (_dialogName.text.isNotEmpty &&
                      _dialogAmount.text.isNotEmpty) {
                    double amount =
                        double.tryParse(_dialogAmount.text) ?? 0;
                    for (var c in committees) {
                      for (var m in c.members) {
                        if (m.name == _dialogName.text) {
                          m.amountPaid += amount;
                          m.hasPaid = true;
                        }
                      }
                    }
                    _saveData();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Payment Sent Successfully")));
                  }
                },
                child: Text("Send"))
          ],
        ));
  }

  void _showAccountDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Select Account"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                    title: Text("JazzCash"),
                    onTap: () {
                      setState(() => selectedAccount = "JazzCash");
                      Navigator.pop(context);
                      _showPaymentDialog();
                    }),
                ListTile(
                    title: Text("Easypaisa"),
                    onTap: () {
                      setState(() => selectedAccount = "Easypaisa");
                      Navigator.pop(context);
                      _showPaymentDialog();
                    }),
                ListTile(
                    title: Text("Bank"),
                    onTap: () {
                      setState(() => selectedAccount = "Bank");
                      Navigator.pop(context);
                      _showPaymentDialog();
                    }),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Member> allMembers = committees.expand((c) => c.members).toList();
    double totalPaid = allMembers.fold(0, (sum, m) => sum + m.amountPaid);
    double totalAmount =
    committees.fold(0, (sum, c) => sum + c.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
              onPressed: _showCommitteeDialog,
              icon: Icon(Icons.add_circle_outline))
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          Text("Total Committees: ${committees.length}",
              style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text("Total Collected: \$${totalPaid.toStringAsFixed(2)} / "
              "\$${totalAmount.toStringAsFixed(2)}"),
          SizedBox(height: 15),
          SizedBox(
            height: 200,
            child: LineChart(LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: committees
                      .asMap()
                      .entries
                      .map((e) => FlSpot(
                      e.key.toDouble(),
                      e.value.members.fold(
                          0, (sum, m) => sum + m.amountPaid)))
                      .toList(),
                  isCurved: true,
                  barWidth: 3,
                  belowBarData: BarAreaData(show: true),
                )
              ],
            )),
          ),
          SizedBox(height: 15),
          Text("Committees:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          for (var c in committees)
            ExpansionTile(
              title: Text("${c.name} (${c.members.length} members)"),
              children: [
                for (var m in c.members)
                  ListTile(
                    title: Text(m.name),
                    subtitle:
                    Text("Paid: \$${m.amountPaid.toStringAsFixed(2)}"),
                    trailing: IconButton(
                        icon: Icon(
                          m.hasPaid
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: m.hasPaid ? Colors.green : Colors.grey,
                        ),
                        onPressed: () => _togglePayment(m)),
                  ),
              ],
            ),
          SizedBox(height: 20),
          Text("Member Management",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButton<Committee>(
            isExpanded: true,
            value: _selectedCommitteeForMember,
            hint: Text("Select Committee"),
            onChanged: (val) =>
                setState(() => _selectedCommitteeForMember = val),
            items: committees
                .map((c) =>
                DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
          ),
          TextField(
              controller: _memberController,
              decoration: InputDecoration(labelText: "Member Name")),
          TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: "Amount Paid")),
          SizedBox(height: 5),
          ElevatedButton(onPressed: _addMember, child: Text("Add Member")),
          SizedBox(height: 20),
          Text("Draw System",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SwitchListTile(
              title: Text("Exclude Already Drawn"),
              value: excludeAlreadyDrawn,
              onChanged: (val) =>
                  setState(() => excludeAlreadyDrawn = val)),
          Wrap(
            spacing: 10,
            children: [
              ElevatedButton(onPressed: _drawRandom, child: Text("Random")),
              ElevatedButton(onPressed: _drawFirst, child: Text("First")),
              ElevatedButton(onPressed: _drawNeediest, child: Text("Neediest")),
              ElevatedButton(onPressed: _drawSpinner, child: Text("Spinner")),
            ],
          ),
          if (lastDraw.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text("Last Draw: $lastDraw",
                  style: TextStyle(color: Colors.blueAccent)),
            ),
          SizedBox(height: 20),
          Text("Meetings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TextField(
              controller: _meetingController,
              decoration: InputDecoration(labelText: "Meeting Title")),
          SizedBox(height: 5),
          ElevatedButton(
              onPressed: () => _createMeeting(_meetingController.text),
              child: Text("Schedule Meeting")),
          for (var m in meetings)
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.blueAccent),
              title: Text(m.title),
              subtitle: Text(m.dateTime.toString().split('.')[0]),
            ),
          SizedBox(height: 20),
          Text("Messaging",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TextField(
              onChanged: (val) => _msgReceiver = val,
              decoration: InputDecoration(labelText: "Receiver Name")),
          TextField(
              controller: _msgController,
              decoration: InputDecoration(labelText: "Message Content")),
          SizedBox(height: 5),
          ElevatedButton(onPressed: _sendMessage, child: Text("Send Message")),
          for (var msg in messages.reversed.take(5))
            ListTile(
              title: Text("${msg.sender} ➜ ${msg.receiver}"),
              subtitle: Text(msg.content),
              trailing: Text(msg.timestamp.toString().split('.')[0]),
            ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: _showAccountDialog,
              child: Text("Send Payment")),
          if (selectedAccount.isNotEmpty)
            Text("Selected: $selectedAccount",
                style: TextStyle(color: Colors.blueAccent)),
        ],
      ),
    );
  }
}
