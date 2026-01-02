import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesProvider = NotifierProvider<FavoritesController, Set<String>>(
  FavoritesController.new,
);

class FavoritesController extends Notifier<Set<String>> {
  static const _storageKey = 'lotex_favorite_auction_ids';
  bool _hydrated = false;

  @override
  Set<String> build() {
    if (!_hydrated) {
      _hydrated = true;
      _restore();
    }
    return <String>{};
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_storageKey) ?? const <String>[];
      state = ids.toSet();
    } catch (_) {
      // If storage is unavailable, keep in-memory state.
    }
  }

  Future<void> _persist(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, ids.toList(growable: false));
    } catch (_) {
      // Best-effort persistence.
    }
  }

  bool isFavorite(String auctionId) => state.contains(auctionId);

  void toggle(String auctionId) {
    final next = Set<String>.from(state);
    if (!next.add(auctionId)) {
      next.remove(auctionId);
    }
    state = next;
    _persist(next);
  }
}
