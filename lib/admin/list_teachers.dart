import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'profile_teacher.dart'; // Import the TeacherProfile screen
import 'add_teacher.dart'; // Import the AddTeacher screen
import 'admin_panel.dart';

class TeachersList extends StatefulWidget {
  const TeachersList({super.key});

  @override
  TeachersListState createState() => TeachersListState();
}

class TeachersListState extends State<TeachersList> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child("teachers");
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> filteredTeachers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  void _fetchTeachers() async {
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          teachers = data.entries.map((entry) {
            return {
              "id": entry.key,
              "name": entry.value["name"],
              "subject": entry.value["subject"],
              "gender": entry.value["gender"],
              "contact": entry.value["contact"],
            };
          }).toList();
          filteredTeachers = List.from(teachers);
        });
      }
    });
  }

  void _filterTeachers(String query) {
    setState(() {
      filteredTeachers = teachers
          .where((teacher) =>
              teacher["name"].toLowerCase().contains(query.toLowerCase()))
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
          'All Teachers',
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
                onChanged: _filterTeachers,
                decoration: const InputDecoration(
                  hintText: 'Search Teachers...',
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTeachers.length,
              itemBuilder: (context, index) {
                final teacher = filteredTeachers[index];
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
                    "assets/images/teacher.png", // Replace with your image path
                    width: 40, // Adjust the width
                    height: 40, // Adjust the height
                    fit: BoxFit.cover, // Ensures the image fits within the specified dimensions
                  ),
                  title: Text(
                    teacher["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherProfile(teacher: teacher),
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
            MaterialPageRoute(builder: (context) => const AddTeacher()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}