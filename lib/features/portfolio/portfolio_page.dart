import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/stock_avatar.dart';
import '../dashboard/dashboard_providers.dart';
import '../dashboard/model/market_models.dart';
import 'data/portfolio_controller.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdings = ref.watch(portfolioProvider);
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final currency = NumberFormat.compactCurrency(symbol: 'Rs. ');

    // Cross-reference today's movers to get a live price where we can.
    // Symbols not in today's gainers/losers just won't have a live P&L —
    // that's an honest limitation given our data source, not a bug.
    final movers = dashboardAsync.value == null
        ? <MoverItem>[]
        : [...dashboardAsync.value!.gainers, ...dashboardAsync.value!.losers];

    double totalInvested = 0;
    double totalCurrent = 0;
    for (final h in holdings) {
      totalInvested += h.investedValue;
      final match = movers.where((m) => m.symbol == h.symbol);
      final currentPrice = match.isNotEmpty ? match.first.ltp : h.avgCost;
      totalCurrent += currentPrice * h.quantity;
    }
    final totalPnl = totalCurrent - totalInvested;
    final pnlColor = totalPnl >= 0 ? AppColors.gain : AppColors.loss;

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHoldingSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: holdings.isEmpty
          ? const _EmptyPortfolio()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _SummaryLine(label: 'Invested', value: currency.format(totalInvested)),
                        _SummaryLine(label: 'Current value', value: currency.format(totalCurrent)),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Overall P&L', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${totalPnl >= 0 ? '+' : ''}${currency.format(totalPnl)}',
                              style: TextStyle(color: pnlColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...holdings.map((h) => _HoldingTile(holding: h, movers: movers)),
                const SizedBox(height: 80), // room for the FAB
              ],
            ),
    );
  }

  void _showAddHoldingSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddHoldingSheet(),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.pie_chart_outline_rounded, size: 56, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 12),
        const Text('No holdings yet', textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Tap the + button to add a stock you own and track its gain/loss.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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

class _HoldingTile extends ConsumerWidget {
  const _HoldingTile({required this.holding, required this.movers});

  final Holding holding;
  final List<MoverItem> movers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = movers.where((m) => m.symbol == holding.symbol);
    final hasLivePrice = match.isNotEmpty;
    final currentPrice = hasLivePrice ? match.first.ltp : holding.avgCost;
    final pnl = (currentPrice - holding.avgCost) * holding.quantity;
    final pnlPercent = holding.avgCost == 0 ? 0 : (currentPrice - holding.avgCost) / holding.avgCost * 100;
    final color = pnl >= 0 ? AppColors.gain : AppColors.loss;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: StockAvatar(symbol: holding.symbol),
        title: Text(holding.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${holding.quantity.toStringAsFixed(0)} shares @ avg Rs. ${holding.avgCost.toStringAsFixed(2)}'
          '${hasLivePrice ? '' : ' · no live price today'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${pnl >= 0 ? '+' : ''}Rs. ${pnl.toStringAsFixed(0)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              onPressed: () => ref.read(portfolioProvider.notifier).remove(holding.symbol),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddHoldingSheet extends ConsumerStatefulWidget {
  const _AddHoldingSheet();

  @override
  ConsumerState<_AddHoldingSheet> createState() => _AddHoldingSheetState();
}

class _AddHoldingSheetState extends ConsumerState<_AddHoldingSheet> {
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _avgCostController = TextEditingController();

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _avgCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add holding', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _symbolController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Symbol (e.g. NABIL)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _avgCostController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Average cost per share (Rs.)'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Add to Portfolio')),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final symbol = _symbolController.text.trim().toUpperCase();
    final quantity = double.tryParse(_quantityController.text.trim());
    final avgCost = double.tryParse(_avgCostController.text.trim());

    if (symbol.isEmpty || quantity == null || avgCost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields with valid numbers')),
      );
      return;
    }

    ref.read(portfolioProvider.notifier).addOrUpdate(
          Holding(symbol: symbol, quantity: quantity, avgCost: avgCost),
        );
    Navigator.of(context).pop();
  }
}
