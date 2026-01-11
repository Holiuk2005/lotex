import 'dart:developer' as developer;
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/core/router/app_router.dart';
import 'package:lotex/core/theme/app_theme.dart';
import 'package:lotex/core/theme/theme_manager.dart';
import 'firebase_options.dart';

const bool _useFirebaseEmulators = bool.fromEnvironment(
  'USE_FIREBASE_EMULATORS',
  defaultValue: false,
);

Future<void> main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      details.exceptionAsString(),
      name: 'FlutterError',
      stackTrace: details.stack,
      error: details.exception,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log(
      error.toString(),
      name: 'PlatformError',
      stackTrace: stack,
      error: error,
    );
    return false; // allow default handler in debug
  };

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Avoid rare Firestore web SDK internal assertion failures caused by local
  // persistence state (especially during hot-restart / multi-tab / quick nav).
  // This disables offline persistence.
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);

  developer.log(
    'Firebase initialized: projectId=${DefaultFirebaseOptions.currentPlatform.projectId}, appId=${DefaultFirebaseOptions.currentPlatform.appId}',
    name: 'Lotex',
  );

  if (_useFirebaseEmulators) {
    await _connectToFirebaseEmulators();
  }

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _connectToFirebaseEmulators() async {
  final host = _emulatorHost();
  developer.log('Connecting to Firebase emulators at $host', name: 'Lotex');

  // Auth
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);

  // Firestore
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  // Avoid persistence quirks when switching between emulator/real project.
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);

  // Storage
  FirebaseStorage.instance.useStorageEmulator(host, 9199);

  // Functions
  FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
}

String _emulatorHost() {
  if (kIsWeb) return 'localhost';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      // Android emulator maps host loopback to 10.0.2.2
      return '10.0.2.2';
    default:
      return 'localhost';
  }
}

/// Keep the public name `MyApp` because tests/imports reference it.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.mode,
      builder: (context, mode, _) {
        return MaterialApp.router(
          title: 'Lotex',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          routerConfig: router,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('uk'),
            Locale('en'),
          ],
        );
      },
    );
  }
}
