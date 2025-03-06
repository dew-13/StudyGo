import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CourseDetails extends StatefulWidget {
  final String courseId;

  const CourseDetails({Key? key, required this.courseId}) : super(key: key);

  @override
  CourseDetailsState createState() => CourseDetailsState();
}

class CourseDetailsState extends State<CourseDetails> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? courseData;

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    DatabaseEvent event = await _database.child('courses/${widget.courseId}').once();
    if (event.snapshot.value != null) {
      setState(() {
        courseData = Map<String, dynamic>.from(event.snapshot.value as Map);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text(
          'Selected Course Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: courseData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Subject: ${courseData!["subject"]}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Grade: ${courseData!["grade"]}",
                      style: const TextStyle(fontSize: 18)),
                  Text("Day: ${courseData!["day"]}",
                      style: const TextStyle(fontSize: 18)),
                  Text("Time: ${courseData!["time"]}",
                      style: const TextStyle(fontSize: 18)),
                  Text("Teacher: ${courseData!["teacher"]}",
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  const Text("Enrolled Students:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: (courseData!["students"] as List?)?.length ?? 0,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(courseData!["students"][index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
