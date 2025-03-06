import 'package:study_go/logins/admin_login.dart';
import 'package:study_go/logins/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:study_go/logins/login_screen.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome to\n',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      TextSpan(
                        text: 'LearnGo\n',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '\nHigh-quality tuition classes\n for students of all levels. ',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Admin Icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminLogInScreen()),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Admin', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                  // Teacher Icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  LogInScreen()),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school, size: 50, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Teacher', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                  // Student Icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LogInScreen()),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, size: 50, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Student', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}