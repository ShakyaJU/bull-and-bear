import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/stock_avatar.dart';
import '../dashboard/dashboard_providers.dart';
import '../dashboard/model/market_models.dart';
import 'data/watchlist_controller.dart';

/// Shows the stocks the user has starred from the Dashboard. This screen
/// cross-references today's gainers/losers data to show a live price next
/// to each symbol, if we happen to have it — otherwise it just shows the
/// symbol with a note that live data isn't loaded for it yet.
class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watched = ref.watch(watchlistProvider);
    final dashboardAsync = ref.watch(dashboardControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: watched.isEmpty
          ? const _EmptyWatchlist()
          : dashboardAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _WatchlistSymbolsOnly(symbols: watched, ref: ref),
              data: (data) => _WatchlistWithData(symbols: watched, data: data, ref: ref),
            ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.star_border_rounded, size: 56, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 12),
        const Text('Your watchlist is empty', textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Tap the star on any stock in the Dashboard to add it here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _WatchlistWithData extends StatelessWidget {
  const _WatchlistWithData({required this.symbols, required this.data, required this.ref});

  final Set<String> symbols;
  final DashboardData data;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final allMovers = [...data.gainers, ...data.losers];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: symbols.map((symbol) {
        final match = allMovers.where((m) => m.symbol == symbol);
        final mover = match.isNotEmpty ? match.first : null;
        return _WatchlistTile(symbol: symbol, mover: mover, ref: ref);
      }).toList(),
    );
  }
}

class _WatchlistSymbolsOnly extends StatelessWidget {
  const _WatchlistSymbolsOnly({required this.symbols, required this.ref});

  final Set<String> symbols;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: symbols.map((symbol) => _WatchlistTile(symbol: symbol, mover: null, ref: ref)).toList(),
    );
  }
}

class _WatchlistTile extends StatelessWidget {
  const _WatchlistTile({required this.symbol, required this.mover, required this.ref});

  final String symbol;
  final MoverItem? mover;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final color = mover == null ? Theme.of(context).colorScheme.outline : (mover!.isUp ? AppColors.gain : AppColors.loss);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: StockAvatar(symbol: symbol),
        title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(mover == null ? 'No live data loaded' : 'LTP: ${mover!.ltp.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mover != null)
              Text(
                '${mover!.isUp ? '+' : ''}${mover!.percentChange.toStringAsFixed(2)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            IconButton(
              icon: const Icon(Icons.star_rounded, color: Colors.amber),
              onPressed: () => ref.read(watchlistProvider.notifier).toggle(symbol),
              tooltip: 'Remove from watchlist',
            ),
          ],
        ),
      ),
    );
  }
}
