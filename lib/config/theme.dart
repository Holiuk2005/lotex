import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/firebase_options.dart';
import 'package:lotex/features/auction/data/auction_repository.dart';
import 'package:lotex/features/auction/domain/auction_entity.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: LotexApp()));
}

class LotexApp extends StatelessWidget {
  const LotexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lotex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuctionListScreen(),
    );
  }
}

class AuctionListScreen extends ConsumerWidget {
  const AuctionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctionData = ref.watch(auctionStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lotex Market')),
      body: auctionData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Помилка: $err')),
        data: (auctions) {
          if (auctions.isEmpty) {
            return const Center(child: Text('Лотів поки немає 📦'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: auctions.length,
            itemBuilder: (context, index) {
              return AuctionCard(auction: auctions[index]);
            },
          );
        },
      ),
    );
  }
}

class AuctionCard extends StatelessWidget {
  final AuctionEntity auction;
  const AuctionCard({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(auction.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Статус: ${auction.status}"),
        trailing: Text(
          "\$${auction.currentPrice}",
          style: const TextStyle(fontSize: 18, color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}