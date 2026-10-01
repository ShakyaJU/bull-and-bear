import 'package:flutter/material.dart';

/// A colored circle showing a stock's initials, since there's no reliable
/// or legally clean source of real company logos for NEPSE-listed stocks.
/// The color is deterministically derived from the symbol's characters,
/// so "NABIL" always gets the same color everywhere in the app, every
/// time — it just LOOKS random, it isn't actually.
///
/// This is the same fallback pattern apps like Slack or Google Contacts
/// use for a person/entity with no uploaded photo.
class StockAvatar extends StatelessWidget {
  const StockAvatar({super.key, required this.symbol, this.size = 40});

  final String symbol;
  final double size;

  static const _palette = [
    Color(0xFF1B5E20), Color(0xFF0D47A1), Color(0xFF4A148C),
    Color(0xFFB71C1C), Color(0xFFE65100), Color(0xFF004D40),
    Color(0xFF880E4F), Color(0xFF1A237E), Color(0xFF33691E),
    Color(0xFF3E2723), Color(0xFF006064), Color(0xFF827717),
  ];

  Color _colorFor(String symbol) {
    // A simple, stable hash: sum of character codes, then mod into the
    // palette. Same input always produces the same output — that's the
    // whole point (no randomness, no server call, no flicker on rebuild).
    final sum = symbol.codeUnits.fold<int>(0, (acc, c) => acc + c);
    return _palette[sum % _palette.length];
  }

  String _initialsFor(String symbol) {
    final letters = symbol.replaceAll(RegExp('[^A-Za-z]'), '');
    if (letters.isEmpty) return '?';
    return letters.length == 1 ? letters.toUpperCase() : letters.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _colorFor(symbol),
      child: Text(
        _initialsFor(symbol),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}
