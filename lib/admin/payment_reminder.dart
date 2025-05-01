import "package:flutter/material.dart";
import "package:firebase_database/firebase_database.dart";
import "package:intl/intl.dart";
import "notification_service.dart"; // Import our notification service

class PaymentRemindersScreen extends StatefulWidget {
  const PaymentRemindersScreen({super.key});

  @override
  State<PaymentRemindersScreen> createState() => _PaymentRemindersScreenState();
}

class _PaymentRemindersScreenState extends State<PaymentRemindersScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic> courses = {};
  Map<String, dynamic> payments = {};
  final List<Map<String, dynamic>> pendingReminders = [];
  final String currentMonth = DateFormat("MMMM").format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    DatabaseEvent coursesEvent = await _database.child("courses").once();
    DatabaseEvent paymentsEvent = await _database.child("payments").once();

    if (coursesEvent.snapshot.exists) {
      courses = Map<String, dynamic>.from(coursesEvent.snapshot.value as Map);
    }
    if (paymentsEvent.snapshot.exists) {
      payments = Map<String, dynamic>.from(paymentsEvent.snapshot.value as Map);
    }

    _processReminders();
  }

  void _processReminders() {
    List<Map<String, dynamic>> tempList = [];

    courses.forEach((courseId, courseData) {
      final course = Map<String, dynamic>.from(courseData);

      String courseNameFull = "${course["subject"]} ${course["grade"]} ${course["day"]}";
      String teacherName = course["teacher"];

      if (course["students"] is List) {
        List studentsList = course["students"];

        for (var studentName in studentsList) {
          String studentId = studentName; // ID is same as name for now

          final status = _getPaymentStatus(studentId, courseId);

          if (status == "Pending" || status == "Overdue") {
            tempList.add({
              "studentName": studentName,
              "studentId": studentId,
              "courseId": courseId,
              "courseName": courseNameFull,
              "teacherName": teacherName,
              "status": status,
            });
          }
        }
      }
    });

    // Sort alphabetically by student name
    tempList.sort((a, b) => a["studentName"].toLowerCase().compareTo(b["studentName"].toLowerCase()));

    setState(() {
      pendingReminders.clear();
      pendingReminders.addAll(tempList);
    });
  }

  String _getPaymentStatus(String studentId, String courseId) {
    final now = DateTime.now();
    final selectedMonthIndex = DateFormat.MMMM().parse(currentMonth).month;
    final selectedMonthDate = DateTime(now.year, selectedMonthIndex);

    for (var payment in payments.values) {
      if (payment["studentId"] == studentId &&
          payment["month"] == currentMonth &&
          payment["courseId"] == courseId) {
        if (now.isAfter(selectedMonthDate.add(const Duration(days: 30)))) {
          return "Paid - Overdue";
        }
        return "Paid";
      }
    }

    if (now.isBefore(selectedMonthDate.add(const Duration(days: 30)))) {
      return "Pending";
    } else {
      return "Overdue";
    }
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case "Pending":
        return const Icon(Icons.access_time, color: Colors.orange);
      case "Overdue":
        return const Icon(Icons.error_outline, color: Colors.red);
      default:
        return const Icon(Icons.help_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text("This Month Pending Payments", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: pendingReminders.isEmpty
          ? const Center(child: Text("No pending or overdue payments."))
          : ListView.builder(
              itemCount: pendingReminders.length,
              itemBuilder: (context, index) {
                final reminder = pendingReminders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: _getStatusIcon(reminder["status"]),
                    title: Text(reminder["studentName"]),
                    subtitle: Text("${reminder["courseName"]} | Teacher: ${reminder["teacherName"]}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        try {
                          await NotificationService.sendReminder(
                            reminder["studentId"],
                            reminder["studentName"],
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Reminder sent!")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to send reminder")),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
