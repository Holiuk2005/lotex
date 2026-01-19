// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'Linux options are not configured in this file.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCXIqFFRDcoggp42HumK_oOGc8cAbpGVs0',
    appId: '1:823233113152:web:e55363b4182bac51b883a5',
    messagingSenderId: '823233113152',
    projectId: 'lotex-4890a',
    authDomain: 'lotex-4890a.firebaseapp.com',
    storageBucket: 'lotex-4890a.firebasestorage.app',
    measurementId: 'G-WWG4VZ75W2',
  );

  // ОСЬ ТУТ ВСТАВТЕ ДАНІ З FIREBASE CONSOLE:

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDQSla4mzDuocuFYj-MMMt6FBLNSBkPaXg',
    appId: '1:823233113152:ios:47970db92db8909fb883a5',
    messagingSenderId: '823233113152',
    projectId: 'lotex-4890a',
    storageBucket: 'lotex-4890a.firebasestorage.app',
    androidClientId: '823233113152-eblfsj3edhp7ug8evhocrnt1kqidp4tk.apps.googleusercontent.com',
    iosClientId: '823233113152-i6uisql4eg8vfp7qu5i8u9r2lgt6d76h.apps.googleusercontent.com',
    iosBundleId: 'com.example.lotex',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDQSla4mzDuocuFYj-MMMt6FBLNSBkPaXg',
    appId: '1:823233113152:ios:47970db92db8909fb883a5',
    messagingSenderId: '823233113152',
    projectId: 'lotex-4890a',
    storageBucket: 'lotex-4890a.firebasestorage.app',
    androidClientId: '823233113152-eblfsj3edhp7ug8evhocrnt1kqidp4tk.apps.googleusercontent.com',
    iosClientId: '823233113152-i6uisql4eg8vfp7qu5i8u9r2lgt6d76h.apps.googleusercontent.com',
    iosBundleId: 'com.example.lotex',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHlPOLUuBt__ppa-TQtizFCjwNcQU0DNQ',
    appId: '1:823233113152:android:3a10dcde54334bd2b883a5',
    messagingSenderId: '823233113152',
    projectId: 'lotex-4890a',
    storageBucket: 'lotex-4890a.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCXIqFFRDcoggp42HumK_oOGc8cAbpGVs0',
    appId: '1:823233113152:web:68c71885e4edb69db883a5',
    messagingSenderId: '823233113152',
    projectId: 'lotex-4890a',
    authDomain: 'lotex-4890a.firebaseapp.com',
    storageBucket: 'lotex-4890a.firebasestorage.app',
    measurementId: 'G-HWCD3BQZY1',
  );

}