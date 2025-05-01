import 'package:flutter/material.dart'; 
import 'package:firebase_database/firebase_database.dart';
import 'package:study_go/admin/admin_panel.dart';

class AddSubject extends StatefulWidget {
    const AddSubject({super.key});
  @override
  AddSubjectState createState() => AddSubjectState();
}

class AddSubjectState extends State<AddSubject> {
  final TextEditingController _timeController = TextEditingController();
  String? selectedSubject;
  String? selectedGrade;
  String? selectedDay;
  String? selectedTeacher;
  List<Map<String, dynamic>> students = [];
  List<String> selectedStudents = [];
  List<Map<String, dynamic>> teachers = [];

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final List<String> subjects = [
    "Science", "Mathematics", "Art", "Music", "Drama", "History", "Sinhala", "English", "Computer Science"
  ];

  final List<String> grades = [
    "Grade 6", "Grade 7", "Grade 8", "Grade 9", "Grade 10", "Grade 11"
  ];

  final List<String> days = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
    _fetchStudents();
  }

  Future<void> _fetchTeachers() async {
    DatabaseEvent event = await _database.child('teachers').once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        teachers =
            data.entries
                .map((e) => {'id': e.key, 'name': e.value['name']})
                .toList();
      });
    }
  }

  Future<void> _fetchStudents() async {
    DatabaseEvent event = await _database.child('students').once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        students =
            data.entries
                .map((e) => {'id': e.key, 'name': e.value['name']})
                .toList();
      });
    }
  }

  Future<void> _saveSubject() async {
    if (selectedSubject == null || selectedGrade == null || selectedDay == null || _timeController.text.isEmpty || selectedTeacher == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    DatabaseReference newSubjectRef = _database.child('courses').push();
    await newSubjectRef.set({
      'subject': selectedSubject,
      'grade': selectedGrade,
      'day': selectedDay,
      'time': _timeController.text,
      'teacher': selectedTeacher,
      'students': selectedStudents,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Subject added successfully")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text('Add New Course', style: TextStyle(color: Colors.white)),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSubject,
              items: subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedSubject = value),
              decoration: InputDecoration(labelText: "Select Subject"),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedGrade,
              items: grades.map((grade) {
                return DropdownMenuItem(
                  value: grade,
                  child: Text(grade),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedGrade = value),
              decoration: InputDecoration(labelText: "Select Grade"),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedDay,
              items: days.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedDay = value),
              decoration: InputDecoration(labelText: "Select Day"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: "Enter Time"),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedTeacher,
              items:
                  teachers.map<DropdownMenuItem<String>>((teacher) {
                    return DropdownMenuItem<String>(
                      value: teacher['name'],
                      child: Text(teacher['name']),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => selectedTeacher = value),
              decoration: InputDecoration(labelText: "Assign Teacher"),
            ),
            SizedBox(height: 20),
             Text(
              "Assign Students",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children:
                    students.map((student) {
                      return CheckboxListTile(
                        title: Text(student['name']),
                        value: selectedStudents.contains(student['name']),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              selectedStudents.add(student['name']);
                            } else {
                              selectedStudents.remove(student['name']);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSubject,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Save Subject"),
            ),
          ],
        ),
      ),
    );
  }
}