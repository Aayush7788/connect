import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/discovery_models.dart';
import 'package:connect_app/src/features/discovery/discovery_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final discoveryControllerProvider =
    NotifierProvider<DiscoveryController, DiscoveryState>(
      DiscoveryController.new,
    );

class DiscoveryState {
  const DiscoveryState({
    this.target = 'job_worker',
    this.query = '',
    this.businessMode = 'work_needed_posts',
    this.jobWorkerMode = 'work_cards',
    this.sort = 'best',
    this.verifiedOnly = false,
    this.results = const [],
    this.taxonomy = const {},
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.categoryId,
    this.productTypeId,
    this.locality = '',
    this.minExperienceYears,
    this.maxExperienceYears,
  });

  final String target;
  final String query;
  final String businessMode;
  final String jobWorkerMode;
  final String sort;
  final bool verifiedOnly;
  final List<MarketplaceSearchResult> results;
  final Map<String, List<CategoryOption>> taxonomy;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String? categoryId;
  final String? productTypeId;
  final String locality;
  final int? minExperienceYears;
  final int? maxExperienceYears;

  bool get hasFilters =>
      categoryId != null ||
      productTypeId != null ||
      locality.trim().isNotEmpty ||
      minExperienceYears != null ||
      maxExperienceYears != null ||
      verifiedOnly ||
      sort != 'best';

  DiscoveryState copyWith({
    String? target,
    String? query,
    String? businessMode,
    String? jobWorkerMode,
    String? sort,
    bool? verifiedOnly,
    List<MarketplaceSearchResult>? results,
    Map<String, List<CategoryOption>>? taxonomy,
    bool? isLoading,
    bool? isInitialized,
    Object? errorMessage = _unchanged,
    Object? categoryId = _unchanged,
    Object? productTypeId = _unchanged,
    String? locality,
    Object? minExperienceYears = _unchanged,
    Object? maxExperienceYears = _unchanged,
  }) {
    return DiscoveryState(
      target: target ?? this.target,
      query: query ?? this.query,
      businessMode: businessMode ?? this.businessMode,
      jobWorkerMode: jobWorkerMode ?? this.jobWorkerMode,
      sort: sort ?? this.sort,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      results: results ?? this.results,
      taxonomy: taxonomy ?? this.taxonomy,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: identical(errorMessage, _unchanged)
          ? this.errorMessage
          : errorMessage as String?,
      categoryId: identical(categoryId, _unchanged)
          ? this.categoryId
          : categoryId as String?,
      productTypeId: identical(productTypeId, _unchanged)
          ? this.productTypeId
          : productTypeId as String?,
      locality: locality ?? this.locality,
      minExperienceYears: identical(minExperienceYears, _unchanged)
          ? this.minExperienceYears
          : minExperienceYears as int?,
      maxExperienceYears: identical(maxExperienceYears, _unchanged)
          ? this.maxExperienceYears
          : maxExperienceYears as int?,
    );
  }
}

const Object _unchanged = Object();

class DiscoveryController extends Notifier<DiscoveryState> {
  static const int _maximumCachedSearches = 30;

  int _requestSequence = 0;
  CancelToken? _searchCancelToken;
  final Map<String, List<CategoryOption>> _taxonomyCache = {};
  final Map<String, MarketplaceSearchResponse> _searchCache = {};

  @override
  DiscoveryState build() {
    ref.onDispose(() => _searchCancelToken?.cancel('Controller disposed'));
    return const DiscoveryState();
  }

  Future<void> configure({
    required String target,
    String initialQuery = '',
  }) async {
    state = DiscoveryState(target: target, query: initialQuery);
    await Future.wait([loadTaxonomy(), search()]);
  }

  Future<void> selectTarget(String target) async {
    if (target == state.target) {
      return;
    }
    state = DiscoveryState(target: target, query: state.query);
    await Future.wait([loadTaxonomy(), search()]);
  }

  Future<void> updateQuery(String query) async {
    state = state.copyWith(query: query);
    await search();
  }

  Future<void> setBusinessMode(String mode) async {
    state = state.copyWith(businessMode: mode, categoryId: null);
    await Future.wait([loadTaxonomy(), search()]);
  }

