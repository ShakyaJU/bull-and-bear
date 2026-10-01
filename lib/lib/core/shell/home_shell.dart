import 'package:flutter/material.dart';

import '../../features/dashboard/dashboard_page.dart';
import '../../features/market/market_page.dart';
import '../../features/more/more_page.dart';
import '../../features/portfolio/portfolio_page.dart';
import '../../features/watchlist/watchlist_page.dart';

/// The persistent bottom navigation shell. IndexedStack keeps all 5 tabs
/// alive at once, so switching between them preserves scroll position,
/// search text, and loaded data instead of rebuilding from scratch.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  static const _pages = [
    DashboardPage(),
    WatchlistPage(),
    MarketPage(),
    PortfolioPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.star_border_rounded), selectedIcon: Icon(Icons.star_rounded), label: 'Watchlist'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline_rounded), selectedIcon: Icon(Icons.pie_chart_rounded), label: 'Portfolio'),
          NavigationDestination(icon: Icon(Icons.more_horiz_rounded), selectedIcon: Icon(Icons.more_horiz_rounded), label: 'More'),
        ],
      ),
    );
  }
}
