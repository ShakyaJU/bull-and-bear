import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'data/market_repository.dart';
import 'data/mock_market_repository.dart';
import 'model/market_models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepository(ref.watch(apiClientProvider));
});

/// Everything the Dashboard screen needs, PLUS metadata about how fresh
/// and trustworthy it is. This "freshness" info is what lets the UI show
/// an honest "Live" / "Demo data" / "Updated 2 min ago" label instead of
/// silently mixing real and fake numbers with no distinction.
class DashboardData {
  const DashboardData({
    required this.summary,
    required this.index,
    required this.gainers,
    required this.losers,
    required this.isLive,
    required this.lastUpdated,
  });

  final MarketSummary summary;
  final NepseIndexData index;
  final List<MoverItem> gainers;
  final List<MoverItem> losers;

  /// true = this came from the real API just now.
  /// false = this is either demo data, or real data from an earlier
  /// successful fetch that we're still showing because the latest
  /// attempt failed (better than blanking the screen).
  final bool isLive;
  final DateTime lastUpdated;
}

/// This is an AsyncNotifier rather than a plain FutureProvider, because we
/// need to REMEMBER the last successful result and fall back to it — a
/// plain FutureProvider has no memory of its own previous value once a
/// new fetch starts.
///
/// This pattern is called "stale-while-revalidate": show what you have,
/// try to get something newer, and only replace what's on screen once the
/// newer data actually arrives successfully.
class DashboardController extends AsyncNotifier<DashboardData> {
  bool _everHadLiveData = false;

  @override
  Future<DashboardData> build() => _fetch();

  /// Called by pull-to-refresh, the auto-refresh timer, and the initial
  /// load. Tries the real API first; only touches `state` with a loading
  /// spinner-clearing update if we get SOMETHING (live or demo) back —
  /// on failure after already having live data, it just keeps what's there.
  Future<void> refresh() async {
    try {
      final fresh = await _fetch();
      state = AsyncData(fresh);
    } catch (_) {
      // If we already have something on screen, just leave it — a failed
      // background refresh shouldn't blank out a working dashboard.
      if (!state.hasValue) {
        state = AsyncData(await _mockSnapshot());
      }
    }
  }

  Future<DashboardData> _fetch() async {
    try {
      final repo = ref.read(marketRepositoryProvider);
      final results = await Future.wait([
        repo.getSummary(),
        repo.getNepseIndex(),
        repo.getTopGainers(),
        repo.getTopLosers(),
      ]).timeout(const Duration(seconds: 8));

      _everHadLiveData = true;
      return DashboardData(
        summary: results[0] as MarketSummary,
        index: results[1] as NepseIndexData,
        gainers: results[2] as List<MoverItem>,
        losers: results[3] as List<MoverItem>,
        isLive: true,
        lastUpdated: DateTime.now(),
      );
    } catch (_) {
      // Live fetch failed. If we've never had live data at all (e.g. very
      // first launch with no internet), show clearly-labeled demo data
      // so the app is still usable and demonstrable. If we HAD live data
      // before, prefer re-throwing so refresh() keeps the old snapshot
      // instead of overwriting it with demo numbers.
      if (_everHadLiveData) rethrow;
      return _mockSnapshot();
    }
  }

  Future<DashboardData> _mockSnapshot() async {
    final mockRepo = MockMarketRepository();
    final results = await Future.wait([
      mockRepo.getSummary(),
      mockRepo.getNepseIndex(),
      mockRepo.getTopGainers(),
      mockRepo.getTopLosers(),
    ]);
    return DashboardData(
      summary: results[0] as MarketSummary,
      index: results[1] as NepseIndexData,
      gainers: results[2] as List<MoverItem>,
      losers: results[3] as List<MoverItem>,
      isLive: false,
      lastUpdated: DateTime.now(),
    );
  }
}

final dashboardControllerProvider = AsyncNotifierProvider<DashboardController, DashboardData>(
  DashboardController.new,
);
