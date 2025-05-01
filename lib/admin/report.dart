import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class PaymentReport extends StatefulWidget {
  const PaymentReport({super.key});

  @override
  State<PaymentReport> createState() => _PaymentReportState();
}

class _PaymentReportState extends State<PaymentReport> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic> payments = {};
  Map<String, dynamic> courses = {}; 
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());

  final List<String> months = List.generate(
    12,
    (index) => DateFormat('MMMM').format(DateTime(0, index + 1)),
  );

  Map<String, double> courseIncome = {}; 

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    DatabaseEvent paymentsEvent = await _database.child('payments').once();
    DatabaseEvent coursesEvent = await _database.child('courses').once();

    if (coursesEvent.snapshot.exists) {
      final courseData = Map<String, dynamic>.from(coursesEvent.snapshot.value as Map);
      setState(() {
        courses = courseData;
      });
    }

    if (paymentsEvent.snapshot.exists) {
      final paymentData = Map<String, dynamic>.from(paymentsEvent.snapshot.value as Map);
      setState(() {
        payments = paymentData;
      });
    }

    _calculateIncome();
  }

  void _calculateIncome() {
    courseIncome.clear();

    // Initialize all courses with 0
    courses.forEach((courseId, courseInfo) {
      String courseName = '${courseInfo["subject"]} ${courseInfo["grade"]} ${courseInfo["day"]}';
      courseIncome[courseName] = 0;
    });

    for (var payment in payments.values) {
      String paymentMonth = payment['month'] ?? '';
      String courseName = payment['courseName'] ?? '';
      double paidAmount = (payment['paidAmount'] ?? 0).toDouble();

      if (paymentMonth == selectedMonth) {
        courseIncome[courseName] = (courseIncome[courseName] ?? 0) + paidAmount;
      }
    }
  }

  List<PieChartSectionData> _buildPieChartData() {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.yellow,
      Colors.brown,
      Colors.pink,
      Colors.indigo,
    ];
    int colorIndex = 0;

    return courseIncome.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
          final color = colors[colorIndex % colors.length];
          final section = PieChartSectionData(
            color: color,
            value: entry.value,
            title: '${entry.key.split(' ')[0]}: ${entry.value.toInt()}',
            radius: 90,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titlePositionPercentageOffset: 0.7, // move label inside but clear
          );
          colorIndex++;
          return section;
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final courseNames = courseIncome.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text('Payments Report', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: courseIncome.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Month:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                              _calculateIncome();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                month,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
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
                  const Text('Income Report:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: courseIncome.length,
                      itemBuilder: (context, index) {
                        String courseName = courseNames[index];
                        double totalIncome = courseIncome[courseName] ?? 0;

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              courseName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Total Income: ${totalIncome.toInt()}'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Income Chart:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartData(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
