import '../model/market_models.dart';

/// A fake version of MarketRepository that returns made-up data instantly,
/// with no network call at all. This lets you keep building and testing
/// the UI even when the free hosted API is down (which its own docs warn
/// can happen randomly).
///
/// This is also a real technique used in professional apps — it's called a
/// "fake" or "stub" implementation, and is genuinely useful for previews,
/// tests, and exactly this situation: an unreliable third-party dependency.
class MockMarketRepository {
  Future<MarketSummary> getSummary() async {
    await Future.delayed(const Duration(milliseconds: 400)); // pretend it's loading
    return const MarketSummary(
      totalTurnover: 4489236458.2,
      totalTradedShares: 12540423,
      totalTransactions: 85879,
      totalScripsTraded: 242,
    );
  }

  Future<NepseIndexData> getNepseIndex() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const NepseIndexData(
      currentValue: 2145.67,
      pointChange: 12.34,
      percentChange: 0.58,
    );
  }

  Future<List<MoverItem>> getTopGainers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      MoverItem(symbol: 'NABIL', ltp: 685.0, percentChange: 4.2),
      MoverItem(symbol: 'NICA', ltp: 412.5, percentChange: 3.9),
      MoverItem(symbol: 'HIDCL', ltp: 210.0, percentChange: 3.1),
      MoverItem(symbol: 'UPPER', ltp: 305.2, percentChange: 2.8),
      MoverItem(symbol: 'CHCL', ltp: 158.0, percentChange: 2.4),
    ];
  }

  Future<List<MoverItem>> getTopLosers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      MoverItem(symbol: 'API', ltp: 320.0, percentChange: -3.6),
      MoverItem(symbol: 'GBIME', ltp: 245.5, percentChange: -2.9),
      MoverItem(symbol: 'SHINE', ltp: 190.0, percentChange: -2.5),
      MoverItem(symbol: 'PRVU', ltp: 275.0, percentChange: -2.1),
      MoverItem(symbol: 'SBI', ltp: 410.0, percentChange: -1.8),
    ];
  }

  Future<List<CompanyListItem>> getCompanyList() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      CompanyListItem(symbol: 'NABIL', companyName: 'Nabil Bank Limited', sector: 'Commercial Banks'),
      CompanyListItem(symbol: 'NICA', companyName: 'NIC Asia Bank Limited', sector: 'Commercial Banks'),
      CompanyListItem(symbol: 'GBIME', companyName: 'Global IME Bank Limited', sector: 'Commercial Banks'),
      CompanyListItem(symbol: 'HIDCL', companyName: 'Hydroelectricity Investment and Development Company', sector: 'Hydropower'),
      CompanyListItem(symbol: 'UPPER', companyName: 'Upper Tamakoshi Hydropower', sector: 'Hydropower'),
      CompanyListItem(symbol: 'CHCL', companyName: 'Chilime Hydropower Company', sector: 'Hydropower'),
      CompanyListItem(symbol: 'API', companyName: 'Api Power Company', sector: 'Hydropower'),
      CompanyListItem(symbol: 'SHINE', companyName: 'Shine Resunga Development Bank', sector: 'Development Banks'),
      CompanyListItem(symbol: 'PRVU', companyName: 'Prabhu Bank Limited', sector: 'Commercial Banks'),
      CompanyListItem(symbol: 'SBI', companyName: 'Nepal SBI Bank Limited', sector: 'Commercial Banks'),
    ];
  }
}
