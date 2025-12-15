import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart'; 
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'features/auction/presentation/providers/auction_list_provider.dart';
import 'features/auction/presentation/widgets/auction_card.dart';

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
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Lotex',
      theme: AppTheme.lightTheme,
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctionsAsync = ref.watch(auctionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lotex Auctions"),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: auctionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary600)),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (auctions) {
          if (auctions.isEmpty) return const Center(child: Text("Немає лотів"));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: auctions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final auction = auctions[index];
              return AuctionCard(
                auction: auction,
                onTap: () => context.push('/auction', extra: auction),
              );
            },
          );
        },
      ),
    );
  }
}