import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dashboard/model/market_models.dart';
import '../../core/widgets/stock_avatar.dart';
import '../watchlist/data/watchlist_controller.dart';
import 'market_providers.dart';

class MarketPage extends ConsumerWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredCompanyListProvider);
    final companiesAsync = ref.watch(companyListProvider);

    // Build the sector chip list from whatever sectors actually appear in
    // the data, so this never goes stale if the company list changes.
    final sectors = companiesAsync.value?.map((c) => c.sector).toSet().toList() ?? [];
    sectors.sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by symbol or company name',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (value) => ref.read(marketSearchQueryProvider.notifier).state = value,
            ),
          ),
          if (sectors.isNotEmpty) _SectorChips(sectors: sectors),
          const SizedBox(height: 4),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Could not load companies: $error')),
              data: (companies) {
                if (companies.isEmpty) {
                  return const Center(child: Text('No matching companies'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: companies.length,
                  itemBuilder: (context, i) => _CompanyTile(company: companies[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectorChips extends ConsumerWidget {
  const _SectorChips({required this.sectors});

  final List<String> sectors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(marketSectorFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _SectorChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => ref.read(marketSectorFilterProvider.notifier).state = null,
          ),
          ...sectors.map((sector) => _SectorChip(
                label: sector,
                isSelected: selected == sector,
                onTap: () => ref.read(marketSectorFilterProvider.notifier).state = sector,
              )),
        ],
      ),
    );
  }
}

class _SectorChip extends StatelessWidget {
  const _SectorChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _CompanyTile extends ConsumerWidget {
  const _CompanyTile({required this.company});

  final CompanyListItem company;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWatched = ref.watch(watchlistProvider).contains(company.symbol);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: StockAvatar(symbol: company.symbol),
        title: Text(company.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${company.companyName}\n${company.sector}'),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
            isWatched ? Icons.star_rounded : Icons.star_border_rounded,
            color: isWatched ? Colors.amber : Theme.of(context).colorScheme.outline,
          ),
          onPressed: () => ref.read(watchlistProvider.notifier).toggle(company.symbol),
        ),
      ),
    );
  }
}
