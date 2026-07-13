import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/discovery_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return ApiDiscoveryRepository(ref.watch(connectApiProvider));
});

abstract class DiscoveryRepository {
  Future<MarketplaceSearchResponse> search(MarketplaceSearchRequest request);

  Future<PublicProfileDetailResult> profile(
    String profileId, {
    String? sourceType,
    String? sourceId,
  });

  Future<List<CategoryOption>> taxonomy(String categoryType);
}

class ApiDiscoveryRepository implements DiscoveryRepository {
  const ApiDiscoveryRepository(this._api);

  final ConnectApi _api;

  @override
  Future<MarketplaceSearchResponse> search(MarketplaceSearchRequest request) {
    return _api.searchMarketplace(request);
  }

  @override
  Future<PublicProfileDetailResult> profile(
    String profileId, {
    String? sourceType,
    String? sourceId,
  }) {
    return _api.publicProfile(
      profileId,
      sourceType: sourceType,
      sourceId: sourceId,
    );
  }

  @override
  Future<List<CategoryOption>> taxonomy(String categoryType) {
    return _api.categories(categoryType: categoryType);
  }
}
