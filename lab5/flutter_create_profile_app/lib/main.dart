import 'package:flutter/material.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String name = 'Rabeel Fatima';
  final String email = 'rabeelfatima@example.com';
  final String contact = '0315-0160169';
  final String location = 'Burewala, Pakistan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                  ),
                ),
                child: Center(
                  child: Text(
                    'Profile App',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Profile Image
              CircleAvatar(
                radius: 65,
                backgroundImage: AssetImage('assets/girl_image.jpg'),
              ),

              SizedBox(height: 15),

              // Name & Contact Info
              Text(
                name,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(email, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              SizedBox(height: 6),
              Text(contact, style: TextStyle(fontSize: 16, color: Colors.black87)),
              SizedBox(height: 6),
              Text(location, style: TextStyle(fontSize: 16, color: Colors.grey[600])),

              SizedBox(height: 20),

              // Skills Section
              _SectionCard(
                title: "Skills",
                items: [
                  'Flutter Development',
                  'Mobile App Development',
                  'Web Development',
                  'Database Management',
                  'Networking',
                ],
              ),

              // Education Section
              _SectionCard(
                title: "Education",
                items: [
                  'BSSE, COMSATS University (2023–2027)',
                ],
              ),

              // Projects Section
              _SectionCard(
                title: "Projects",
                items: [
                  'House Rent Prediction App',
                  'Hospital Management System',
                ],
              ),

              // Social Links
              _SectionCard(
                title: "Social Links",
                items: [
                  'GitHub',
                ],
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _SectionCard({Key? key, required this.title, required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 10),
            ...items.map(
                  (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.deepPurple, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
