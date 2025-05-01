import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:study_go/logins/custom_scaffold.dart';
import 'package:study_go/admin/register_screen.dart';
import 'package:study_go/admin/admin_welcome_screen.dart';
import 'package:study_go/admin/reset_password.dart';
import '../theme/theme.dart';
import 'package:study_go/admin/admin_panel.dart'; // Import the admin panel screen
import 'package:shared_preferences/shared_preferences.dart'; // NEW import

class AdminLogInScreen extends StatefulWidget {
  const AdminLogInScreen({super.key});

  @override
  State<AdminLogInScreen> createState() => _AdminLogInScreenState();
}

class _AdminLogInScreenState extends State<AdminLogInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('admins');

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // Load saved credentials when screen loads
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('admin_username');
    final savedPassword = prefs.getString('admin_password');
    final remember = prefs.getBool('remember_admin') ?? false;

    if (remember && savedUsername != null && savedPassword != null) {
      setState(() {
        usernameController.text = savedUsername;
        passwordController.text = savedPassword;
        rememberPassword = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberPassword) {
      await prefs.setString('admin_username', usernameController.text.trim());
      await prefs.setString('admin_password', passwordController.text.trim());
      await prefs.setBool('remember_admin', true);
    } else {
      await prefs.remove('admin_username');
      await prefs.remove('admin_password');
      await prefs.setBool('remember_admin', false);
    }
  }

  // Function to validate admin credentials
  Future<void> _validateAdmin() async {
    if (_formSignInKey.currentState!.validate()) {
      final String username = usernameController.text.trim();
      final String password = passwordController.text.trim();

      try {
        // Fetch admin data from Firebase Realtime Database
        final snapshot = await _databaseRef.orderByChild('username').equalTo(username).once();

        if (snapshot.snapshot.value != null) {
          // Extract admin data
          final Map<dynamic, dynamic> admins = snapshot.snapshot.value as Map<dynamic, dynamic>;
          bool isAuthenticated = false;

          admins.forEach((key, value) {
            if (value['username'] == username && value['password'] == password) {
              isAuthenticated = true;
            }
          });

          if (isAuthenticated) {
            await _saveCredentials(); // Save credentials if authenticated
            // Navigate to AdminPanel if credentials are correct
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminPanel()),
            );
          } else {
            // Show error if credentials are incorrect
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid username or password')),
            );
          }
        } else {
          // Show error if username is not found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin not found')),
          );
        }
      } catch (e) {
        // Show error if Firebase operation fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
                        controller: usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Username';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Username'),
                          hintText: 'Enter Your Username',
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const ResetPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _validateAdmin,
                          child: const Text('Log In'),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'New Admin? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const RegisterScreen(),
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
                              builder: (e) => const AdminWelcomeScreen(),
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
