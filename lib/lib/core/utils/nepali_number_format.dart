/// Nepal/India use a different large-number naming system than the West's
/// thousand/million/billion. This formats numbers the way a Nepali market
/// app actually should:
///
///   1,00,000            = 1 Lakh   (10^5)
///   1,00,00,000         = 1 Crore  (10^7)
///   1,00,00,00,000      = 1 Arab   (10^9)
///   1,00,00,00,00,000   = 1 Kharab (10^11)
///
/// Example: a turnover of 4,489,236,458 becomes "4.49 Arab" instead of the
/// Western-style "4.49B".
class NepaliNumberFormat {
  NepaliNumberFormat._();

  static const _kharab = 1e11;
  static const _arab = 1e9;
  static const _crore = 1e7;
  static const _lakh = 1e5;

  /// Compact form: "4.49 Arab", "12.3 Lakh", "850" (below 1 lakh, shown plain).
  static String compact(num value) {
    final absValue = value.abs();
    final sign = value < 0 ? '-' : '';

    if (absValue >= _kharab) return '$sign${(absValue / _kharab).toStringAsFixed(2)} Kharab';
    if (absValue >= _arab) return '$sign${(absValue / _arab).toStringAsFixed(2)} Arab';
    if (absValue >= _crore) return '$sign${(absValue / _crore).toStringAsFixed(2)} Crore';
    if (absValue >= _lakh) return '$sign${(absValue / _lakh).toStringAsFixed(2)} Lakh';
    // Below 1 lakh, plain comma-grouped is clearer than a fraction of a lakh.
    return '$sign${absValue.toStringAsFixed(0)}';
  }

  /// Same as [compact] but with a "Rs. " currency prefix.
  static String compactCurrency(num value) => 'Rs. ${compact(value)}';
}
