import '../../../core/api/api_client.dart';
import '../model/market_models.dart';

/// This is the "Repository" in our MVVM + Repository pattern. Its ONE job:
/// know how to fetch market data and hand back clean, typed Dart objects.
/// The screen/view-model above it never sees raw JSON or a Dio response —
/// just MarketSummary, NepseIndexData, and List<MoverItem>.
///
/// Later, if you want to add caching (e.g. "show yesterday's data instantly,
/// then refresh in the background"), this is the ONLY file you'd touch —
/// the UI code doesn't need to know or care.
class MarketRepository {
  MarketRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<MarketSummary> getSummary() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>('/Summary');
    return MarketSummary.fromJson(response.data!);
  }

  Future<NepseIndexData> getNepseIndex() async {
    final response = await _apiClient.dio.get<dynamic>('/NepseIndex');
    final data = response.data;
    // The real response shape here is unconfirmed — it might be a single
    // object, or a list with the main index as the first item. We handle
    // both so a small surprise doesn't crash the app.
    if (data is List && data.isNotEmpty) {
      return NepseIndexData.fromJson(data.first as Map<String, dynamic>);
    }
    return NepseIndexData.fromJson(data as Map<String, dynamic>);
  }

  Future<List<MoverItem>> getTopGainers() async {
    final response = await _apiClient.dio.get<List<dynamic>>('/TopGainers');
    return response.data!
        .map((e) => MoverItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MoverItem>> getTopLosers() async {
    final response = await _apiClient.dio.get<List<dynamic>>('/TopLosers');
    return response.data!
        .map((e) => MoverItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CompanyListItem>> getCompanyList() async {
    final response = await _apiClient.dio.get<List<dynamic>>('/CompanyList');
    return response.data!
        .map((e) => CompanyListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
