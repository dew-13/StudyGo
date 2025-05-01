import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StudentProfile extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentProfile({super.key, required this.student});

  @override
  StudentProfileState createState() => StudentProfileState();
}

class StudentProfileState extends State<StudentProfile> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child("students");

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.student["name"] ?? "";
    _schoolController.text = widget.student["school"] ?? "";
    _gradeController.text = widget.student["grade"] ?? "";
    _birthYearController.text = widget.student["birthyear"] ?? "";
  }

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  void _saveChanges() async {
    Map<String, String> updatedData = {
      "name": _nameController.text,
      "school": _schoolController.text,
      "grade": _gradeController.text,
      "birthyear": _birthYearController.text,
    };

    if (_newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New passwords do not match.")),
        );
        return;
      }

      updatedData["password"] = hashPassword(_newPasswordController.text);
    }

    var databaseRef;
    databaseRef.child(widget.student["id"]).update(updatedData).then(() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student details updated successfully!")),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating student: $error")),
      );
    });
  }

  void _deleteStudent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this student?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      var databaseRef;
      databaseRef.child(widget.student["id"]).remove().then(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student deleted successfully.")),
        );
        Navigator.pop(context); // go back after deletion
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting student: $error")),
        );
      });
    }
  }

  Widget _buildProfileItem(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      obscuringCharacter: '*',
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text('Student Profile',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/student_icon.jpeg", height: 100),
            const SizedBox(height: 20),
            _buildProfileItem("Name", _nameController),
            const SizedBox(height: 16),
            _buildProfileItem("School", _schoolController),
            const SizedBox(height: 16),
            _buildProfileItem("Grade", _gradeController),
            const SizedBox(height: 16),
            _buildProfileItem("Birth Year", _birthYearController),
            const SizedBox(height: 24),
            const Text("Change Password (optional)",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildProfileItem("New Password", _newPasswordController,
                obscureText: true),
            const SizedBox(height: 10),
            _buildProfileItem(
                "Confirm New Password", _confirmPasswordController,
                obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Save Changes",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _deleteStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text("Delete Student",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}