import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:study_go/admin/add_subject.dart';
import 'package:study_go/admin/profile_subject.dart';
import 'admin_panel.dart';

class CourseList extends StatefulWidget {
  const CourseList({super.key});
  @override
  CourseListState createState() => CourseListState();
}

class CourseListState extends State<CourseList> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child("courses");
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> filteredCourses = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  void _fetchCourses() {
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          courses = data.entries.map((entry) {
            return {
              "id": entry.key,
              "subject": entry.value["subject"],
              "teacher": entry.value["teacher"],
              "time": entry.value["time"],
              "grade": entry.value["grade"],
              "day": entry.value["day"],
            };
          }).toList();
          filteredCourses = List.from(courses);
        });
      }
    });
  }

  void _filterCourses(String query) {
    setState(() {
      filteredCourses = courses
          .where((course) =>
              course["subject"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text(
          'All Courses',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPanel()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterCourses,
                decoration: const InputDecoration(
                  hintText: 'Search Courses...',
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/students.jpg", // Replace with your image path
                      width: 40, // Adjust the width
                      height: 40, // Adjust the height
                      fit: BoxFit.cover, // Ensures the image fits within the specified dimensions
                    ),
                    title: Text(
                      course["subject"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${course["grade"]}\nTeacher: ${course["teacher"]}\nDay: ${course["day"]}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      // Navigate to CourseDetails page with the course ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetails(courseId: course["id"]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSubject()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}