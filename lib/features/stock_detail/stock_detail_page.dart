import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/stock_avatar.dart';
import '../portfolio/portfolio_page.dart' show showAddHoldingSheetFor;
import '../watchlist/data/watchlist_controller.dart';

/// A detail screen for a single stock. Reachable by tapping any stock tile
/// anywhere in the app (Dashboard movers, Market list, Watchlist). Shows
/// what we honestly have — current price, change, sector, if known — and
/// gives quick actions (watchlist, add to portfolio) rather than every
/// tile duplicating those controls inline.
class StockDetailPage extends ConsumerWidget {
  const StockDetailPage({
    super.key,
    required this.symbol,
    this.companyName,
    this.sector,
    this.ltp,
    this.percentChange,
  });

  final String symbol;
  final String? companyName;
  final String? sector;
  final double? ltp;
  final double? percentChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWatched = ref.watch(watchlistProvider).contains(symbol);
    final hasPriceData = ltp != null && percentChange != null;
    final isUp = (percentChange ?? 0) >= 0;
    final changeColor = isUp ? AppColors.gain : AppColors.loss;

    return Scaffold(
      appBar: AppBar(title: Text(symbol)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              StockAvatar(symbol: symbol, size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(symbol, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    if (companyName != null && companyName!.isNotEmpty)
                      Text(companyName!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (hasPriceData)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LTP', style: Theme.of(context).textTheme.bodySmall),
                        Text(ltp!.toStringAsFixed(2), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, color: changeColor, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${percentChange!.toStringAsFixed(2)}%',
                          style: TextStyle(color: changeColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text("No live price available for this stock in today's data."),
                    ),
                  ],
                ),
              ),
            ),
          if (sector != null && sector!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Sector'),
                subtitle: Text(sector!),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => ref.read(watchlistProvider.notifier).toggle(symbol),
            icon: Icon(isWatched ? Icons.star_rounded : Icons.star_border_rounded),
            label: Text(isWatched ? 'Remove from Watchlist' : 'Add to Watchlist'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => showAddHoldingSheetFor(context, symbol),
            icon: const Icon(Icons.pie_chart_outline_rounded),
            label: const Text('Add to Portfolio'),
          ),
        ],
      ),
    );
  }
}
