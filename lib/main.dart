import 'dart:developer' as developer;
import 'dart:ui' show ImageFilter, PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/core/router/app_router.dart';
import 'package:lotex/core/theme/app_colors.dart';
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

  runApp(const ProviderScope(child: LotexBootstrap()));
}

class LotexBootstrap extends StatefulWidget {
  const LotexBootstrap({super.key});

  @override
  State<LotexBootstrap> createState() => _LotexBootstrapState();
}

class _LotexBootstrapState extends State<LotexBootstrap> {
  static final Future<void> _initFuture = _initializeApp();

  static Future<void> _initializeApp() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Avoid rare Firestore web SDK internal assertion failures caused by local
    // persistence state (especially during hot-restart / multi-tab / quick nav).
    // This disables offline persistence.
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: false);

    developer.log(
      'Firebase initialized: projectId=${DefaultFirebaseOptions.currentPlatform.projectId}, appId=${DefaultFirebaseOptions.currentPlatform.appId}',
      name: 'Lotex',
    );

    if (_useFirebaseEmulators) {
      await _connectToFirebaseEmulators();
    }

    // Make the mobile loading moment visible and consistent.
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      await Future<void>.delayed(const Duration(milliseconds: 1100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        final Widget child;
        if (snapshot.hasError) {
          child = MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: _StartupErrorScreen(error: snapshot.error),
          );
        } else if (snapshot.connectionState != ConnectionState.done) {
          // Web already has HTML splash; show a minimal, app-like loader mainly
          // for native mobile platforms.
          child = MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const LotexAppLoadingScreen(),
          );
        } else {
          child = const MyApp();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final key = child.key is ValueKey<String>
                ? (child.key! as ValueKey<String>).value
                : null;
            final isApp = key == 'app';

            final curved =
                CurvedAnimation(parent: animation, curve: Curves.easeOut);
            final fade = Tween<double>(begin: 0, end: 1).animate(curved);
            final scale = Tween<double>(begin: 0.985, end: 1.0).animate(curved);
            final slide =
                Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero)
                    .animate(curved);

            Widget current = FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: ScaleTransition(scale: scale, child: child),
              ),
            );

            if (!isApp) {
              current = AnimatedBuilder(
                animation: animation,
                child: current,
                builder: (context, child) {
                  final t = animation.value;
                  final sigma = (1.0 - t) * 6.0;
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                    child: child,
                  );
                },
              );
            }

            return current;
          },
          child: KeyedSubtree(
            key: ValueKey<String>(
              snapshot.hasError
                  ? 'error'
                  : (snapshot.connectionState == ConnectionState.done
                      ? 'app'
                      : 'loading'),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class LotexAppLoadingScreen extends StatelessWidget {
  const LotexAppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final title = isDark ? AppColors.darkTitle : AppColors.lightTitle;
    final body = isDark ? AppColors.darkBody : AppColors.lightBody;

    return Scaffold(
      backgroundColor: background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    AppColors.darkBackground,
                    Color(0xFF0B1028),
                  ]
                : const [
                    Color(0xFFFDFDFF),
                    Color(0xFFF6F4FF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    boxShadow: isDark
                        ? const [
                            BoxShadow(
                              color: Color(0x66000000),
                              blurRadius: 40,
                              offset: Offset(0, 20),
                            )
                          ]
                        : const [
                            BoxShadow(
                              color: Color(0x1A020617),
                              blurRadius: 40,
                              offset: Offset(0, 20),
                            )
                          ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary500,
                                    AppColors.secondary500,
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x338B5CF6),
                                    blurRadius: 24,
                                    offset: Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/branding/logo.png',
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Lotex',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: title,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Завантаження застосунка…',
                          style: TextStyle(
                            fontSize: 14,
                            color: body,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 10,
                                  backgroundColor: isDark
                                      ? const Color(0x1FFFFFFF)
                                      : const Color(0x140F172A),
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.primary500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  final Object? error;

  const _StartupErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Помилка запуску: $error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

Future<void> _connectToFirebaseEmulators() async {
  final host = _emulatorHost();
  developer.log('Connecting to Firebase emulators at $host', name: 'Lotex');

  // Auth
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);

  // Firestore
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  // Avoid persistence quirks when switching between emulator/real project.
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: false);

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
