import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDGYxxTyjqewIdSDXjutTRHbjcRQJfLtBk',
    appId: '1:YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'postinfo-app',
    authDomain: 'postinfo-app.firebaseapp.com',
    storageBucket: 'postinfo-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGYxxTyjqewIdSDXjutTRHbjcRQJfLtBk',
    appId: '1:YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'postinfo-app',
    storageBucket: 'postinfo-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDGYxxTyjqewIdSDXjutTRHbjcRQJfLtBk',
    appId: '1:YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'postinfo-app',
    storageBucket: 'postinfo-app.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.postinfo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDGYxxTyjqewIdSDXjutTRHbjcRQJfLtBk',
    appId: '1:YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'postinfo-app',
    storageBucket: 'postinfo-app.appspot.com',
    iosBundleId: 'com.example.postinfo.RunnerTests',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDGYxxTyjqewIdSDXjutTRHbjcRQJfLtBk',
    appId: '1:YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'postinfo-app',
    storageBucket: 'postinfo-app.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDGYxxTyjqewIdSDXjutTRHbjcRQJfLtBk',
    appId: '1:YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'postinfo-app',
    storageBucket: 'postinfo-app.appspot.com',
  );
}
