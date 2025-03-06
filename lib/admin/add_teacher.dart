import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode
import 'list_teachers.dart'; // Assuming you have a TeachersList page

class AddTeacher extends StatefulWidget {
  const AddTeacher({super.key});

  @override
  State<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> {
  final _formKey = GlobalKey<FormState>();
  final _database = FirebaseDatabase.instance.ref().child("teachers");

  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _contactController = TextEditingController();

  String? _selectedGender;
  String? _selectedSubject;

  final List<String> _subjects = [
    "Mathematics",
    "Science",
    "English",
    "History",
    "Physics",
    "Chemistry",
    "Biology",
    "Computer Science"
  ];

  // Function to hash the password using SHA-256
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert the password to bytes
    var digest = sha256.convert(bytes); // Hash the password using SHA-256
    return digest.toString(); // Return the hashed password as a string
  }

  void _saveTeacher() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null || _selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select gender and subject")),
        );
        return;
      }

      final hashedPassword = _hashPassword(_passwordController.text.trim());

      final teacherData = {
        "name": _nameController.text.trim(),
        "gender": _selectedGender,
        "subject": _selectedSubject,
        "password": hashedPassword,
        "contact": _contactController.text.trim(),
      };

      _database
          .push()
          .set(teacherData)
          .then((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Teacher added successfully!")),
              );
              _formKey.currentState!.reset();
              setState(() {
                _selectedGender = null;
                _selectedSubject = null;
              });

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TeachersList()),
              );
            }
          })
          .catchError((error) {
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
          'Add New Teacher',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TeachersList()),
            );
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Image.asset("assets/images/teachers.png", height: 180),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildTextField(_nameController, "Teacher Name"),

                          // Gender Selection
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Gender",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text("Male"),
                                  value: "Male",
                                  groupValue: _selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text("Female"),
                                  value: "Female",
                                  groupValue: _selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          // Subject Dropdown
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Subject",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedSubject,
                            items: _subjects.map((subject) {
                              return DropdownMenuItem<String>(
                                value: subject,
                                child: Text(subject),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSubject = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                            ),
                            validator: (value) =>
                                value == null ? "Please select a subject" : null,
                          ),

                          _buildTextField(
                            _passwordController,
                            "Password",
                            isPassword: true,
                          ),
                          _buildTextField(
                            _contactController,
                            "Contact Number",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTeacher,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 0, 56, 209),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Add Teacher",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
  }) {
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
              color: Color.fromARGB(255, 27, 2, 255),
              width: 2,
            ),
          ),
        ),
        validator: (value) => value!.isEmpty ? "$label is required" : null,
      ),
    );
  }
}
