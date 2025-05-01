import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveFCMToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String? token = await messaging.getToken();
    if (token != null) {
      // Save the token in the Firestore 'students' collection
      await FirebaseFirestore.instance.collection('students').doc(user.uid).update({
        'fcmToken': token,
      });
    }
  }
}
