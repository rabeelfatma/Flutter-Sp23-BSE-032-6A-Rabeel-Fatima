// lib/main.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// ---------------------- MODELS ----------------------

class Member {
  String name;
  bool hasPaid;

  Member(this.name, {this.hasPaid = false});

  Map<String, dynamic> toJson() => {'name': name, 'hasPaid': hasPaid};
  static Member fromJson(Map<String, dynamic> json) =>
      Member(json['name'], hasPaid: json['hasPaid'] ?? false);
}

class Committee {
  String name;
  List<Member> members;

  Committee(this.name, this.members);

  Map<String, dynamic> toJson() => {
    'name': name,
    'members': members.map((m) => m.toJson()).toList(),
  };

  static Committee fromJson(Map<String, dynamic> json) => Committee(
      json['name'],
      (json['members'] as List<dynamic>?)
          ?.map((m) => Member.fromJson(m as Map<String, dynamic>))
          .toList() ??
          []);
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
  Map<String, dynamic> toJson() =>
      {'title': title, 'dateTime': dateTime.toIso8601String(), 'description': description};

  static Meeting fromJson(Map<String, dynamic> json) => Meeting(
      json['title'] ?? '',
      DateTime.parse(json['dateTime'] ?? DateTime.now().toIso8601String()),
      json['description'] ?? '');
}

// ---------------------- SHARED PREFERENCE KEYS ----------------------

const String kAdminEmailKey = 'admin_email';
const String kAdminPassKey = 'admin_pass';
const String kCommitteesKey = 'committees v1';
const String kMessagesKey = 'messages v1';
const String kMeetingsKey = 'meetings v1';

// ---------------------- LOGIN SCREEN (Only Admin) ----------------------

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// Note: per request there are NO email/password restrictions.
// "Create Account" saves admin credentials to SharedPreferences.

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
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin account created (no validation).')));
  }

  void _login() {
    // Only admin can login. But user requested no restriction on inputs.
    // We'll treat any provided email/pass as valid if they match saved ones.
    // If saved ones are empty (first run), allow login regardless.
    if (savedEmail.isEmpty && savedPass.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
      return;
    }
    if (_emailController.text == savedEmail &&
        _passController.text == savedPass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } else {
      // if user insisted "give me same same my code" with no restriction,
      // still we give a hint but do not enforce strong validation.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credentials do not match saved admin.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(body: Center(child: CircularProgressIndicator()));
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
              Text("Committee Management System (Admin Only)",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email ",
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password ",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    minimumSize: Size(double.infinity, 45)),
                onPressed: _login,
                child: Text("Login as Admin", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: _createAccount,
                child: Text("Create Account (store admin in SharedPreferences)"),
              ),
              SizedBox(height: 6),
              Text(
                "Default admin: 'admin' / 'admin' until you create one.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- DASHBOARD & FEATURES ----------------------

class DashboardScreen extends StatefulWidget {
  DashboardScreen();

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<Committee> committees = [];
  List<Message> messages = [];
  List<Meeting> meetings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    // Load committees
    final String? cJson = prefs.getString(kCommitteesKey);
    if (cJson != null) {
      final list = json.decode(cJson) as List<dynamic>;
      committees = list.map((c) => Committee.fromJson(c)).toList();
    } else {
      // default data
      committees = [
        Committee("Finance Committee", [Member("Ali"), Member("Sara"), Member("Usman")]),
        Committee("Academic Board", [Member("Ayesha"), Member("Zain"), Member("Fatima")]),
      ];
    }

    // Messages
    final String? mJson = prefs.getString(kMessagesKey);
    if (mJson != null) {
      final list = json.decode(mJson) as List<dynamic>;
      messages = list.map((m) => Message.fromJson(m)).toList();
    }

    // Meetings
    final String? mtJson = prefs.getString(kMeetingsKey);
    if (mtJson != null) {
      final list = json.decode(mtJson) as List<dynamic>;
      meetings = list.map((m) => Meeting.fromJson(m)).toList();
    }

    setState(() => loading = false);
  }

  Future<void> _saveCommittees() async {
    final prefs = await SharedPreferences.getInstance();
    final j = json.encode(committees.map((c) => c.toJson()).toList());
    await prefs.setString(kCommitteesKey, j);
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final j = json.encode(messages.map((m) => m.toJson()).toList());
    await prefs.setString(kMessagesKey, j);
  }

  Future<void> _saveMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final j = json.encode(meetings.map((m) => m.toJson()).toList());
    await prefs.setString(kMeetingsKey, j);
  }

  void sendMessage(String receiver, String msg) {
    messages.add(Message("Admin", receiver, msg, DateTime.now()));
    _saveMessages();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message sent to $receiver")));
    setState(() {});
  }

  void togglePaid(Committee c, Member m) {
    setState(() {
      m.hasPaid = !m.hasPaid;
    });
    _saveCommittees();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${m.name} payment status updated.")));
  }

  void addCommittee(String name) {
    setState(() {
      committees.add(Committee(name, []));
    });
    _saveCommittees();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Committee '$name' added.")));
  }

  void addMember(String committeeName, String memberName) {
    final c = committees.firstWhere((c) => c.name == committeeName, orElse: () => committees.first);
    setState(() {
      c.members.add(Member(memberName));
    });
    _saveCommittees();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Member '$memberName' added to ${c.name}.")));
  }

  void scheduleMeeting(Meeting meeting) {
    meetings.add(meeting);
    _saveMeetings();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Meeting scheduled on ${meeting.dateTime}")));
    final now = DateTime.now();
    final diff = meeting.dateTime.difference(now).inSeconds - 5;
    if (diff > 0) {
      Timer(Duration(seconds: diff), () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Reminder: '${meeting.title}' starts soon!")));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    final pages = [
      HomeDashboard(committees: committees),
      CommitteeScreenV2(
        committees: committees,
        onTogglePaid: togglePaid,
        onAddCommittee: addCommittee,
        onAddMember: addMember,
      ),
      MessageCenterV2(
        messages: messages,
        committees: committees,
        onSend: sendMessage,
      ),
      MeetingSchedulerScreenV2(onAddMeeting: scheduleMeeting, meetings: meetings),
      ReportScreenV2(committees: committees),
    ];

    final titles = ["Dashboard", "Committees", "Messages", "Meetings", "Reports"];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedIndex])),
      body: AnimatedSwitcher(duration: Duration(milliseconds: 400), child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Committees"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Meetings"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
        ],
      ),
    );
  }
}

