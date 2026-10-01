/// Plain data classes describing the shapes of data our screens need.
/// Keeping these separate from the UI means the UI never has to think
/// about raw JSON — it just uses nice typed objects like `summary.turnover`.

/// Maps to the `/Summary` endpoint, which we've confirmed returns exactly:
/// { "Total Turnover Rs:": ..., "Total Traded Shares": ..., "Total Transactions": ..., "Total Scrips Traded": ... }
class MarketSummary {
  const MarketSummary({
    required this.totalTurnover,
    required this.totalTradedShares,
    required this.totalTransactions,
    required this.totalScripsTraded,
  });

  factory MarketSummary.fromJson(Map<String, dynamic> json) {
    return MarketSummary(
      // Note the odd key name with a colon in it — that's really what the
      // API returns, so we have to match it exactly, including the colon.
      totalTurnover: (json['Total Turnover Rs:'] as num?)?.toDouble() ?? 0,
      totalTradedShares: (json['Total Traded Shares'] as num?)?.toInt() ?? 0,
      totalTransactions: (json['Total Transactions'] as num?)?.toInt() ?? 0,
      totalScripsTraded: (json['Total Scrips Traded'] as num?)?.toInt() ?? 0,
    );
  }

  final double totalTurnover;
  final int totalTradedShares;
  final int totalTransactions;
  final int totalScripsTraded;
}

/// Maps to `/NepseIndex`. The exact field names for this endpoint aren't
/// published anywhere, so this is a best-effort guess with a few common
/// alternate key names checked. If it doesn't parse right when you run it,
/// print(response.data) in market_repository.dart to see the REAL shape,
/// then fix the key names below to match. This is completely normal when
/// working with undocumented APIs — nobody gets it right on the first try.
class NepseIndexData {
  const NepseIndexData({
    required this.currentValue,
    required this.pointChange,
    required this.percentChange,
  });

  factory NepseIndexData.fromJson(Map<String, dynamic> json) {
    return NepseIndexData(
      currentValue: _firstNum(json, ['currentValue', 'current', 'close', 'index']),
      pointChange: _firstNum(json, ['pointChange', 'change', 'netChange']),
      percentChange: _firstNum(json, ['percentChange', 'perChange', 'changePercent']),
    );
  }

  final double currentValue;
  final double pointChange;
  final double percentChange;

  bool get isUp => pointChange >= 0;
}

/// Maps to one entry from `/TopGainers` or `/TopLosers`. Same caveat as
/// above — field names are a best guess, verify against the real response.
class MoverItem {
  const MoverItem({
    required this.symbol,
    required this.ltp,
    required this.percentChange,
  });

  factory MoverItem.fromJson(Map<String, dynamic> json) {
    return MoverItem(
      symbol: (json['symbol'] ?? json['Symbol'] ?? '') as String,
      ltp: _firstNum(json, ['ltp', 'LTP', 'lastTradedPrice', 'close']),
      percentChange: _firstNum(json, ['percentChange', 'perChange', 'pointChangePercent']),
    );
  }

  final String symbol;
  final double ltp;
  final double percentChange;

  bool get isUp => percentChange >= 0;
}

/// Small helper: tries several possible key names in order and returns the
/// first one that's actually present, as a double. Returns 0 if none match.
double _firstNum(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
  }
  return 0;
}

String _firstStr(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return '';
}

/// Maps to one entry from `/CompanyList`. Powers the Market tab's full
/// searchable company directory. Field names are again a best-effort
/// guess — verify against the real response and adjust if needed.
class CompanyListItem {
  const CompanyListItem({
    required this.symbol,
    required this.companyName,
    required this.sector,
  });

  factory CompanyListItem.fromJson(Map<String, dynamic> json) {
    return CompanyListItem(
      symbol: _firstStr(json, ['symbol', 'Symbol']),
      companyName: _firstStr(json, ['companyName', 'securityName', 'name']),
      sector: _firstStr(json, ['sector', 'sectorName', 'group']).isEmpty
          ? 'Uncategorized'
          : _firstStr(json, ['sector', 'sectorName', 'group']),
    );
  }

  final String symbol;
  final String companyName;
  final String sector;
}
