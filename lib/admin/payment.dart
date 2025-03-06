import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  PaymentsPageState createState() => PaymentsPageState();
}

class PaymentsPageState extends State<PaymentsPage> {
  String? selectedMonth;
  String? selectedCourseId;
  String? selectedCourseName;
  String? selectedStudentId;
  String? selectedStudentName;
  String? paymentAmount;

  List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  List<Map<String, String>> courses = [];
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> payments = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _fetchPayments();
  }

  Future<void> _fetchCourses() async {
    DatabaseReference database = FirebaseDatabase.instance.ref("courses");
    database.onValue.listen((event) {
      setState(() {
        courses = event.snapshot.children.map((e) {
          String grade = e.child("grade").value.toString();
          String subject = e.child("subject").value.toString();
          String day = e.child("day").value.toString();
          return {
            "id": e.key.toString(),
            "name": "$grade $subject $day"
          };
        }).toList();
      });
    });
  }

  Future<void> _fetchStudents() async {
    if (selectedCourseId == null) return;
    DatabaseReference database = FirebaseDatabase.instance.ref("courses/$selectedCourseId/students");
    database.onValue.listen((event) {
      setState(() {
        students = event.snapshot.children.map((e) {
          return {
            "id": e.key,
            "name": e.child("name").value.toString(),
            "paid": e.child("paid").value == true || e.child("paid").value == "true",
          };
        }).toList();
      });
    });
  }

  Future<void> _fetchPayments() async {
    DatabaseReference database = FirebaseDatabase.instance.ref("payments");
    database.onValue.listen((event) {
      setState(() {
        payments = event.snapshot.children.map((e) {
          return {
            "studentId": e.child("studentId").value.toString(),
            "courseId": e.child("courseId").value.toString(),
            "feeMonth": e.child("feeMonth").value.toString(),
          };
        }).toList();
      });
    });
  }

  bool _isStudentPaid(String studentId, String courseId, String month) {
    return payments.any((payment) =>
        payment["studentId"] == studentId &&
        payment["courseId"] == courseId &&
        payment["feeMonth"] == month);
  }

  void _confirmPayment() {
    if (selectedMonth == null || selectedCourseId == null || selectedCourseName == null || selectedStudentId == null || selectedStudentName == null || paymentAmount == null || paymentAmount!.isEmpty) return;
    DatabaseReference paymentRef = FirebaseDatabase.instance.ref("payments").push();
    DateTime now = DateTime.now();
    String paymentDate = "${now.year}-${now.month}-${now.day}";

    paymentRef.set({
      "studentId": selectedStudentId,
      "studentName": selectedStudentName,
      "courseId": selectedCourseId,
      "courseName": selectedCourseName,
      "feeMonth": selectedMonth,
      "paymentDate": paymentDate,
      "amount": paymentAmount,
      "status": "Paid",
    });

    DatabaseReference studentRef = FirebaseDatabase.instance.ref("courses/$selectedCourseId/students/$selectedStudentId");
    studentRef.update({"paid": true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Payments"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedMonth,
              hint: Text("Select Month"),
              items: months.map((month) {
                return DropdownMenuItem<String>(value: month, child: Text(month));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMonth = value;
                });
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCourseId,
              hint: Text("Select Course"),
              items: courses.map((course) {
                return DropdownMenuItem<String>(value: course["id"]!, child: Text(course["name"]!));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCourseId = value;
                  selectedCourseName = courses.firstWhere((course) => course["id"] == value)["name"];
                  selectedStudentId = null;
                  selectedStudentName = null;
                  _fetchStudents();
                });
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedStudentId,
              hint: Text("Select Student"),
              items: students.map((student) {
                bool isPaid = _isStudentPaid(student["id"], selectedCourseId ?? "", selectedMonth ?? "");
                return DropdownMenuItem<String>(
                  value: student["id"],
                  child: Text(isPaid ? "${student["name"]} (Paid)" : student["name"]),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStudentId = value;
                  selectedStudentName = students.firstWhere((student) => student["id"] == value)["name"];
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter Payment Amount"),
              onChanged: (value) {
                setState(() {
                  paymentAmount = value;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _confirmPayment,
              child: Text("Confirm Payment"),
            ),
          ],
        ),
      ),
    );
  }
}