  Future<void> setJobWorkerMode(String mode) async {
    state = state.copyWith(jobWorkerMode: mode, categoryId: null);
    await Future.wait([loadTaxonomy(), search()]);
  }

  Future<void> applyFilters({
    String? categoryId,
    String? productTypeId,
    required String locality,
    int? minExperienceYears,
    int? maxExperienceYears,
    required bool verifiedOnly,
    required String sort,
  }) async {
    state = state.copyWith(
      categoryId: categoryId,
      productTypeId: productTypeId,
      locality: locality,
      minExperienceYears: minExperienceYears,
      maxExperienceYears: maxExperienceYears,
      verifiedOnly: verifiedOnly,
      sort: sort,
    );
    await search();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(
      categoryId: null,
      productTypeId: null,
      locality: '',
      minExperienceYears: null,
      maxExperienceYears: null,
      verifiedOnly: false,
      sort: 'best',
    );
    await search();
  }

  Future<void> loadTaxonomy() async {
    final repository = ref.read(discoveryRepositoryProvider);
    final target = state.target;
    final businessMode = state.businessMode;
    final jobWorkerMode = state.jobWorkerMode;
    final categoryType = switch (state.target) {
      'business' when state.businessMode == 'profiles' => 'business_category',
      'skilled_worker' => 'work_name',
      _ => 'work_category',
    };
    try {
      final types = [categoryType, 'product_type'];
      final missing = types
          .where((type) => !_taxonomyCache.containsKey(type))
          .toList(growable: false);
      final loaded = await Future.wait(missing.map(repository.taxonomy));
      for (var index = 0; index < missing.length; index += 1) {
        _taxonomyCache[missing[index]] = loaded[index];
      }
      if (state.target != target ||
          state.businessMode != businessMode ||
          state.jobWorkerMode != jobWorkerMode) {
        return;
      }
      state = state.copyWith(
        taxonomy: {
          'category': _taxonomyCache[categoryType]!,
          'product_type': _taxonomyCache['product_type']!,
        },
      );
    } on Object {
      state = state.copyWith(taxonomy: const {});
    }
  }

  Future<void> search() async {
    final sequence = ++_requestSequence;
    _searchCancelToken?.cancel('Superseded by a newer search');
    final cancelToken = CancelToken();
    _searchCancelToken = cancelToken;
    final request = MarketplaceSearchRequest(
      target: state.target,
      query: state.query,
      businessMode: state.businessMode,
      jobWorkerMode: state.jobWorkerMode,
      categoryId: state.categoryId,
      productTypeId: state.productTypeId,
      locality: state.locality,
      minExperienceYears: state.target == 'business'
          ? null
          : state.minExperienceYears,
      maxExperienceYears: state.target == 'business'
          ? null
          : state.maxExperienceYears,
      verifiedOnly: state.verifiedOnly,
      sort: state.sort,
    );
    final cacheKey = _cacheKey(request);
    final cached = _searchCache[cacheKey];
    state = state.copyWith(isLoading: true, errorMessage: null);
    if (cached != null) {
      state = state.copyWith(results: cached.items, isInitialized: true);
    }
    try {
      final response = await ref
          .read(discoveryRepositoryProvider)
          .search(request, cancelToken: cancelToken);
      if (sequence != _requestSequence) {
        return;
      }
      if (!_searchCache.containsKey(cacheKey) &&
          _searchCache.length >= _maximumCachedSearches) {
        _searchCache.remove(_searchCache.keys.first);
      }
      _searchCache[cacheKey] = response;
      state = state.copyWith(
        results: response.items,
        isLoading: false,
        isInitialized: true,
        errorMessage: null,
      );
    } on DioException catch (error) {
      if (!CancelToken.isCancel(error) && sequence == _requestSequence) {
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          errorMessage: "Can't access internet",
        );
      }
    } on ApiFailure catch (error) {
      if (sequence == _requestSequence) {
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          errorMessage: error.message,
        );
      }
    } on Object {
      if (sequence == _requestSequence) {
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          errorMessage: "Can't access internet",
        );
      }
    }
  }

  String _cacheKey(MarketplaceSearchRequest request) {
    final values = request.toQueryParameters().entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));
    return values.map((entry) => '${entry.key}=${entry.value}').join('&');
  }
}
