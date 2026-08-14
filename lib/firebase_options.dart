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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCJhq-MUyezdzYLrMWY0qiuR8Q6hY-LQfY',
    appId: '1:775748763322:web:ef8c09cf7c0e887d18cc83',
    messagingSenderId: '775748763322',
    projectId: 'dropout-prediction-af891',
    authDomain: 'dropout-prediction-af891.firebaseapp.com',
    storageBucket: 'dropout-prediction-af891.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJhq-MUyezdzYLrMWY0qiuR8Q6hY-LQfY',
    appId: '1:775748763322:web:ef8c09cf7c0e887d18cc83',
    messagingSenderId: '775748763322',
    projectId: 'dropout-prediction-af891',
    storageBucket: 'dropout-prediction-af891.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCJhq-MUyezdzYLrMWY0qiuR8Q6hY-LQfY',
    appId: '1:775748763322:web:ef8c09cf7c0e887d18cc83',
    messagingSenderId: '775748763322',
    projectId: 'dropout-prediction-af891',
    storageBucket: 'dropout-prediction-af891.firebasestorage.app',
  );
}