// ---------------------- HOME DASHBOARD ----------------------

class HomeDashboard extends StatelessWidget {
  final List<Committee> committees;
  const HomeDashboard({required this.committees});

  int totalMembersCount() => committees.fold(0, (sum, c) => sum + c.members.length);

  int paidMembersCount() =>
      committees.fold(0, (sum, c) => sum + c.members.where((m) => m.hasPaid).length);

  double totalFundsFromPaidMembers() {
    // per-member paid amount = 2000 (as earlier)
    return paidMembersCount() * 2000.0;
  }

  @override
  Widget build(BuildContext context) {
    final totalMembers = totalMembersCount();
    final funds = totalFundsFromPaidMembers();

    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        Text("Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DashboardCard(title: "Committees", count: committees.length, icon: Icons.groups),
            DashboardCard(title: "Members", count: totalMembers, icon: Icons.person),
            DashboardCard(title: "Paid", count: paidMembersCount(), icon: Icons.money),
          ],
        ),
        SizedBox(height: 30),
        Text("Total Funds (from paid members): PKR ${funds.toStringAsFixed(0)}", style: TextStyle(fontSize: 18)),
        SizedBox(height: 200, child: DynamicBarChart(committees: committees)),
      ],
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  const DashboardCard({required this.title, required this.count, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 100,
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.blueAccent),
        SizedBox(height: 6),
        Text(title),
        Text("$count", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
      ]),
    );
  }
}

// ---------------------- COMMITTEE SCREEN V2 (add/search/filter/persistence) ----------------------

class CommitteeScreenV2 extends StatefulWidget {
  final List<Committee> committees;
  final Function(Committee, Member) onTogglePaid;
  final Function(String) onAddCommittee;
  final Function(String, String) onAddMember;

  CommitteeScreenV2({required this.committees, required this.onTogglePaid, required this.onAddCommittee, required this.onAddMember});

  @override
  _CommitteeScreenV2State createState() => _CommitteeScreenV2State();
}

