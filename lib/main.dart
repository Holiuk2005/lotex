import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart'; 
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else {
    await Firebase.initializeApp();
  }

  runApp(const ProviderScope(child: LotexApp()));
}

class LotexApp extends ConsumerWidget {
  const LotexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.mode,
      builder: (context, mode, _) {
        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          title: 'Lotex',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
        );
      },
    );
  }
}

// HomeScreen moved to features/home/home_screen.dart