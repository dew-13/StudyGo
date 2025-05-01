import 'package:cloud_functions/cloud_functions.dart';

class NotificationService {
  static Future<void> sendReminder(String studentId, String studentName) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendReminder');
      await callable.call({
        'studentId': studentId,
        'studentName': studentName,
      });
      print('Reminder sent successfully');
    } catch (e) {
      print('Failed to send reminder: $e');
      rethrow;
    }
  }
}
