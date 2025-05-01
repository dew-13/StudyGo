import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final String studentName;

  const AttendanceHistoryPage({super.key, required this.studentName});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  final _database = FirebaseDatabase.instance;
  List<Map<String, dynamic>> allRecords = [];
  List<Map<String, dynamic>> filteredRecords = [];
  List<String> subjects = [];
  String selectedSubject = 'All';
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadAttendanceRecords();
  }

  Future<void> loadAttendanceRecords() async {
    final snapshot = await _database.ref('attendance').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> tempList = [];

      for (var entry in data.entries) {
        final record = Map<String, dynamic>.from(entry.value);
        final students = Map<String, dynamic>.from(record['students'] ?? {});

        if (students.containsKey(widget.studentName)) {
          final dateStr = record['date'] ?? '';
          DateTime? parsedDate;
          try {
            parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
          } catch (_) {}

          tempList.add({
            'course': record['course'] ?? '',
            'subject': (record['course'] ?? '').split(' ').first,
            'teacher': record['teacher'] ?? '',
            'date': dateStr,
            'parsedDate': parsedDate,
            'status': students[widget.studentName] ?? 'Absent',
          });
        }
      }

      tempList.sort((a, b) => b['parsedDate'].compareTo(a['parsedDate']));
      final uniqueSubjects = tempList.map((e) => e['subject'] as String).toSet().toList();

      setState(() {
        allRecords = tempList;
        subjects = ['All', ...uniqueSubjects];
        applyFilters();
      });
    }
  }

  void applyFilters() {
    setState(() {
      filteredRecords = allRecords.where((record) {
        final inSubject = selectedSubject == 'All' || record['subject'] == selectedSubject;
        final inMonth = record['parsedDate'].month == selectedMonth.month &&
            record['parsedDate'].year == selectedMonth.year;
        return inSubject && inMonth;
      }).toList();
    });
  }

  Future<void> pickMonth() async {
    final now = DateTime.now();
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        int selectedYear = selectedMonth.year;
        int selectedMonthIndex = selectedMonth.month;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Month'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(10, (index) {
                      int year = now.year - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedYear = value;
                        });
                      }
                    },
                  ),
                  DropdownButton<int>(
                    value: selectedMonthIndex,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(DateFormat.MMMM().format(DateTime(0, index + 1))),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedMonthIndex = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, DateTime(selectedYear, selectedMonthIndex));
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedMonth = picked;
        applyFilters();
      });
    }
  }

  Map<String, int> getAttendanceSummary() {
    int presentCount = 0;
    int absentCount = 0;

    for (var record in filteredRecords) {
      if (record['status'] == 'Present') {
        presentCount++;
      } else {
        absentCount++;
      }
    }

    return {'Present': presentCount, 'Absent': absentCount};
  }

  @override
  Widget build(BuildContext context) {
    final summary = getAttendanceSummary();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Filters Row (Course and Month Filter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedSubject,
                    isExpanded: true,
                    items: subjects.map((subj) {
                      return DropdownMenuItem(
                        value: subj,
                        child: Text(subj),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedSubject = value;
                          applyFilters();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(DateFormat('MMMM yyyy').format(selectedMonth)),
                  onPressed: pickMonth,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Attendance Summary (Present/Absent Count)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Chip(
                  label: Text(
                    'Present: ${summary['Present']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
                Chip(
                  label: Text(
                    'Absent: ${summary['Absent']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ),

          const Divider(),

          // Attendance List (Filtered Records)
          Expanded(
            child: filteredRecords.isEmpty
                ? const Center(child: Text('No attendance records found.'))
                : ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            record['status'] == 'Present'
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: record['status'] == 'Present'
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(record['course']),
                          subtitle: Text(
                            'Date: ${record['date']}\nTeacher: ${record['teacher']}',
                          ),
                          trailing: Text(
                            record['status'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: record['status'] == 'Present'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
