import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/theme_controller.dart';
import '../dashboard/dashboard_providers.dart';
import '../watchlist/data/watchlist_controller.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final watchlistCount = ref.watch(watchlistProvider).length;

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          RadioListTile<ThemeMode>(
            title: const Text('Follow system'),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).setThemeMode(mode!),
          ),
          const Divider(height: 32),
          const _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('Refresh market data now'),
            subtitle: const Text('Dashboard also auto-refreshes every 60 seconds'),
            onTap: () {
              ref.read(dashboardControllerProvider.notifier).refresh();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_rounded),
            title: const Text('Watchlist'),
            subtitle: Text('$watchlistCount stock${watchlistCount == 1 ? '' : 's'} saved'),
          ),
          const Divider(height: 32),
          const _SectionHeader(title: 'About'),
          const _AboutTile(),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Data source'),
            subtitle: Text(
              'Unofficial NEPSE data API, used for educational and personal, '
              'non-commercial purposes only. Not affiliated with the Nepal '
              'Stock Exchange. Prices may be delayed or occasionally '
              'unavailable, in which case demo data is shown and clearly '
              'labeled.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.pie_chart_outline_rounded),
            title: Text('Portfolio data'),
            subtitle: Text(
              'Holdings are entered manually and stored only on this device. '
              'This app is not connected to any broker or exchange account.',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '...';
        final buildNumber = snapshot.data?.buildNumber ?? '';
        return ListTile(
          leading: const Icon(Icons.trending_up_rounded),
          title: const Text('Bull & Bear'),
          subtitle: Text('Version $version${buildNumber.isNotEmpty ? '+$buildNumber' : ''}'),
        );
      },
    );
  }
}
