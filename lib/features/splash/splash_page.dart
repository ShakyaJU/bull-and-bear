import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// The very first screen. Its only job is to show a brand moment for a
/// beat, then hand off to the real app. Later you could use this screen
/// to do startup work (checking for an app update, loading cached data)
/// before navigating onward.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Wait a moment, then move to the dashboard. In a real app you might
    // wait for "is there an update available?" or "is the cache warm?"
    // instead of a fixed delay.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up_rounded, color: Colors.white, size: 72),
            SizedBox(height: 16),
            Text(
              'Bull & Bear',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Nepal Stock Market, at a glance',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
