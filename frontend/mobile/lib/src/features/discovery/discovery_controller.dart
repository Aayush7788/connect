import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/discovery_models.dart';
import 'package:connect_app/src/features/discovery/discovery_repository.dart';
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
  int _requestSequence = 0;

  @override
  DiscoveryState build() => const DiscoveryState();

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
    final categoryType = switch (state.target) {
      'business' when state.businessMode == 'profiles' => 'business_category',
      'skilled_worker' => 'work_name',
      _ => 'work_category',
    };
    try {
      final values = await Future.wait([
        repository.taxonomy(categoryType),
        repository.taxonomy('product_type'),
      ]);
      if (state.target != target || state.businessMode != businessMode) {
        return;
      }
      state = state.copyWith(
        taxonomy: {'category': values[0], 'product_type': values[1]},
      );
    } on Object {
      state = state.copyWith(taxonomy: const {});
    }
  }

  Future<void> search() async {
    final sequence = ++_requestSequence;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await ref
          .read(discoveryRepositoryProvider)
          .search(
            MarketplaceSearchRequest(
              target: state.target,
              query: state.query,
              businessMode: state.businessMode,
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
            ),
          );
      if (sequence != _requestSequence) {
        return;
      }
      state = state.copyWith(
        results: response.items,
        isLoading: false,
        isInitialized: true,
        errorMessage: null,
      );
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
}
