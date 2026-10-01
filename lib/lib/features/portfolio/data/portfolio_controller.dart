import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _portfolioPrefKey = 'portfolio_holdings';

/// A single position the user has told the app about: "I own 50 shares of
/// NABIL, bought at an average of Rs. 650." This is entered by hand — we
/// have no way to know someone's real brokerage holdings without a login
/// to a broker, which this app deliberately doesn't do.
class Holding {
  const Holding({required this.symbol, required this.quantity, required this.avgCost});

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      symbol: json['symbol'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      avgCost: (json['avgCost'] as num).toDouble(),
    );
  }

  final String symbol;
  final double quantity;
  final double avgCost;

  double get investedValue => quantity * avgCost;

  Map<String, dynamic> toJson() => {'symbol': symbol, 'quantity': quantity, 'avgCost': avgCost};
}

class PortfolioController extends Notifier<List<Holding>> {
  @override
  List<Holding> build() {
    _loadSaved();
    return [];
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_portfolioPrefKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    state = decoded.map((e) => Holding.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((h) => h.toJson()).toList());
    await prefs.setString(_portfolioPrefKey, encoded);
  }

  Future<void> addOrUpdate(Holding holding) async {
    final updated = [...state];
    final existingIndex = updated.indexWhere((h) => h.symbol == holding.symbol);
    if (existingIndex >= 0) {
      updated[existingIndex] = holding;
    } else {
      updated.add(holding);
    }
    state = updated;
    await _save();
  }

  Future<void> remove(String symbol) async {
    state = state.where((h) => h.symbol != symbol).toList();
    await _save();
  }
}

final portfolioProvider = NotifierProvider<PortfolioController, List<Holding>>(
  PortfolioController.new,
);
