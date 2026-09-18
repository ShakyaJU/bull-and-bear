import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _watchlistPrefKey = 'watchlist_symbols';

/// Holds the user's saved stock symbols (e.g. "NABIL", "NICA") and persists
/// them on-device with SharedPreferences. No account, no login, no server —
/// this data belongs entirely to whoever's holding the phone.
class WatchlistController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _loadSaved();
    return <String>{};
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_watchlistPrefKey) ?? [];
    state = saved.toSet();
  }

  Future<void> toggle(String symbol) async {
    final updated = Set<String>.from(state);
    if (updated.contains(symbol)) {
      updated.remove(symbol);
    } else {
      updated.add(symbol);
    }
    state = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_watchlistPrefKey, updated.toList());
  }

  bool isWatched(String symbol) => state.contains(symbol);
}

final watchlistProvider = NotifierProvider<WatchlistController, Set<String>>(
  WatchlistController.new,
);
