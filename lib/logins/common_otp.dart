import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:study_go/logins/login_screen.dart';
import 'package:study_go/theme/theme.dart';
import 'package:study_go/logins/custom_scaffold.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> _validatePhoneNumberAndOTP(String contact, String otp, String userType) async {
    final hashedOTP = _hashPassword(otp);
    DatabaseEvent snapshot = await _database.child(userType).orderByChild('contact').equalTo(contact).once();

    if (snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> users = snapshot.snapshot.value as Map<dynamic, dynamic>;
      for (var key in users.keys) {
        var userData = users[key];
        if (userData['password'] == hashedOTP) {
          return key;
        }
      }
      return 'invalid_otp';
    }
    return null;
  }

  Future<void> _updatePassword(String userKey, String password, String userType) async {
    final hashedPassword = _hashPassword(password);
    await _database.child('$userType/$userKey').update({'password': hashedPassword});
  }

  void _signUp() async {
    if (_formSignupKey.currentState!.validate() && agreePersonalData) {
      String contact = _contactController.text.trim();
      String otp = _otpController.text.trim();
      String password = _newPasswordController.text;

      String? studentKey = await _validatePhoneNumberAndOTP(contact, otp, 'students');
      String? teacherKey = await _validatePhoneNumberAndOTP(contact, otp, 'teachers');

      if (studentKey == 'invalid_otp' || teacherKey == 'invalid_otp') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please enter the correct OTP.')),
        );
      } else if (studentKey != null) {
        await _updatePassword(studentKey, password, 'students');
        _navigateToLogin();
      } else if (teacherKey != null) {
        await _updatePassword(teacherKey, password, 'teachers');
        _navigateToLogin();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number not found in records')),
        );
      }
    } else if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the processing of personal data')),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LogInScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Get Started', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w900, color: lightColorScheme.primary)),
                      const SizedBox(height: 40.0),
                      TextFormField(controller: _contactController, validator: (value) => value!.isEmpty ? 'Please enter your registered telephone number' : null, decoration: InputDecoration(label: const Text('Registered Telephone Number'), hintText: 'Enter Telephone Number', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 25.0),
                      TextFormField(controller: _otpController, validator: (value) => value!.isEmpty ? 'Please enter One Time Password' : null, decoration: InputDecoration(label: const Text('OTP'), hintText: 'Enter First Time Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 25.0),
                      TextFormField(controller: _newPasswordController, obscureText: true, validator: (value) => value!.isEmpty ? 'Enter a new password' : null, decoration: InputDecoration(label: const Text('New Password'), hintText: 'Enter New Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 25.0),
                      TextFormField(controller: _confirmPasswordController, obscureText: true, validator: (value) => value != _newPasswordController.text ? 'Passwords do not match' : null, decoration: InputDecoration(label: const Text('Confirm New Password'), hintText: 'Confirm New Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 25.0),
                      Row(children: [Checkbox(value: agreePersonalData, onChanged: (bool? value) { setState(() { agreePersonalData = value!; }); }, activeColor: lightColorScheme.primary), const Text('I agree to the processing of Personal data')]),
                      const SizedBox(height: 25.0),
                      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _signUp, child: const Text('Sign up'))),
                      const SizedBox(height: 25.0),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Already a User? '), GestureDetector(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (e) => const LogInScreen())); }, child: Text('Log in', style: TextStyle(fontWeight: FontWeight.bold, color: lightColorScheme.primary)))])
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
