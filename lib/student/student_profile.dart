import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'attendance_history.dart';

class StudentPanel extends StatefulWidget {
  final String contact;
  final String password;

  const StudentPanel({
    super.key,
    required this.contact,
    required this.password,
  });

  @override
  State<StudentPanel> createState() => _StudentPanelState();
}

class _StudentPanelState extends State<StudentPanel> {
  final _studentsRef = FirebaseDatabase.instance.ref().child('students');
  final _coursesRef = FirebaseDatabase.instance.ref().child('courses');

  Map<String, dynamic>? studentData;
  List<Map<String, dynamic>> enrolledCourses = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _fetchStudentDetails() async {
    try {
      final snapshot = await _studentsRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final hashedPassword = _hashPassword(widget.password);

        bool found = false;
        String studentName = "";

        data.forEach((key, value) {
          if (value['contact'] == widget.contact &&
              value['password'] == hashedPassword) {
            studentData = Map<String, dynamic>.from(value);
            studentName = studentData?['name'] ?? "";
            found = true;
          }
        });

        if (found && studentName.isNotEmpty) {
          _fetchEnrolledCourses(studentName);
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
      print("Error fetching student details: $e");
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  void _fetchEnrolledCourses(String studentName) async {
    try {
      final coursesSnapshot = await _coursesRef.get();

      if (coursesSnapshot.exists) {
        final coursesData = coursesSnapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> courseList = [];

        coursesData.forEach((courseId, courseDetails) {
          final studentsList = List.from(courseDetails['students'] ?? []);
          if (studentsList.contains(studentName)) {
            courseList.add({
              'subject': courseDetails['subject'] ?? '',
              'grade': courseDetails['grade'] ?? '',
              'teacher': courseDetails['teacher'] ?? '',
              'day': courseDetails['day'] ?? '',
              'time': courseDetails['time'] ?? '',
            });
          }
        });

        setState(() {
          enrolledCourses = courseList;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching enrolled courses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.blue[900];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text('Student Panel', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(child: Text('Error fetching data. Please try again.'))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.asset(
                            "assets/images/students.png",
                            height: 150,
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// STUDENT INFO CARD
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Student Information",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 8, 127, 143),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildDetailRow("Name", studentData?['name']),
                                const Divider(),
                                _buildDetailRow("School", studentData?['school']),
                                const Divider(),
                                _buildDetailRow("Grade", studentData?['grade']),
                                const Divider(),
                                _buildDetailRow("Birth Year", studentData?['birthyear']),
                                const Divider(),
                                _buildDetailRow("Contact", studentData?['contact']),
                              ],
                            ),
                          ),
                        ),

                        /// ENROLLED COURSES
                        const Text(
                          "    Enrolled Courses",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 8, 127, 143),
                                  ),
                        ),
                        const SizedBox(height: 10),

                        ...enrolledCourses.map((course) {
                          final courseDisplayName = "${course['subject']} (${course['grade']})";
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: iconColor,
                                        child: const Icon(Icons.book, size: 28, color: Colors.white),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          courseDisplayName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: iconColor,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AttendanceHistoryPage(
                                                studentName: studentData?['name'] ?? '',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "View Attendance",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text("Day: ${course['day']}"),
                                  Text("Time: ${course['time']}"),
                                  Text("Teacher: ${course['teacher']}"),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value ?? "Not Available",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
