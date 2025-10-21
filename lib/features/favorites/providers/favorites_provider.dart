import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/presentation/providers/event_providers.dart';

/// ------------------------------------------------------
/// FAVORITES STATE NOTIFIER
/// ------------------------------------------------------
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  static const _favoritesKey = 'user_favorites';

  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_favoritesKey) ?? [];
      state = stored.toSet();
    } catch (_) {
      state = {};
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, state.toList());
    } catch (_) {}
  }

  void toggleFavorite(String eventId) {
    if (state.contains(eventId)) {
      state = {...state}..remove(eventId);
    } else {
      state = {...state, eventId};
    }
    _saveFavorites();
  }

  bool isFavorite(String eventId) => state.contains(eventId);

  void addFavorite(String eventId) {
    if (!state.contains(eventId)) {
      state = {...state, eventId};
      _saveFavorites();
    }
  }

  void removeFavorite(String eventId) {
    if (state.contains(eventId)) {
      state = {...state}..remove(eventId);
      _saveFavorites();
    }
  }

  void clearAllFavorites() {
    state = {};
    _saveFavorites();
  }

  int get count => state.length;
}

/// ------------------------------------------------------
/// DERIVED PROVIDER — FAVORITE EVENTS LIST
/// ------------------------------------------------------
/// This listens reactively to both favorites and event stream updates.
final favoriteEventsProvider = Provider<List<EventEntity>>((ref) {
  final favoriteIds = ref.watch(favoritesProvider);
  final eventsAsync = ref.watch(approvedEventsStreamProvider);

  return eventsAsync.when(
    data: (events) =>
        events.where((e) => favoriteIds.contains(e.id)).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
