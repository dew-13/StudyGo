import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CourseDetails extends StatefulWidget {
  final String courseId;

  const CourseDetails({super.key, required this.courseId});

  @override
  CourseDetailsState createState() => CourseDetailsState();
}

class CourseDetailsState extends State<CourseDetails> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? courseData;
  Map<String, dynamic> payments = {};
  Map<String, dynamic> enrolledStudents = {};
  Map<String, dynamic> allStudents = {};
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String? selectedStudentId;
  String? selectedStudentName;
  final TextEditingController _amountController = TextEditingController();

  final List<String> months = List.generate(
    12,
    (index) => DateFormat('MMMM').format(DateTime(0, index + 1)),
  );

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
    _fetchPayments();
    _fetchAllStudents();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchCourseDetails() async {
    DatabaseEvent event =
        await _database.child('courses/${widget.courseId}').once();
    if (event.snapshot.exists) {
      setState(() {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        courseData = data;
        if (data["students"] is List) {
          List studentsList = data["students"];
          enrolledStudents = {for (var name in studentsList) name: name};
        }
      });
    }
  }

  Future<void> _fetchPayments() async {
    DatabaseEvent event = await _database.child('payments').once();
    if (event.snapshot.exists) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        payments = data;
      });
    }
  }

  Future<void> _fetchAllStudents() async {
    DatabaseEvent event = await _database.child('students').once();
    if (event.snapshot.exists) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        allStudents = data.map((key, value) => MapEntry(key, value['name']));
      });
    }
  }

  bool _hasAlreadyPaid(String studentId) {
    for (var payment in payments.values) {
      if (payment['studentId'] == studentId &&
          payment['month'] == selectedMonth &&
          payment['courseId'] == widget.courseId) {
        return true;
      }
    }
    return false;
  }

  Future<void> _makePayment() async {
    if (selectedStudentId != null && selectedStudentName != null) {
      if (_amountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter payment amount')),
        );
        return;
      }

      final alreadyPaid = _hasAlreadyPaid(selectedStudentId!);
      if (alreadyPaid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already paid for this month')),
        );
        return;
      }

      String paymentId = _database.child('payments').push().key!;
      String paymentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      double paidAmount = double.tryParse(_amountController.text) ?? 0.0;

      String courseNameFull =
          '${courseData!["subject"]} ${courseData!["grade"]} ${courseData!["day"]}';
      String teacherName = courseData!["teacher"];

      final paymentData = {
        'paymentId': paymentId,
        'paymentDate': paymentDate,
        'studentName': selectedStudentName,
        'studentId': selectedStudentId,
        'paidAmount': paidAmount,
        'courseName': courseNameFull,
        'teacherName': teacherName,
        'month': selectedMonth,
        'courseId': widget.courseId,
      };
      final studentSnapshot =
          await _database.child('students/$selectedStudentId').once();
      if (studentSnapshot.snapshot.exists) {
        final studentInfo =
            Map<String, dynamic>.from(studentSnapshot.snapshot.value as Map);
        final phoneNumber = studentInfo['contact'];

        String smsMessage =
            "Hi $selectedStudentName, your payment of Rs. ${paidAmount.toStringAsFixed(2)} for $courseNameFull has been received for $selectedMonth. Thank you!";

        await sendSms(phoneNumber, smsMessage);
      }

      await _database.child('payments/$paymentId').set(paymentData);

      setState(() {
        payments[paymentId] = paymentData;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> sendSms(String phoneNumber, String message) async {
    var url = Uri.parse('https://api.infobip.com/sms/2/text/advanced');

    var headers = {
      'Authorization':
          'App bb38d88e96213e9387b78515175e8287-f75c5f99-53a3-4a41-8068-a7734759f19f', // Replace with your real API key
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    var body = jsonEncode({
      "messages": [
        {
          "destinations": [
            {"to": phoneNumber}
          ],
          "from": "+44 7491 163443", // Your Infobip sender ID
          "text": message
        }
      ]
    });

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Payment SMS sent successfully!');
    } else {
      print('Failed to send payment SMS: ${response.body}');
    }
  }

  Future<void> _editCourseDetails() async {
    TextEditingController dayController =
        TextEditingController(text: courseData?["day"]);
    TextEditingController timeController =
        TextEditingController(text: courseData?["time"]);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dayController,
              decoration: const InputDecoration(labelText: 'Day'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _database.child('courses/${widget.courseId}').update({
                'day': dayController.text,
                'time': timeController.text,
              });
              setState(() {
                courseData?["day"] = dayController.text;
                courseData?["time"] = timeController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Course updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteCourse() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _database.child('courses/${widget.courseId}').remove();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _removeStudent(String studentId) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student'),
        content: const Text(
            'Are you sure you want to remove this student from the course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      enrolledStudents.remove(studentId);
      await _database
          .child('courses/${widget.courseId}/students')
          .set(enrolledStudents.values.toList());
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student removed successfully')),
      );
    }
  }

  Future<void> _addStudent(String studentId, String studentName) async {
    enrolledStudents[studentId] = studentName;
    await _database
        .child('courses/${widget.courseId}/students')
        .set(enrolledStudents.values.toList());
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student added successfully')),
    );
  }

  String _getPaymentStatus(String studentId) {
    final now = DateTime.now();
    final selectedMonthIndex = months.indexOf(selectedMonth) + 1;
    final selectedMonthDate = DateTime(now.year, selectedMonthIndex);

    for (var payment in payments.values) {
      if (payment['studentId'] == studentId &&
          payment['month'] == selectedMonth &&
          payment['courseId'] == widget.courseId) {
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
      case "Paid":
        return const Icon(Icons.check_circle, color: Colors.green);
      case "Paid - Overdue":
        return const Icon(Icons.check_circle, color: Colors.teal);
      case "Pending":
        return const Icon(Icons.access_time, color: Colors.orange);
      case "Overdue":
        return const Icon(Icons.error, color: Colors.red);
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
        title: const Text('Selected Course Details',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editCourseDetails,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _confirmDeleteCourse,
          ),
        ],
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
                  const Text("Select Month:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: months.length,
                      itemBuilder: (context, index) {
                        String month = months[index];
                        bool isSelected = month == selectedMonth;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMonth = month;
                              selectedStudentId = null;
                              selectedStudentName = null;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                month,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Enrolled Students:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: [
                        ...enrolledStudents.entries.map((entry) {
                          final studentId = entry.key;
                          final studentName = entry.value;
                          final status = _getPaymentStatus(studentId);
                          return ListTile(
                            leading: _getStatusIcon(status),
                            title: Text(studentName),
                            subtitle: Text(status),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeStudent(studentId),
                            ),
                            selected: selectedStudentId == studentId,
                            onTap: () {
                              if (status == "Pending" || status == "Overdue") {
                                setState(() {
                                  selectedStudentId = studentId;
                                  selectedStudentName = studentName;
                                });
                              } else {
                                setState(() {
                                  selectedStudentId = null;
                                  selectedStudentName = null;
                                });
                              }
                            },
                          );
                        }),
                        const SizedBox(height: 20),
                        const Text("Add New Students:",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...allStudents.entries
                            .where((entry) =>
                                !enrolledStudents.containsValue(entry.value))
                            .map((entry) {
                          return ListTile(
                            leading: const Icon(Icons.person_add,
                                color: Colors.green),
                            title: Text(entry.value),
                            onTap: () => _addStudent(entry.key, entry.value),
                          );
                        }),
                      ],
                    ),
                  ),
                  if (selectedStudentId != null)
                    Column(
                      children: [
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Enter Payment Amount',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 7, 2, 87),
                            ),
                            onPressed: _makePayment,
                            child: const Text('Make Payment',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
