import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auction/domain/entities/auction_entity.dart';
import '../../features/auction/presentation/pages/auction_details_screen.dart';
import '../../features/auction/presentation/pages/create_auction_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/profile/presentation/pages/register_screen.dart';
import '../../features/main_wrapper/main_wrapper.dart';
import '../../features/favorites/presentation/pages/favorites_screen.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/home/home_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>();
final _shellNavigatorCreateKey = GlobalKey<NavigatorState>();
final _shellNavigatorFavoritesKey = GlobalKey<NavigatorState>();
final _shellNavigatorChatKey = GlobalKey<NavigatorState>();
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorFavoritesKey,
            routes: [
              GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCreateKey,
            routes: [
              GoRoute(path: '/create', builder: (context, state) => const CreateAuctionScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorChatKey,
            routes: [
              GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/auction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final auction = state.extra as AuctionEntity;
          return AuctionDetailsScreen(auction: auction);
        },
      ),
    ],
  );
});