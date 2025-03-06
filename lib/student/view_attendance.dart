import 'package:flutter/material.dart';
import 'package:study_go/student/student_profile.dart';

class ViewAttendance extends StatelessWidget {
  // Sample attendance data (replace with real data from Firebase)
  final List<Map<String, String>> attendanceRecords = [
    {"date": "Feb 1, 2025", "status": "Present"},
    {"date": "Feb 3, 2025", "status": "Absent"},
    {"date": "Feb 5, 2025", "status": "Present"},
    {"date": "Feb 7, 2025", "status": "Present"},
    {"date": "Feb 10, 2025", "status": "Absent"},
    {"date": "Feb 12, 2025", "status": "Present"},
    {"date": "Feb 15, 2025", "status": "Present"},
    {"date": "Feb 18, 2025", "status": "Absent"},
    {"date": "Feb 20, 2025", "status": "Present"},
    {"date": "Feb 22, 2025", "status": "Present"},
    {"date": "Feb 25, 2025", "status": "Absent"},
    {"date": "Feb 28, 2025", "status": "Present"},
  ];

  ViewAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text(
          'View Attendance',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentProfile()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: attendanceRecords.length,
          itemBuilder: (context, index) {
            final record = attendanceRecords[index];

            return Card(
              elevation: 3,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                leading: Icon(Icons.calendar_today, color: Colors.blueAccent),
                title: Text(
                  record["date"]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        record["status"] == "Present"
                            ? Colors.green
                            : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    record["status"]!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          record["status"] == "Present"
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
