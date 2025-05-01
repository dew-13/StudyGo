import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import 'package:study_go/teacher/attendance_marking.dart';
import 'dart:convert';

class TeacherPanel extends StatefulWidget {
  final String contact;
  final String password;

  const TeacherPanel({
    super.key,
    required this.contact,
    required this.password,
  });

  @override
  State<TeacherPanel> createState() => _TeacherPanelState();
}

class _TeacherPanelState extends State<TeacherPanel> {
  final _database = FirebaseDatabase.instance;
  Map<String, dynamic>? teacherData;
  bool isLoading = true;
  bool isError = false;
  List<Map<String, dynamic>> teacherCourses = [];

  @override
  void initState() {
    super.initState();
    _fetchTeacherDetails();
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _fetchTeacherDetails() async {
    try {
      final snapshot = await _database.ref('teachers').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final hashedPassword = _hashPassword(widget.password);

        bool found = false;

        data.forEach((key, value) {
          if (value['contact'] == widget.contact &&
              value['password'] == hashedPassword) {
            teacherData = Map<String, dynamic>.from(value);
            found = true;
          }
        });

        if (found) {
          await _fetchAssignedCourses();
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAssignedCourses() async {
    final coursesSnapshot = await _database.ref('courses').get();
    if (coursesSnapshot.exists) {
      final data = coursesSnapshot.value as Map<dynamic, dynamic>;
      final name = teacherData?['name'];
      final List<Map<String, dynamic>> assigned = [];

      data.forEach((key, value) {
        final course = Map<String, dynamic>.from(value);
        if (course['teacher'] == name) {
          assigned.add({
            'subject': course['subject'],
            'grade': course['grade'],
            'day': course['day'],
          });
        }
      });

      teacherCourses = assigned;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text('Teacher Panel', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(child: Text('Error fetching data. Please try again.'))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/images/teachers.jpg",
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow("Name", teacherData?['name']),
                      const SizedBox(height: 10),
                      _buildDetailRow("Gender", teacherData?['gender']),
                      const SizedBox(height: 10),
                      _buildDetailRow("Subject", teacherData?['subject']),
                      const SizedBox(height: 10),
                      _buildDetailRow("Contact", teacherData?['contact']),
                      const SizedBox(height: 30),
                      const Text(
                        "Courses Assigned",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...teacherCourses.map((course) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.book, size: 40, color: Colors.deepPurple),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(course['subject'],
                                          style: const TextStyle(
                                              fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text("Grade: ${course['grade']}"),
                                      Text("Day: ${course['day']}"),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AttendanceMarkingPage(
                                          subject: course['subject'],
                                          grade: course['grade'],
                                          teacher: teacherData?['name'] ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 0, 56, 209),
                                  ),
                                  child: const Text("Mark Attendance",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 0, 56, 209),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Logout",
                              style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Expanded(
          child: Text(
            value ?? "Not Available",
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
