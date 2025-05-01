import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class AttendanceMarkingPage extends StatefulWidget {
  final String subject;
  final String grade;
  final String teacher;

  const AttendanceMarkingPage({
    super.key,
    required this.subject,
    required this.grade,
    required this.teacher,
  });

  @override
  State<AttendanceMarkingPage> createState() => _AttendanceMarkingPageState();
}

class _AttendanceMarkingPageState extends State<AttendanceMarkingPage> {
  final _database = FirebaseDatabase.instance;
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;
  DateTime focusedMonth = DateTime.now();
  DateTime? selectedDate;
  int selectedWeekday = DateTime.monday;

  final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final coursesSnapshot = await _database.ref('courses').get();
      if (coursesSnapshot.exists) {
        final data = coursesSnapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          final course = Map<String, dynamic>.from(value);
          if (course['subject'] == widget.subject &&
              course['grade'] == widget.grade &&
              course['teacher'] == widget.teacher) {
            final studentNames = List<String>.from(course['students'] ?? []);
            students = studentNames.map((name) {
              return {'name': name, 'isPresent': false};
            }).toList();
          }
        });
      }
    } catch (e) {
      print('Error loading students: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  void toggleAttendance(int index) {
    setState(() {
      students[index]['isPresent'] = !students[index]['isPresent'];
    });
  }

  void goToPreviousMonth() {
    setState(() {
      focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1);
    });
  }

  void goToNextMonth() {
    setState(() {
      focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1);
    });
  }

  List<Widget> buildCalendarDays() {
    List<Widget> dayWidgets = [];

    DateTime firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    int firstWeekday = firstDayOfMonth.weekday;
    int daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;

    // Add empty slots for the days before the 1st
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime currentDate = DateTime(focusedMonth.year, focusedMonth.month, i);
      int weekday = currentDate.weekday;
      bool isSelectable = weekday == selectedWeekday;
      bool isSelected = selectedDate != null &&
          selectedDate!.year == currentDate.year &&
          selectedDate!.month == currentDate.month &&
          selectedDate!.day == currentDate.day;

      Color bgColor = isSelected
          ? Colors.green
          : isSelectable
              ? Colors.grey.shade300
              : Colors.white;

      dayWidgets.add(
        GestureDetector(
          onTap: isSelectable
              ? () {
                  setState(() {
                    selectedDate = currentDate;
                  });
                }
              : null,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            width: 40,
            height: 40,
            child: Center(
              child: Text(
                currentDate.day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return dayWidgets;
  }

  Future<void> saveAttendance() async {
    if (selectedDate == null) return;

    final attendanceRef = _database.ref('attendance').push();

    await attendanceRef.set({
      'course': '${widget.subject} ${widget.grade} ${weekdays[selectedWeekday - 1]}',
      'teacher': widget.teacher,
      'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
      'students': {
        for (var student in students)
          student['name']: student['isPresent'] ? 'Present' : 'Absent'
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Attendance saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text('Mark Attendance', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 8),
                // Weekday selector (Mon-Sun)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(weekdays.length, (index) {
                      bool isSelected = index + 1 == selectedWeekday;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWeekday = index + 1;
                            selectedDate = null; // Reset selection
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.teal : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.teal),
                          ),
                          child: Text(
                            weekdays[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: goToPreviousMonth,
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(focusedMonth),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: goToNextMonth,
                      ),
                    ],
                  ),
                ),

                // Weekday names row above calendar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekdays.map((day) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Calendar
                Expanded(
                  flex: 2,
                  child: GridView.count(
                    crossAxisCount: 7,
                    children: buildCalendarDays(),
                  ),
                ),

                const Divider(),

                // Students list
                Expanded(
                  flex: 3,
                  child: selectedDate == null
                      ? const Center(child: Text('Select a date to mark attendance.'))
                      : students.isEmpty
                          ? const Center(child: Text('No students found for this course.'))
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: students.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: ListTile(
                                          onTap: () => toggleAttendance(index),
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.blue[900],
                                            child: const Icon(Icons.person, color: Colors.white),
                                          ),
                                          title: Text(
                                            students[index]['name'],
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                          trailing: Text(
                                            students[index]['isPresent']
                                                ? "Present"
                                                : "Absent",
                                            style: TextStyle(
                                              color: students[index]['isPresent']
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: ElevatedButton(
                                    onPressed: saveAttendance,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 0, 56, 209),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text("Save Attendance",
                                        style: TextStyle(fontSize: 16, color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                ),
              ],
            ),
    );
  }
}