class _CommitteeScreenV2State extends State<CommitteeScreenV2> {
  String committeeQuery = '';
  String memberQuery = '';
  String selectedCommitteeForMember = '';
  final TextEditingController _committeeSearch = TextEditingController();
  final TextEditingController _memberSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.committees.isNotEmpty) selectedCommitteeForMember = widget.committees.first.name;
  }

  List<Committee> get filteredCommittees {
    if (committeeQuery.trim().isEmpty) return widget.committees;
    final q = committeeQuery.toLowerCase();
    return widget.committees.where((c) => c.name.toLowerCase().contains(q) || c.members.any((m) => m.name.toLowerCase().contains(q))).toList();
  }

  List<Member> membersOf(Committee c) {
    if (memberQuery.trim().isEmpty) return c.members;
    final q = memberQuery.toLowerCase();
    return c.members.where((m) => m.name.toLowerCase().contains(q)).toList();
  }

  void _showAddCommitteeDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Add Committee"),
        content: TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Committee name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) {
                  // per request no restriction — but avoid empty names
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a name.")));
                  return;
                }
                widget.onAddCommittee(nameCtrl.text.trim());
                Navigator.pop(context);
                setState(() {
                  if (widget.committees.isNotEmpty) selectedCommitteeForMember = widget.committees.first.name;
                });
              },
              child: Text("Add"))
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Add Member"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Member name")),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedCommitteeForMember.isEmpty ? null : selectedCommitteeForMember,
            items: widget.committees.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => selectedCommitteeForMember = v ?? ''),
            decoration: InputDecoration(labelText: "Select Committee"),
          )
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || selectedCommitteeForMember.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter member name and pick a committee.")));
                  return;
                }
                widget.onAddMember(selectedCommitteeForMember, nameCtrl.text.trim());
                Navigator.pop(context);
                setState(() {});
              },
              child: Text("Add"))
        ],
      ),
    );
  }

  Widget committeeCard(Committee c) {
    final paidCount = c.members.where((m) => m.hasPaid).length;
    final funds = paidCount * 2000.0;
    return Card(
      color: Colors.grey[900],
      child: ExpansionTile(
        title: Row(children: [
          Expanded(child: Text("${c.name} — PKR ${funds.toStringAsFixed(0)}")),
          SizedBox(width: 8),
          Text("${c.members.length} members", style: TextStyle(fontSize: 12)),
        ]),
        children: membersOf(c).map((m) {
          return ListTile(
            title: Text(m.name),
            subtitle: Text(m.hasPaid ? "Paid" : "Pending"),
            trailing: IconButton(
              icon: Icon(m.hasPaid ? Icons.check_circle : Icons.circle_outlined, color: m.hasPaid ? Colors.green : Colors.grey),
              onPressed: () {
                widget.onTogglePaid(c, m);
                setState(() {});
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = filteredCommittees;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _committeeSearch,
              decoration: InputDecoration(prefixIcon: Icon(Icons.search), labelText: "Search committees or members"),
              onChanged: (v) => setState(() => committeeQuery = v),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton.icon(onPressed: _showAddCommitteeDialog, icon: Icon(Icons.add), label: Text("Add Committee")),
          SizedBox(width: 8),
          ElevatedButton.icon(onPressed: _showAddMemberDialog, icon: Icon(Icons.person_add), label: Text("Add Member")),
        ]),
        SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _memberSearch,
              decoration: InputDecoration(prefixIcon: Icon(Icons.filter_list), labelText: "Filter members (within committee open)"),
              onChanged: (v) => setState(() => memberQuery = v),
            ),
          ),
        ]),
        SizedBox(height: 12),
        Expanded(
          child: list.isEmpty
              ? Center(child: Text("No committees found."))
              : ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, idx) => committeeCard(list[idx]),
          ),
        ),
      ]),
    );
  }
}

// ---------------------- MESSAGE CENTER V2 ----------------------

class MessageCenterV2 extends StatefulWidget {
  final List<Message> messages;
  final List<Committee> committees;
  final Function(String, String) onSend;

  MessageCenterV2({required this.messages, required this.onSend, required this.committees});

  @override
  _MessageCenterV2State createState() => _MessageCenterV2State();
}

class _MessageCenterV2State extends State<MessageCenterV2> {
  final TextEditingController msgCtrl = TextEditingController();
  String selectedReceiver = '';

  @override
  void initState() {
    super.initState();
    final members = widget.committees.expand((c) => c.members.map((m) => m.name)).toList();
    if (members.isNotEmpty) selectedReceiver = members.first;
  }

