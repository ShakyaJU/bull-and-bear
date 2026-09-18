import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/network/network_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/stock_avatar.dart';
import '../watchlist/data/watchlist_controller.dart';
import 'dashboard_providers.dart';
import 'model/market_models.dart';

/// ConsumerStatefulWidget (not just ConsumerWidget) because this screen
/// needs a Timer for auto-refresh, and Timers need a State object to live
/// in and be cleaned up properly when the widget goes away.
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Every 60 seconds, quietly try to get fresher data. This is what
    // makes the numbers actually feel "live" instead of static — without
    // this, data would only ever update when the user manually pulls to
    // refresh.
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      ref.read(dashboardControllerProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final isOffline = isOnlineAsync.value == false;

    return Scaffold(
      appBar: AppBar(title: const Text('Bull & Bear')),
      body: Column(
        children: [
          if (isOffline) const _OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
              child: dashboardAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorView(error: error),
                data: (data) => _DashboardContent(data: data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade800,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text('No internet connection', style: TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.lightTextSecondary),
        const SizedBox(height: 12),
        const Text('Could not load market data', textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text('$error', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(height: 8),
        const Text('Pull down to try again', textAlign: TextAlign.center),
      ],
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _FreshnessBadge(isLive: data.isLive, lastUpdated: data.lastUpdated),
        const SizedBox(height: 12),
        _IndexCard(index: data.index),
        const SizedBox(height: 16),
        _SummaryCard(summary: data.summary),
        const SizedBox(height: 24),
        Text('Top Gainers', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        ...data.gainers.take(5).map((m) => _MoverTile(item: m)),
        const SizedBox(height: 24),
        Text('Top Losers', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        ...data.losers.take(5).map((m) => _MoverTile(item: m)),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// This is the honesty layer: tells the user in plain terms whether
/// they're looking at real market data or a demo fallback, and exactly
/// how old it is. Industry apps almost always show something like this —
/// silently mixing real and fake data erodes trust fast.
class _FreshnessBadge extends StatelessWidget {
  const _FreshnessBadge({required this.isLive, required this.lastUpdated});

  final bool isLive;
  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat('h:mm a').format(lastUpdated);
    final color = isLive ? AppColors.gain : Colors.orange.shade700;
    final label = isLive ? 'Live · updated $timeLabel' : 'Demo data · live feed unavailable';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isLive ? Icons.circle : Icons.info_outline_rounded, size: 10, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _IndexCard extends StatelessWidget {
  const _IndexCard({required this.index});

  final NepseIndexData index;

  @override
  Widget build(BuildContext context) {
    final color = index.isUp ? AppColors.gain : AppColors.loss;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEPSE Index', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  index.currentValue.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Icon(index.isUp ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${index.pointChange.toStringAsFixed(2)} (${index.percentChange.toStringAsFixed(2)}%)',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final MarketSummary summary;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactCurrency(symbol: 'Rs. ');
    final numberFormat = NumberFormat.compact();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(label: 'Turnover', value: currencyFormat.format(summary.totalTurnover)),
            _SummaryRow(label: 'Shares Traded', value: numberFormat.format(summary.totalTradedShares)),
            _SummaryRow(label: 'Transactions', value: numberFormat.format(summary.totalTransactions)),
            _SummaryRow(label: 'Scrips Traded', value: '${summary.totalScripsTraded}'),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MoverTile extends ConsumerWidget {
  const _MoverTile({required this.item});

  final MoverItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = item.isUp ? AppColors.gain : AppColors.loss;
    final isWatched = ref.watch(watchlistProvider).contains(item.symbol);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: StockAvatar(symbol: item.symbol),
        title: Text(item.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('LTP: ${item.ltp.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${item.isUp ? '+' : ''}${item.percentChange.toStringAsFixed(2)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(
                isWatched ? Icons.star_rounded : Icons.star_border_rounded,
                color: isWatched ? Colors.amber : Theme.of(context).colorScheme.outline,
              ),
              onPressed: () => ref.read(watchlistProvider.notifier).toggle(item.symbol),
              tooltip: isWatched ? 'Remove from watchlist' : 'Add to watchlist',
            ),
          ],
        ),
      ),
    );
  }
}
