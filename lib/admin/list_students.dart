import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:study_go/admin/admin_panel.dart';
import 'profile_student.dart'; // Import the StudentProfile screen
import 'package:study_go/admin/add_student.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  StudentListState createState() => StudentListState();
}

class StudentListState extends State<StudentList> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child("students");
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  void _fetchStudents() async {
  _databaseRef.onValue.listen((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        students = data.entries.map((entry) {
          final studentData = entry.value as Map<dynamic, dynamic>;

          return {
            "id": entry.key,
            "name": studentData["name"]?.toString() ?? "Unknown",
            "school": studentData["school"]?.toString() ?? "N/A",
            "grade": studentData["grade"]?.toString() ?? "N/A",
            "birthyear": studentData["birthyear"]?.toString() ?? "N/A",
            "contact": studentData["contact"]?.toString() ?? "N/A",
          };
        }).toList();

        filteredStudents = List.from(students);
      });
    }
  });
}


  void _filterStudents(String query) {
    setState(() {
      filteredStudents = students
          .where((student) =>
              student["name"].toLowerCase().contains(query.toLowerCase()))
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
          'All Students',
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
                onChanged: _filterStudents,
                decoration: const InputDecoration(
                  hintText: 'Search Students...',
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
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
                    student["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentProfile(student: student),
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
            MaterialPageRoute(builder: (context) => const AddStudent()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}