import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/work_needed_post_models.dart';
import 'package:connect_app/src/features/work_needed_posts/work_needed_post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workNeededPostControllerProvider =
    NotifierProvider<WorkNeededPostController, WorkNeededPostState>(
      WorkNeededPostController.new,
    );

class WorkNeededPostState {
  const WorkNeededPostState({
    this.posts = const [],
    this.taxonomy = const {},
    this.isLoading = false,
    this.isSaving = false,
    this.isInitialized = false,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final List<WorkNeededPostResult> posts;
  final Map<String, List<CategoryOption>> taxonomy;
  final bool isLoading;
  final bool isSaving;
  final bool isInitialized;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  WorkNeededPostState copyWith({
    List<WorkNeededPostResult>? posts,
    Map<String, List<CategoryOption>>? taxonomy,
    bool? isLoading,
    bool? isSaving,
    bool? isInitialized,
    Object? errorMessage = _unchanged,
    Map<String, String>? fieldErrors,
  }) {
    return WorkNeededPostState(
      posts: posts ?? this.posts,
      taxonomy: taxonomy ?? this.taxonomy,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: identical(errorMessage, _unchanged)
          ? this.errorMessage
          : errorMessage as String?,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

const Object _unchanged = Object();

class WorkNeededPostController extends Notifier<WorkNeededPostState> {
  @override
  WorkNeededPostState build() => const WorkNeededPostState();

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
      final repository = ref.read(workNeededPostRepositoryProvider);
      final results = await Future.wait([
        repository.list(),
        repository.taxonomy('work_category'),
        repository.taxonomy('work_name'),
        repository.taxonomy('product_type'),
      ]);
      state = state.copyWith(
        posts: results[0] as List<WorkNeededPostResult>,
        taxonomy: {
          'work_category': results[1] as List<CategoryOption>,
          'work_name': results[2] as List<CategoryOption>,
          'product_type': results[3] as List<CategoryOption>,
        },
        isLoading: false,
        isInitialized: true,
        errorMessage: null,
      );
    } on ApiFailure catch (error) {
      _setFailure(error, initialized: true);
    } catch (_) {
      _setUnknownFailure(initialized: true);
    }
  }

  Future<WorkNeededPostResult?> createDraft(String idempotencyKey) async {
    if (state.isSaving) {
      return null;
    }
    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      fieldErrors: const {},
    );
    try {
      final post = await ref
          .read(workNeededPostRepositoryProvider)
          .createDraft(idempotencyKey: idempotencyKey);
      _replace(post);
      return post;
    } on ApiFailure catch (error) {
      _setFailure(error);
      return null;
    } catch (_) {
      _setUnknownFailure();
      return null;
    }
  }

  Future<void> refreshPosts() async {
    try {
      final posts = await ref.read(workNeededPostRepositoryProvider).list();
      state = state.copyWith(
        posts: posts,
        isInitialized: true,
        errorMessage: null,
      );
    } on ApiFailure catch (error) {
      _setFailure(error);
    } catch (_) {
      _setUnknownFailure();
    }
  }

  Future<bool> saveAndPublish({
    required String id,
    required WorkNeededPostUpsert fields,
    required bool publish,
  }) async {
    if (state.isSaving) {
      return false;
    }
    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      fieldErrors: const {},
    );
    try {
      final repository = ref.read(workNeededPostRepositoryProvider);
      var post = await repository.update(id, fields);
      if (publish) {
        post = await repository.publish(id);
      }
      _replace(post);
      return true;
    } on ApiFailure catch (error) {
      _setFailure(error);
      return false;
    } catch (_) {
      _setUnknownFailure();
      return false;
    }
  }

  Future<bool> pause(WorkNeededPostResult post) {
    return _mutate(
      () => ref.read(workNeededPostRepositoryProvider).pause(post.id),
    );
  }

  Future<bool> resume(WorkNeededPostResult post) {
    return _mutate(
      () => ref.read(workNeededPostRepositoryProvider).resume(post.id),
    );
  }

  Future<bool> close(WorkNeededPostResult post) {
    return _mutate(
      () => ref.read(workNeededPostRepositoryProvider).close(post.id),
    );
  }

  Future<bool> delete(WorkNeededPostResult post) async {
    if (state.isSaving) {
      return false;
    }
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await ref.read(workNeededPostRepositoryProvider).delete(post.id);
      state = state.copyWith(
        posts: state.posts.where((item) => item.id != post.id).toList(),
        isSaving: false,
        errorMessage: null,
      );
      return true;
    } on ApiFailure catch (error) {
      _setFailure(error);
      return false;
    } catch (_) {
      _setUnknownFailure();
      return false;
    }
  }

  WorkNeededPostResult? find(String id) {
    for (final post in state.posts) {
      if (post.id == id) {
        return post;
      }
    }
    return null;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null, fieldErrors: const {});
  }

  Future<bool> _mutate(Future<WorkNeededPostResult> Function() action) async {
    if (state.isSaving) {
      return false;
    }
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final post = await action();
      _replace(post);
      return true;
    } on ApiFailure catch (error) {
      _setFailure(error);
      return false;
    } catch (_) {
      _setUnknownFailure();
      return false;
    }
  }

  void _replace(WorkNeededPostResult post) {
    final posts = [...state.posts];
    final index = posts.indexWhere((item) => item.id == post.id);
    if (index == -1) {
      posts.insert(0, post);
    } else {
      posts[index] = post;
    }
    state = state.copyWith(
      posts: posts,
      isSaving: false,
      isInitialized: true,
      errorMessage: null,
      fieldErrors: const {},
    );
  }

  void _setFailure(ApiFailure error, {bool? initialized}) {
    state = state.copyWith(
      isLoading: false,
      isSaving: false,
      isInitialized: initialized,
      errorMessage: error.message,
      fieldErrors: error.fieldErrors,
    );
  }

  void _setUnknownFailure({bool? initialized}) {
    state = state.copyWith(
      isLoading: false,
      isSaving: false,
      isInitialized: initialized,
      errorMessage: "Can't access internet",
    );
  }
}
