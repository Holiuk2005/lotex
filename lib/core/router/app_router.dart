import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auction/domain/entities/auction_entity.dart';
import '../../features/auction/presentation/pages/auction_details_screen.dart';
import '../../features/auction/presentation/pages/create_auction_screen.dart';
import '../../features/auction/presentation/pages/edit_auction_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/profile/presentation/pages/settings_screen.dart';
import '../../features/profile/presentation/pages/public_profile_screen.dart';
import '../../features/auction/presentation/pages/shipping_screen.dart';
import '../../features/auction/presentation/pages/payment_screen.dart';
import '../../features/auction/presentation/pages/order_checkout_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/profile/presentation/pages/register_screen.dart';
import '../../features/main_wrapper/main_wrapper.dart';
import '../../features/favorites/presentation/pages/favorites_screen.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/home/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');
  final shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  final shellNavigatorFavoritesKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellFavorites');
  final shellNavigatorCreateKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellCreate');
  final shellNavigatorChatKey = GlobalKey<NavigatorState>(debugLabel: 'shellChat');
  final shellNavigatorProfileKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  // refreshListenable is used to re-run redirect when auth state changes.
  // Avoid using deprecated `.stream` on StreamProvider.
  final authRefresh = ValueNotifier<int>(0);
  ref.onDispose(authRefresh.dispose);
  // Important: listen to the *derived* user provider to avoid a timing race
  // where redirect runs before `valueOrNull` updates.
  ref.listen<UserEntity?>(currentUserProvider, (_, __) {
    authRefresh.value++;
  });

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isLoggedIn = ref.read(currentUserProvider) != null;

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorHomeKey,
            routes: [
              GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorFavoritesKey,
            routes: [
              GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorCreateKey,
            routes: [
              GoRoute(path: '/create', builder: (context, state) => const CreateAuctionScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorChatKey,
            routes: [
              GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/auction',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final auction = state.extra as AuctionEntity;
          return AuctionDetailsScreen(auction: auction);
        },
      ),

      GoRoute(
        path: '/auction/:auctionId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['auctionId'] ?? '';
          if (id.isEmpty) {
            return const Scaffold(body: Center(child: Text('Auction not found')));
          }

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('auctions').doc(id).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                final err = snapshot.error;
                if (err is FirebaseException && err.code == 'permission-denied') {
                  return const Scaffold(
                    body: Center(child: Text('У вас немає доступу до цього аукціону')),
                  );
                }
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              final doc = snapshot.data;
              if (doc == null || !doc.exists) {
                return const Scaffold(body: Center(child: Text('Auction not found')));
              }
              final auction = AuctionEntity.fromDocument(doc);
              return AuctionDetailsScreen(auction: auction);
            },
          );
        },
      ),

      GoRoute(
        path: '/auction/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final auction = state.extra as AuctionEntity;
          return EditAuctionScreen(auction: auction);
        },
      ),

      GoRoute(
        path: '/shipping/:auctionId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['auctionId'] ?? '';
          return ShippingScreen(auctionId: id);
        },
      ),

      GoRoute(
        path: '/payment/:auctionId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['auctionId'] ?? '';
          return PaymentScreen(auctionId: id);
        },
      ),

      GoRoute(
        path: '/checkout',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          // Demo-friendly defaults.
          final extra = state.extra;
          double itemPrice = 1200;
          double shippingCost = 0;
          if (extra is Map) {
            final p = extra['itemPrice'];
            final s = extra['shippingCost'];
            if (p is num) itemPrice = p.toDouble();
            if (s is num) shippingCost = s.toDouble();
          }

          return OrderCheckoutScreen(
            itemPrice: itemPrice,
            shippingCost: shippingCost,
          );
        },
      ),

      GoRoute(
        path: '/user/:uid',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['uid'] ?? '';
          return PublicProfileScreen(uid: id);
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});