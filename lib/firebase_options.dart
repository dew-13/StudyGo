
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBRGQeh7o_OydfcSImJxVOdz8xSA4XBWiA',
    appId: '1:961495830989:web:1a1a04ec439fd40117f484',
    messagingSenderId: '961495830989',
    projectId: 'classapp-3ebe1',
    authDomain: 'classapp-3ebe1.firebaseapp.com',
    databaseURL: 'https://classapp-3ebe1-default-rtdb.firebaseio.com',
    storageBucket: 'classapp-3ebe1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCK_TvJqc7BmCOhnNUeQMr-xl66OEplkQM',
    appId: '1:961495830989:android:e46e3924fa8a70eb17f484',
    messagingSenderId: '961495830989',
    projectId: 'classapp-3ebe1',
    databaseURL: 'https://classapp-3ebe1-default-rtdb.firebaseio.com',
    storageBucket: 'classapp-3ebe1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSn9pszzb7iXD1oG_CT_RDuftuIBIlYvQ',
    appId: '1:961495830989:ios:5a57e5f4dd95b14417f484',
    messagingSenderId: '961495830989',
    projectId: 'classapp-3ebe1',
    databaseURL: 'https://classapp-3ebe1-default-rtdb.firebaseio.com',
    storageBucket: 'classapp-3ebe1.firebasestorage.app',
    iosBundleId: 'com.example.studyGo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDSn9pszzb7iXD1oG_CT_RDuftuIBIlYvQ',
    appId: '1:961495830989:ios:5a57e5f4dd95b14417f484',
    messagingSenderId: '961495830989',
    projectId: 'classapp-3ebe1',
    databaseURL: 'https://classapp-3ebe1-default-rtdb.firebaseio.com',
    storageBucket: 'classapp-3ebe1.firebasestorage.app',
    iosBundleId: 'com.example.studyGo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBRGQeh7o_OydfcSImJxVOdz8xSA4XBWiA',
    appId: '1:961495830989:web:7fc54cce63d4642817f484',
    messagingSenderId: '961495830989',
    projectId: 'classapp-3ebe1',
    authDomain: 'classapp-3ebe1.firebaseapp.com',
    databaseURL: 'https://classapp-3ebe1-default-rtdb.firebaseio.com',
    storageBucket: 'classapp-3ebe1.firebasestorage.app',
  );

}