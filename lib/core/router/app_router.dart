import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auction/domain/entities/auction_entity.dart';
import '../../features/auction/presentation/pages/auction_details_screen.dart';
import '../../features/auction/presentation/pages/create_auction_screen.dart';
import '../../features/auction/presentation/pages/edit_auction_screen.dart';
import '../../features/auction/presentation/providers/auction_detail_provider.dart';
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
import '../../features/marketplace/presentation/pages/create_marketplace_item_screen.dart';
import '../../features/marketplace/presentation/pages/marketplace_item_details_screen.dart';
import '../../features/marketplace/presentation/providers/marketplace_providers.dart';

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

  // refreshListenable — оновлює GoRouter при зміні стану автентифікації.
  // Відстежуємо похідний провайдер currentUserProvider, щоб redirect спрацьовував
  // лише після того, як valueOrNull оновився.
  final authRefresh = ValueNotifier<int>(0);
  ref.onDispose(authRefresh.dispose);
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
        redirect: (context, state) {
          if (state.extra is! AuctionEntity) return '/home';
          return null;
        },
        builder: (context, state) {
          final auction = state.extra as AuctionEntity;
          return AuctionDetailsScreen(auction: auction);
        },
      ),

      GoRoute(
        path: '/auction/:auctionId',
        parentNavigatorKey: rootNavigatorKey,
        // Дані завантажуються через auctionDetailProvider (StreamProvider) —
        // Firestore запити НЕ виконуються безпосередньо в builder роутера.
        builder: (context, state) {
          final id = state.pathParameters['auctionId'] ?? '';
          if (id.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Лот не знайдено')),
            );
          }
          return _AuctionDetailLoader(auctionId: id);
        },
      ),

      GoRoute(
        path: '/auction/edit',
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) {
          if (state.extra is! AuctionEntity) return '/home';
          return null;
        },
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
          final extra = state.extra;
          // Якщо extra відсутній або не містить itemPrice — показуємо помилку.
          double? itemPrice;
          double shippingCost = 0;
          if (extra is Map) {
            final p = extra['itemPrice'];
            final s = extra['shippingCost'];
            if (p is num) itemPrice = p.toDouble();
            if (s is num) shippingCost = s.toDouble();
          }
          if (itemPrice == null) {
            return const Scaffold(
              body: Center(
                child: Text('Помилка: не передано ціну товару для оформлення замовлення.'),
              ),
            );
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

      GoRoute(
        path: '/marketplace/create',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreateMarketplaceItemScreen(),
      ),

      GoRoute(
        path: '/marketplace/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          if (id.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Товар не знайдено')),
            );
          }
          return _MarketplaceDetailLoader(itemId: id);
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

/// Виджет-завантажник для маршруту /auction/:auctionId.
/// Використовує [auctionDetailProvider] (StreamProvider) замість прямого Firestore-запиту в роутері.
class _AuctionDetailLoader extends ConsumerWidget {
  final String auctionId;
  const _AuctionDetailLoader({required this.auctionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctionAsync = ref.watch(auctionDetailProvider(auctionId));
    return auctionAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) {
        final msg = e.toString().contains('permission-denied')
            ? 'У вас немає доступу до цього аукціону.'
            : 'Помилка завантаження: $e';
        return Scaffold(body: Center(child: Text(msg)));
      },
      data: (auction) => AuctionDetailsScreen(auction: auction),
    );
  }
}

class _MarketplaceDetailLoader extends ConsumerWidget {
  final String itemId;
  const _MarketplaceDetailLoader({required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(marketplaceDetailProvider(itemId));
    return itemAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) {
        final msg = e.toString().contains('permission-denied')
            ? 'У вас немає доступу до цього товару.'
            : 'Помилка завантаження: $e';
        return Scaffold(body: Center(child: Text(msg)));
      },
      data: (item) => MarketplaceItemDetailsScreen(item: item),
    );
  }
}