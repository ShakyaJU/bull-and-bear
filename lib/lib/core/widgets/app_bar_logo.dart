import 'package:flutter/material.dart';

/// A small version of the app's logo mark, used as a leading icon on every
/// top-level tab's AppBar for consistent branding. Uses the transparent-
/// background icon (not the flat splash version) so it sits cleanly on
/// the app bar's background color in both light and dark mode.
class AppBarLogo extends StatelessWidget {
  const AppBarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset('assets/icon/icon.png'),
    );
  }
}
