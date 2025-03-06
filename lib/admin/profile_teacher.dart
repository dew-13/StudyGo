import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_go/admin/list_teachers.dart';

class TeacherProfile extends StatefulWidget {
  final Map<String, dynamic> teacher;

  const TeacherProfile({super.key, required this.teacher});

  @override
  State<TeacherProfile> createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile> {
  late TextEditingController _nameController;
  late TextEditingController _genderController;
  late TextEditingController _subjectController;

  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacher["name"]);
    _genderController = TextEditingController(text: widget.teacher["gender"]);
    _subjectController = TextEditingController(text: widget.teacher["subject"]);
    _contactController = TextEditingController(text: widget.teacher["contact"]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    _subjectController.dispose();
    _contactController.dispose();
    super.dispose();
  }

 Future<void> _updateTeacher() async {
  try {
    await FirebaseFirestore.instance
        .collection('teachers')
        .doc(widget.teacher["id"]) // Ensure 'id' is passed
        .update({
      "name": _nameController.text,
      "gender": _genderController.text,
      "subject": _subjectController.text,
      "contact": _contactController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Teacher details updated successfully!")),
    );

    Navigator.pop(context); // Go back to the previous screen

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error updating: $e")),
    );
  }
}


  Future<void> _deleteTeacher() async {
    try {
      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(widget.teacher["id"]) // Ensure 'id' is passed
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Teacher deleted successfully!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TeachersList()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 2, 87),
        title: const Text(
          'Teacher Profile',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableField("Name", _nameController),
            const SizedBox(height: 16),
            _buildEditableField("Gender", _genderController),
            const SizedBox(height: 16),
            _buildEditableField("Subject", _subjectController),
            const SizedBox(height: 16),
            _buildEditableField("Contact Number", _contactController),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _updateTeacher,
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _deleteTeacher,
                  child: const Text("Delete", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ],
        ),
      ),
    );
  }
}
