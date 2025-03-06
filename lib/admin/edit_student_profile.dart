import 'package:flutter/material.dart';
import 'package:study_go/admin/list_students.dart';
//import 'package:study_go/auth/login.dart';
import 'package:study_go/logins/login_screen.dart'; // Import the login page

class EditStudentProfile extends StatefulWidget {
  final String role; // Add role parameter (Admin/Student)

  const EditStudentProfile({super.key, required this.role});

  @override
  EditStudentProfileState createState() => EditStudentProfileState();
}

class EditStudentProfileState extends State<EditStudentProfile> {
  bool showPassword = false;

  // Function to show SnackBar message
  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.role == "Admin"; // Check if the user is an Admin

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            if (isAdmin) {
              // Redirect Admins to Student List Page
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const StudentList()),
              );
            } else {
              // Redirect Students to Login Page
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LogInScreen()),
              );
            }
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            const Text(
              "Student Profile",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      border: Border.all(width: 4, color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/student_icon.jpeg'),
                      ),
                    ),
                  ),
                  if (isAdmin) // Only Admins can edit the profile picture
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 4, color: Colors.white),
                          color: Colors.blue,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            buildTextField("Full Name", "Student Name", false, isAdmin),
            buildTextField("School Name", "ABC College", false, isAdmin),
            buildTextField("Password", "********", true, isAdmin),
            buildTextField("Grade", "Grade 7", false, isAdmin),
            const SizedBox(height: 35),
            if (isAdmin) // Show SAVE button only for Admins
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      showMessage(context, "Save Changes Successfully");
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StudentList(),
                        ),
                      );
                    },
                    child: const Text(
                      "SAVE",
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 2.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String labelText,
    String placeholder,
    bool isPasswordTextField,
    bool isAdmin,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child:
          isAdmin
              ? TextField(
                obscureText: isPasswordTextField ? showPassword : false,
                decoration: InputDecoration(
                  suffixIcon:
                      isPasswordTextField
                          ? IconButton(
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            icon: const Icon(
                              Icons.remove_red_eye,
                              color: Colors.grey,
                            ),
                          )
                          : null,
                  contentPadding: const EdgeInsets.only(bottom: 3),
                  labelText: labelText,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: placeholder,
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              )
              : Text(
                placeholder, // Display text instead of TextField for students
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
    );
  }
}
