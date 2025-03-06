// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:study_go/student/view_attendance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_go/student/edit_student.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text(
          'Student Panel',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          // COLUMN THAT WILL CONTAIN THE PROFILE
          Column(
            children: const [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/student_icon.jpeg'),
              ),
              SizedBox(height: 10),
              Text(
                "Student Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text("School Name"),
            ],
          ),
          const SizedBox(height: 25),

          const SizedBox(height: 35),
          ...List.generate(customListTiles.length, (index) {
            final tile = customListTiles[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Card(
                elevation: 3,
                shadowColor: Colors.black12,
                child: ListTile(
                  leading: Icon(tile.icon),
                  title: Text(tile.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (tile.title == "Profile Details") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditStudentProfile(),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          }),

          const SizedBox(height: 10),
          SizedBox(
            height: 400, // Adjust height as needed
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical, // Change to vertical direction
              itemBuilder: (context, index) {
                final card = profileCompletionCards[index];
                return Card(
                  shadowColor: Colors.black12,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Icon(card.icon, size: 30),
                        const SizedBox(height: 10),
                        Text(card.title, textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (BuildContext context) => ViewAttendance(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(card.buttonText),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder:
                  (context, index) =>
                      const SizedBox(height: 10), // Add spacing between cards
              itemCount: profileCompletionCards.length,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileCompletionCard {
  final String title;
  final String buttonText;
  final IconData icon;
  ProfileCompletionCard({
    required this.title,
    required this.buttonText,
    required this.icon,
  });
}

List<ProfileCompletionCard> profileCompletionCards = [
  ProfileCompletionCard(
    title: "Course 1",
    icon: CupertinoIcons.square_list,
    buttonText: "View Attendance",
  ),
  ProfileCompletionCard(
    title: "Course 2",
    icon: CupertinoIcons.square_list,
    buttonText: "View Attendance",
  ),
];

class CustomListTile {
  final IconData icon;
  final String title;
  CustomListTile({required this.icon, required this.title});
}

List<CustomListTile> customListTiles = [
  CustomListTile(
    title: "Profile Details",
    icon: CupertinoIcons.person_crop_circle,
  ),
  CustomListTile(title: "Payment History", icon: CupertinoIcons.gear),
  CustomListTile(title: "Logout", icon: CupertinoIcons.power),
];
