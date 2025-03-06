import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  AttendancePageState createState() => AttendancePageState();
}

class AttendancePageState extends State<AttendancePage> {
  List<String> dateKeys = ["6 Mon", "7 Tue", "8 Wed", "9 Thur"];
  int selectedDateIndex = 0;

  Map<String, List<Map<String, dynamic>>> attendanceRecords = {};

  @override
  void initState() {
    super.initState();
    initializeAttendance();
  }

  void initializeAttendance() {
    for (String date in dateKeys) {
      attendanceRecords[date] = [
        {"name": "Amal Edirimuni", "isPresent": false},
        {"name": "Sunil Gunasoma", "isPresent": false},
        {"name": "Nimal Kurera", "isPresent": false},
        {"name": "Kamal Perera", "isPresent": false},
        {"name": "Rohan Silva", "isPresent": false},
        {"name": "Saman Kumara", "isPresent": false},
      ];
    }
  }

  void toggleAttendance(int index) {
    setState(() {
      String currentDate = dateKeys[selectedDateIndex];
      attendanceRecords[currentDate]![index]["isPresent"] =
          !attendanceRecords[currentDate]![index]["isPresent"];
    });
  }

  void toggleDateSelection(int index) {
    setState(() {
      selectedDateIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = dateKeys[selectedDateIndex];
    List<Map<String, dynamic>> students = attendanceRecords[currentDate]!;

    return Scaffold(
      backgroundColor: Color(0xFF040866),
      appBar: AppBar(
        backgroundColor: Color(0xFF040866),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Science Grade 6",
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Date selection buttons
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            color: Color(0xFF040866),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(dateKeys.length, (index) {
                return dateButton(dateKeys[index], index);
              }),
            ),
          ),
          SizedBox(height: 30),

          // Attendance List
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue[900],
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          students[index]["name"],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => toggleAttendance(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              students[index]["isPresent"]
                                  ? Colors.green
                                  : Colors.red,
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          students[index]["isPresent"] ? "Present" : "Absent",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget dateButton(String date, int index) {
    bool isSelected = index == selectedDateIndex;
    List<String> parts = date.split(" ");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () => toggleDateSelection(index),
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                parts[0],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                parts[1],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
