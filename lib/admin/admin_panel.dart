import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:study_go/admin/list_courses.dart';
import 'package:study_go/admin/list_students.dart';
import 'package:study_go/admin/list_teachers.dart';
import 'package:study_go/admin/payment_reminder.dart';
import 'package:study_go/admin/admin_welcome_screen.dart';
import 'package:study_go/admin/report.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  AdminPanelState createState() => AdminPanelState();
}

class AdminPanelState extends State<AdminPanel> {
  int studentCount = 0;
  int teacherCount = 0;
  int courseCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    DatabaseReference database = FirebaseDatabase.instance.ref();

    database.child('students').onValue.listen((event) {
      setState(() {
        studentCount = event.snapshot.children.length;
      });
    });

    database.child('teachers').onValue.listen((event) {
      setState(() {
        teacherCount = event.snapshot.children.length;
      });
    });

    database.child('courses').onValue.listen((event) {
      setState(() {
        courseCount = event.snapshot.children.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: _buildStatCard(
                          'Students',
                          studentCount.toString(),
                          Icons.person,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'Classes',
                          courseCount.toString(),
                          Icons.book,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'Teachers',
                          teacherCount.toString(),
                          Icons.school,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildManageOption('Manage Students', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentList()),
                    );
                  }),
                  const SizedBox(height: 20),
                  _buildManageOption('Manage Courses', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CourseList()),
                    );
                  }),
                  const SizedBox(height: 20),
                  _buildManageOption('Manage Teachers', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TeachersList()),
                    );
                  }),
                  const SizedBox(height: 20),
                  _buildManageOption('Pending Payments', () {
                    if (courseCount > 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentRemindersScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No courses available')),
                      );
                    }
                  }),
                  const SizedBox(height: 20),
                  _buildManageOption('Payment Reports', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PaymentReport()),
                    );
                  }),
                  const SizedBox(height: 20),
                  // Log out button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminWelcomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          169,
                          168,
                          177,
                        ), // Button color
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageOption(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color.fromARGB(255, 7, 2, 87),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16),
          ],
        ),
      ),
    );
  }
}
