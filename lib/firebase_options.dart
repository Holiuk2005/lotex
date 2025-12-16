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
        throw UnsupportedError(
          'Android options are not configured in this file.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS options are not configured in this file.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'macOS options are not configured in this file.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Windows options are not configured in this file.',
        );
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

  // ОСЬ ТУТ ВСТАВТЕ ДАНІ З FIREBASE CONSOLE:
  static const FirebaseOptions web = FirebaseOptions(
  apiKey: "AIzaSyCXIqFFRDcoggp42HumK_oOGc8cAbpGVs0",
  authDomain: "lotex-4890a.firebaseapp.com",
  projectId: "lotex-4890a",
  storageBucket: "lotex-4890a.firebasestorage.app",
  messagingSenderId: "823233113152",
  appId: "1:823233113152:web:6565f42bcee8b4acb883a5",
  measurementId: "G-NP3NFWETVL"
  );
}