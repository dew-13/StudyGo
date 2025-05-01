const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendReminder = functions.https.onCall(async (data, context) => {
  const studentId = data.studentId;
  const studentName = data.studentName;

  if (!studentId || !studentName) {
    throw new functions.https.HttpsError("invalid-argument Missing parameters");
  }

  // Get the student's device token
  // eslint-disable-next-line max-len
  const snapshot = await admin.database().ref("users/${studentId}").once("value");
  if (!snapshot.exists()) {
    throw new functions.https.HttpsError("not-found Student not found");
  }

  const userData = snapshot.val();
  const deviceToken = userData.deviceToken;

  if (!deviceToken) {
    throw new functions.https.HttpsError("notfound Device token not available");
  }

  // Create the message
  const message = {
    token: deviceToken,
    notification: {
      title: "Payment Reminder",
      body: `Hi ${studentName}, your payment is pending. Please pay ASAP.`,
    },
  };

  // Send the message
  await admin.messaging().send(message);

  return {success: true};
});
