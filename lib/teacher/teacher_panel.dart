import 'package:flutter/material.dart';
import 'package:study_go/teacher/mark_attendance.dart';

import 'package:study_go/teacher/teacher_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF040866),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/images/teacher.png'),
            ),
            SizedBox(height: 8),
            Text(
              "Teachers Name",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
     
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeacherProfile()),
                );
              },
              style: ElevatedButton.styleFrom(
                
              ),
              child: Text(
                "View your Profile",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      "1",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Subject",
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  ],
                ),
                SizedBox(width: 30),
                Column(
                  children: [
                    Text(
                      "6",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Grades",
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  ],
                ),
                SizedBox(width: 30),
                Column(
                  children: [
                    Text(
                      "6",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Total Classes",
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                List<Color> iconColors = [
                  Color(0xFFE9AE24),
                  Color(0xff24e942),
                  Color(0xffe92424),
                  Colors.black,
                  Color(0xffe924c5),
                ];

                return GestureDetector(
                  onTap: () {
                    if (index == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendancePage(),
                        ),
                      );
                    } else {}
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 80, color: iconColors[index]),
                        SizedBox(height: 10),
                        Text(
                          "Science Grade ${index + 6}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
