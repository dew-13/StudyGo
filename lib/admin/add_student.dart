import 'package:flutter/material.dart'; 
import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import 'package:study_go/admin/list_students.dart';
import 'dart:convert'; // for the utf8.encode method

class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final _formKey = GlobalKey<FormState>();
  final _database = FirebaseDatabase.instance.ref().child("students");

  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _passwordController = TextEditingController();
  final _contactController = TextEditingController();
  String _selectedGrade = "Grade 6";

  // Function to hash the password using SHA-256
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _saveStudent() {
    if (_formKey.currentState!.validate()) {
      final hashedPassword = _hashPassword(_passwordController.text.trim());

      final studentData = {
        "name": _nameController.text.trim(),
        "school": _schoolController.text.trim(),
        "grade": _selectedGrade,
        "birthyear": _birthYearController.text.trim(),
        "password": hashedPassword,
        "contact": _contactController.text.trim(),
      };

      _database.push().set(studentData).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Student added successfully!")),
          );
          _formKey.currentState!.reset();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentList()),
          );
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $error")),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text(
          'Add New Student Registration',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentList()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset("assets/images/students.png", height: 180),
                const SizedBox(height: 16),
                _buildTextField(_nameController, "Student Name"),
                _buildTextField(_schoolController, "School Name"),
                _buildGradeDropdown(),
                _buildTextField(_birthYearController, "Birth Year"),
                _buildTextField(_passwordController, "Password", isPassword: true),
                _buildTextField(_contactController, "Contact Number"),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 56, 209),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Add Student",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Color.fromARGB(255, 12, 0, 0)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color.fromARGB(179, 0, 60, 255)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color.fromARGB(179, 1, 27, 85)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 27, 2, 255), width: 2),
          ),
        ),
        validator: (value) => value!.isEmpty ? "$label is required" : null,
      ),
    );
  }

  Widget _buildGradeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedGrade,
        decoration: InputDecoration(
          labelText: "Grade",
          labelStyle: const TextStyle(color: Color.fromARGB(179, 0, 60, 255)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color.fromARGB(179, 1, 27, 85)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 27, 2, 255), width: 2),
          ),
        ),
        items: [
          for (int i = 6; i <= 11; i++)
            DropdownMenuItem(value: "Grade $i", child: Text("Grade $i")),
        ],
        onChanged: (value) {
          setState(() {
            _selectedGrade = value!;
          });
        },
      ),
    );
  }
}