  @override
  Widget build(BuildContext context) {
    final allMembers = widget.committees.expand((c) => c.members.map((m) => m.name)).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: "Select Member to message"),
          value: selectedReceiver.isEmpty ? null : selectedReceiver,
          items: allMembers.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (v) => setState(() => selectedReceiver = v ?? ''),
        ),
        SizedBox(height: 8),
        TextField(controller: msgCtrl, decoration: InputDecoration(labelText: "Message")),
        SizedBox(height: 8),
        ElevatedButton(
            onPressed: selectedReceiver.isEmpty || msgCtrl.text.trim().isEmpty
                ? null
                : () {
              widget.onSend(selectedReceiver, msgCtrl.text.trim());
              msgCtrl.clear();
              setState(() {});
            },
            child: Text("Send Message")),
        SizedBox(height: 12),
        Expanded(
          child: widget.messages.isEmpty
              ? Center(child: Text("No messages"))
              : ListView.builder(
              itemCount: widget.messages.length,
              itemBuilder: (context, idx) {
                final msg = widget.messages[idx];
                return Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    title: Text("${msg.sender} ➜ ${msg.receiver}"),
                    subtitle: Text(msg.content),
                    trailing: Text("${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}"),
                  ),
                );
              }),
        )
      ]),
    );
  }
}

// ---------------------- MEETING SCHEDULER V2 ----------------------

class MeetingSchedulerScreenV2 extends StatefulWidget {
  final Function(Meeting) onAddMeeting;
  final List<Meeting> meetings;
  MeetingSchedulerScreenV2({required this.onAddMeeting, required this.meetings});

  @override
  _MeetingSchedulerScreenV2State createState() => _MeetingSchedulerScreenV2State();
}

class _MeetingSchedulerScreenV2State extends State<MeetingSchedulerScreenV2> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? selectedDateTime;

  void _pickDateTime() async {
    DateTime? date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2100), initialDate: DateTime.now());
    if (date == null) return;
    TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: [
        TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: "Meeting Title")),
        TextField(controller: _descCtrl, decoration: InputDecoration(labelText: "Description")),
        SizedBox(height: 8),
        ElevatedButton.icon(onPressed: _pickDateTime, icon: Icon(Icons.calendar_today), label: Text(selectedDateTime == null ? "Pick Date & Time" : "${selectedDateTime!.day}/${selectedDateTime!.month} - ${selectedDateTime!.hour}:${selectedDateTime!.minute.toString().padLeft(2, '0')}")),
        SizedBox(height: 8),
        ElevatedButton(onPressed: selectedDateTime == null || _titleCtrl.text.trim().isEmpty ? null : () {
          widget.onAddMeeting(Meeting(_titleCtrl.text.trim(), selectedDateTime!, _descCtrl.text.trim()));
          _titleCtrl.clear();
          _descCtrl.clear();
          setState(() => selectedDateTime = null);
        }, child: Text("Schedule Meeting")),
        SizedBox(height: 12),
        Expanded(child: widget.meetings.isEmpty ? Center(child: Text("No meetings")) : ListView.builder(itemCount: widget.meetings.length, itemBuilder: (context, idx) {
          final m = widget.meetings[idx];
          return Card(color: Colors.grey[900], child: ListTile(leading: Icon(Icons.event, color: Colors.blueAccent), title: Text(m.title), subtitle: Text("${m.description}\n${m.dateTime.day}/${m.dateTime.month} ${m.dateTime.hour}:${m.dateTime.minute.toString().padLeft(2, '0')}")));
        }))
      ]),
    );
  }
}

// ---------------------- REPORT SCREEN V2 ----------------------

class ReportScreenV2 extends StatelessWidget {
  final List<Committee> committees;
  ReportScreenV2({required this.committees});

  double fundsOfCommittee(Committee c) {
    final paidCount = c.members.where((m) => m.hasPaid).length;
    return paidCount * 2000.0;
  }

  @override
  Widget build(BuildContext context) {
    final totalFunds = committees.fold(0.0, (sum, c) => sum + fundsOfCommittee(c));
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Text("Reports Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text("Total Committees: ${committees.length}"),
          Text("Total Funds (from paid members): PKR ${totalFunds.toStringAsFixed(0)}"),
          SizedBox(height: 20),
          SizedBox(height: 250, child: DynamicBarChart(committees: committees)),
        ]),
      ),
    );
  }
}

// ---------------------- DYNAMIC BAR CHART ----------------------

class DynamicBarChart extends StatelessWidget {
  final List<Committee> committees;
  DynamicBarChart({required this.committees});

  @override
  Widget build(BuildContext context) {
    // Each paid member contributes 2000
    final values = committees.map((c) => c.members.where((m) => m.hasPaid).length * 2000.0).toList();
    final maxY = (values.isEmpty ? 10.0 : values.reduce((a, b) => a > b ? a : b)) + 2000;

    return BarChart(
      BarChartData(
        maxY: maxY <= 0 ? 10 : maxY,
        alignment: BarChartAlignment.spaceAround,
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(toY: values[i])],
          );
        }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < committees.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        committees[i].name,
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    );
                  }
                  return SizedBox();
          return Text('');
              },
              reservedSize: 60,
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
