import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_go/student/student_profile.dart';
import 'package:study_go/logins/custom_scaffold.dart';
import 'package:study_go/teacher/teacher_panel.dart';
import '../theme/theme.dart';
import 'package:study_go/logins/common_otp.dart';
import 'package:study_go/logins/welcome_screen.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    loadUserCredentials();
  }

  Future<void> loadUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool remember = prefs.getBool('remember_me') ?? false;
    if (remember) {
      String? savedPhone = prefs.getString('phone');
      String? savedPassword = prefs.getString('password');
      setState(() {
        rememberPassword = remember;
        phoneController.text = savedPhone ?? '';
        passwordController.text = savedPassword ?? '';
      });
    }
  }

  Future<void> saveUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberPassword) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('phone', phoneController.text.trim());
      await prefs.setString('password', passwordController.text);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('phone');
      await prefs.remove('password');
    }
  }

  void loginUser() async {
    if (_formSignInKey.currentState!.validate()) {
      await saveUserCredentials();
      String phoneNumber = phoneController.text.trim();
      String inputPassword = passwordController.text.trim();
      String hashedInputPassword = sha256.convert(utf8.encode(inputPassword)).toString();

      // Check Student Table
      DatabaseEvent studentSnapshot = await dbRef
          .child('students')
          .orderByChild('contact')
          .equalTo(phoneNumber)
          .once();

      if (studentSnapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(
            studentSnapshot.snapshot.value as Map<dynamic, dynamic>);
        final studentEntry = data.entries.first.value as Map<dynamic, dynamic>;
        if (studentEntry['password'] == hashedInputPassword) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentPanel(
                contact: phoneNumber,
                password: inputPassword,
              ),
            ),
          );
          return;
        }
      }

      // Check Teacher Table
      DatabaseEvent teacherSnapshot = await dbRef
          .child('teachers')
          .orderByChild('contact')
          .equalTo(phoneNumber)
          .once();

      if (teacherSnapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(
            teacherSnapshot.snapshot.value as Map<dynamic, dynamic>);
        final teacherEntry = data.entries.first.value as Map<dynamic, dynamic>;
        if (teacherEntry['password'] == hashedInputPassword) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherPanel(
                contact: phoneNumber,
                password: inputPassword,
              ),
            ),
          );
          return;
        }
      }

      // Either phone not found or password incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number or password')),
      );
    }
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
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      TextFormField(
                        controller: phoneController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Phone Number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Phone Number'),
                          hintText: 'Enter Registered Phone Number',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                          
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loginUser,
                          child: const Text('Log In'),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'First Time User? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Click Here',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (e) => const WelcomeScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Back to Home',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: lightColorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 80.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              
                              const Text(
                                'Forgot password? ',
                                style: TextStyle(color: Colors.black45),
                              ),
                              const Text(
                                ' Please Contact Admin.',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
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
