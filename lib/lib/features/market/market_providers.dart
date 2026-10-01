import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dashboard/dashboard_providers.dart';
import '../dashboard/data/mock_market_repository.dart';
import '../dashboard/model/market_models.dart';

/// Reuses the same live-then-fallback idea as the dashboard, kept simple
/// here since the company list changes far less often than prices — a
/// plain FutureProvider (no need to remember stale state) is enough.
final companyListProvider = FutureProvider<List<CompanyListItem>>((ref) async {
  try {
    final repo = ref.read(marketRepositoryProvider);
    return await repo.getCompanyList().timeout(const Duration(seconds: 8));
  } catch (_) {
    return MockMarketRepository().getCompanyList();
  }
});

/// Holds whatever the user has typed into the Market tab's search box.
final marketSearchQueryProvider = StateProvider<String>((ref) => '');

/// Holds the currently selected sector filter chip, or null for "All".
final marketSectorFilterProvider = StateProvider<String?>((ref) => null);

/// The actual filtered list the UI renders — combines the raw company
/// list with whatever search text and sector filter are currently active.
final filteredCompanyListProvider = Provider<AsyncValue<List<CompanyListItem>>>((ref) {
  final companiesAsync = ref.watch(companyListProvider);
  final query = ref.watch(marketSearchQueryProvider).toLowerCase().trim();
  final sector = ref.watch(marketSectorFilterProvider);

  return companiesAsync.whenData((companies) {
    return companies.where((c) {
      final matchesQuery = query.isEmpty ||
          c.symbol.toLowerCase().contains(query) ||
          c.companyName.toLowerCase().contains(query);
      final matchesSector = sector == null || c.sector == sector;
      return matchesQuery && matchesSector;
    }).toList();
  });
});
