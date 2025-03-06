import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StudentProfile extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentProfile({super.key, required this.student});

  @override
  StudentProfileState createState() => StudentProfileState();
}

class StudentProfileState extends State<StudentProfile> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child("students");

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.student["name"] ?? "";
    _schoolController.text = widget.student["school"] ?? "";
    _gradeController.text = widget.student["grade"] ?? "";
    _birthYearController.text = widget.student["birthyear"] ?? "";
    _contactController.text = widget.student["contact"] ?? "";
  }

  // Function to save changes to Firebase
  void _saveChanges() {
    Map<String, String> updatedData = {
      "name": _nameController.text,
      "school": _schoolController.text,
      "grade": _gradeController.text,
      "birthyear": _birthYearController.text,
      "contact": _contactController.text,
    };

    _databaseRef.child(widget.student["id"]).update(updatedData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student details updated successfully!")),
      );
      Navigator.pop(context); // Go back to the previous screen after saving
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating student: $error")),
      );
    });
  }

  // Function to show confirmation dialog before deleting a student
  void _confirmDeleteStudent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this student? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteStudent(); // Proceed with deletion
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Function to delete the student from Firebase
  void _deleteStudent() {
    _databaseRef.child(widget.student["id"]).remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student deleted successfully!")),
      );
      Navigator.pop(context); // Go back to the previous screen after deletion
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting student: $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text(
          'Student Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo at the top
              Image.asset(
                "assets/images/student_icon.jpeg", // Update with your logo path
                height: 100,
              ),
              const SizedBox(height: 20),

              // Editable fields
              _buildProfileItem("Name", _nameController),
              const SizedBox(height: 16),
              _buildProfileItem("School", _schoolController),
              const SizedBox(height: 16),
              _buildProfileItem("Grade", _gradeController),
              const SizedBox(height: 16),
              _buildProfileItem("Birth Year", _birthYearController),
              const SizedBox(height: 16),
              _buildProfileItem("Contact Number", _contactController),
              const SizedBox(height: 30),

              // Save Changes Button
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 16),

              // Delete Student Button
              ElevatedButton(
                onPressed: _confirmDeleteStudent, // Show confirmation before deleting
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Delete Student", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }
}
