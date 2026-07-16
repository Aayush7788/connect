import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/features/auth/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

class ProfileState {
  const ProfileState({
    this.profile,
    this.categories = const {},
    this.isLoading = false,
    this.isSaving = false,
    this.isInitialized = false,
    this.errorMessage,
    this.fieldErrors = const {},
    this.missingFields = const [],
  });

  final OwnerProfileResult? profile;
  final Map<String, List<CategoryOption>> categories;
  final bool isLoading;
  final bool isSaving;
  final bool isInitialized;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final List<String> missingFields;

  ProfileState copyWith({
    OwnerProfileResult? profile,
    Map<String, List<CategoryOption>>? categories,
    bool? isLoading,
    bool? isSaving,
    bool? isInitialized,
    Object? errorMessage = _unchanged,
    Map<String, String>? fieldErrors,
    List<String>? missingFields,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: identical(errorMessage, _unchanged)
          ? this.errorMessage
          : errorMessage as String?,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      missingFields: missingFields ?? this.missingFields,
    );
  }
}

const Object _unchanged = Object();

class ProfileController extends Notifier<ProfileState> {
  final Map<String, List<CategoryOption>> _taxonomyCache = {};

  @override
  ProfileState build() => const ProfileState();

  Future<void> load({bool force = false}) async {
    if (state.isLoading || (state.isInitialized && !force)) {
      return;
    }
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      fieldErrors: const {},
    );
    try {
      final api = ref.read(connectApiProvider);
      final knownRole = ref.read(authControllerProvider).me?.profile?.role;
      final profileFuture = api.ownerProfile();
      final knownCategoriesFuture = _categoriesForRole(api, knownRole);
      final profile = await profileFuture;
      final categories = knownRole == profile.profile.role
          ? await knownCategoriesFuture
          : await _categoriesForRole(api, profile.profile.role);
      _setProfile(profile, categories: categories);
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: "Can't access internet",
      );
    }
  }

  Future<Map<String, List<CategoryOption>>> _categoriesForRole(
    ConnectApi api,
    String? role,
  ) async {
    final categoryTypes = switch (role) {
      'business' => const ['business_category', 'product_type'],
      'skilled_worker' => const ['work_name'],
      _ => const <String>[],
    };
    final missingTypes = categoryTypes
        .where((type) => !_taxonomyCache.containsKey(type))
        .toList(growable: false);
    final loaded = await Future.wait(
      missingTypes.map((type) => api.categories(categoryType: type)),
    );
    for (var index = 0; index < missingTypes.length; index += 1) {
      _taxonomyCache[missingTypes[index]] = loaded[index];
    }
    return {for (final type in categoryTypes) type: _taxonomyCache[type]!};
  }

  Future<bool> save(Map<String, dynamic> fields) async {
    if (fields.isEmpty || state.isSaving) {
      return fields.isEmpty;
    }
    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      fieldErrors: const {},
      missingFields: const [],
    );
    try {
      final profile = await ref
          .read(connectApiProvider)
          .updateOwnerProfile(fields);
      _setProfile(profile);
      return true;
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.message,
        fieldErrors: error.fieldErrors,
        missingFields: error.missingFields,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: "Can't access internet",
      );
      return false;
    }
  }

  Future<bool> complete() async {
    if (state.isSaving) {
      return false;
    }
    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      fieldErrors: const {},
      missingFields: const [],
    );
    try {
      final profile = await ref.read(connectApiProvider).completeOwnerProfile();
      _setProfile(profile);
      return true;
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.message,
        fieldErrors: error.fieldErrors,
        missingFields: error.missingFields,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: "Can't access internet",
      );
      return false;
    }
  }

  Future<bool> setHidden(bool hidden) async {
    if (state.isSaving) {
      return false;
    }
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final api = ref.read(connectApiProvider);
      final profile = hidden
          ? await api.hideOwnerProfile()
          : await api.showOwnerProfile();
      _setProfile(profile);
      return true;
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.message,
        missingFields: error.missingFields,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: "Can't access internet",
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(
      errorMessage: null,
      fieldErrors: const {},
      missingFields: const [],
    );
  }

  void _setProfile(
    OwnerProfileResult profile, {
    Map<String, List<CategoryOption>>? categories,
  }) {
    ref
        .read(authControllerProvider.notifier)
        .updateProfileSummary(profile.profile);
    state = state.copyWith(
      profile: profile,
      categories: categories,
      isLoading: false,
      isSaving: false,
      isInitialized: true,
      errorMessage: null,
      fieldErrors: const {},
      missingFields: const [],
    );
  }
}
