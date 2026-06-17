import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final String developerTitle = 'Software Engineering Student | Web & Mobile Developer';
  final String email = 'rabeel1937a@gmail.com';
  final String location = 'Burewala, Punjab, Pakistan';

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
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple,
                      Colors.purpleAccent,
                    ],
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
                backgroundImage: AssetImage(
                  'assets/girl_image.jpg',
                ),
              ),

              SizedBox(height: 15),

              // Name
              Text(
                name,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 4),

              // Developer Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  developerTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ),

              SizedBox(height: 8),

              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),

              SizedBox(height: 6),

              Text(
                location,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 20),

              // About Me / Profile Summary
              _SectionCard(
                title: "About Me",
                items: [
                  'Motivated Software Engineering student in the 7th semester at COMSATS University Islamabad, Vehari Campus. Passionate about full-stack web development, mobile applications (Flutter), database systems, and visual programming, with a consistent CGPA of 3.73/4.00.',
                ],
              ),

              // Technical Skills Matrix
              _SectionCard(
                title: "Technical Skills Matrix",
                items: [
                  'Programming Languages: C++, Java, Python, PHP, C#',
                  'Full-Stack Web (MERN): MongoDB, Express.js, React.js, Node.js',
                  'Web Frameworks: Laravel (PHP), HTML, CSS, JavaScript',
                  'Mobile Development: Flutter Development, Firebase Ecosystem',
                  'Database Systems: Database Design, Management & Modeling, SQL',
                  'Other Skills: Visual Programming, Problem Solving',
                ],
              ),

              // Soft Skills & Strengths
              _SectionCard(
                title: "Soft Skills & Strengths",
                items: [
                  'Quick learner with a strong analytical mindset',
                  'Hardworking, responsible, and self-motivated',
                  'Excellent communication and interpersonal skills',
                  'Performs effectively under pressure and strict deadlines',
                  'Strong team player, active collaborator, and detail-oriented',
                ],
              ),

              // Education Section
              _SectionCard(
                title: "Education",
                items: [
                  'BS Software Engineering - COMSATS University Islamabad, Vehari Campus (2023 - Present)',
                  '7th Semester Status | CGPA: 3.73 / 4.00',
                  'Intermediate (FSc Pre-Medical) - Punjab Group of Colleges, Burewala',
                  'Matriculation (Science Group) - Jinnah Model Girls High School, Burewala',
                ],
              ),

              // Projects Section
              _SectionCard(
                title: "Projects",
                items: [
                  'Expense Management System (MERN Stack)',
                  'Hospital Management System (Visual Programming & DB)',
                  'House Rent Prediction System (Machine Learning)',
                  'Coffee Management System (Laravel Web)',
                  'Inventory Management System (Software Construction)',
                  'Quick Check Hub (Assignment Management System)',
                  'Flutter Apps Suite: Dice App, CGPA Calculator, Task Management, Point of Sale (POS) App, Profile App, Committee Management System',
                ],
              ),

              // Achievements
              _SectionCard(
                title: "Achievements",
                items: [
                  'Consistent Good Academic Standing',
                  'Maintained an overall CGPA of 3.73 / 4.00',
                  'Strong Core Engineering Foundations',
                ],
              ),

              // Languages Section
              _SectionCard(
                title: "Languages",
                items: [
                  'English - Professional Proficiency',
                  'Urdu - Native / Full Professional Proficiency',
                ],
              ),

              // Social Links (Formatted correctly matching your link preview)
              _SectionCard(
                title: "Social Links",
                items: [
                  'GitHub: https://github.com/rabeelfatma',
                  'LinkedIn: https://linkedin.com/in/rabeel-fatima-0bb5b7415',
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

  const _SectionCard({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString.trim());
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  (item) {
                final bool isLink = item.contains('https://') || item.contains('github.com') || item.contains('linkedin.com');

                String displayLabel = item;
                String urlToLaunch = '';

                if (isLink) {
                  if (item.contains(': ')) {
                    List<String> parts = item.split(': ');
                    displayLabel = parts[0] + ': ';
                    urlToLaunch = parts.sublist(1).join(': ');
                  } else {
                    urlToLaunch = item;
                    displayLabel = '';
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.deepPurple,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: isLink
                            ? RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Roboto'),
                            children: [
                              if (displayLabel.isNotEmpty)
                                TextSpan(text: displayLabel),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: () => _launchURL(context, urlToLaunch.contains('http') ? urlToLaunch : 'https://$urlToLaunch'),
                                  child: Text(
                                    urlToLaunch,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue.shade700,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            : Text(
                          item,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

  }
}