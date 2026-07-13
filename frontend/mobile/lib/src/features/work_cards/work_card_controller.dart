import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/work_card_models.dart';
import 'package:connect_app/src/features/profile/profile_controller.dart';
import 'package:connect_app/src/features/work_cards/work_card_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workCardControllerProvider =
    NotifierProvider<WorkCardController, WorkCardState>(WorkCardController.new);

final workCardProfileRefreshProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(profileControllerProvider.notifier).load(force: true);
});

class WorkCardState {
  const WorkCardState({
    this.cards = const [],
    this.taxonomy = const {},
    this.isLoading = false,
    this.isSaving = false,
    this.isInitialized = false,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final List<WorkCardResult> cards;
  final Map<String, List<CategoryOption>> taxonomy;
  final bool isLoading;
  final bool isSaving;
  final bool isInitialized;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  WorkCardState copyWith({
    List<WorkCardResult>? cards,
    Map<String, List<CategoryOption>>? taxonomy,
    bool? isLoading,
    bool? isSaving,
    bool? isInitialized,
    Object? errorMessage = _unchanged,
    Map<String, String>? fieldErrors,
  }) {
    return WorkCardState(
      cards: cards ?? this.cards,
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

class WorkCardController extends Notifier<WorkCardState> {
  @override
  WorkCardState build() => const WorkCardState();

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
      final repository = ref.read(workCardRepositoryProvider);
      final results = await Future.wait([
        repository.list(),
        repository.taxonomy('work_category'),
        repository.taxonomy('work_name'),
        repository.taxonomy('product_type'),
      ]);
      state = state.copyWith(
        cards: results[0] as List<WorkCardResult>,
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

  Future<WorkCardResult?> createDraft(String idempotencyKey) async {
    if (state.isSaving) {
      return null;
    }
    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      fieldErrors: const {},
    );
    try {
      final card = await ref
          .read(workCardRepositoryProvider)
          .createDraft(idempotencyKey: idempotencyKey);
      _replace(card);
      return card;
    } on ApiFailure catch (error) {
      _setFailure(error);
      return null;
    } catch (_) {
      _setUnknownFailure();
      return null;
    }
  }

  Future<void> refreshCards() async {
    try {
      final cards = await ref.read(workCardRepositoryProvider).list();
      state = state.copyWith(
        cards: cards,
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
    required WorkCardUpsert fields,
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
      final repository = ref.read(workCardRepositoryProvider);
      var card = await repository.update(id, fields);
      if (publish) {
        card = await repository.publish(id);
      }
      _replace(card);
      await ref.read(workCardProfileRefreshProvider)();
      return true;
    } on ApiFailure catch (error) {
      _setFailure(error);
      return false;
    } catch (_) {
      _setUnknownFailure();
      return false;
    }
  }

  Future<bool> setHidden(WorkCardResult card, bool hidden) async {
    return _mutate(() {
      final repository = ref.read(workCardRepositoryProvider);
      return hidden ? repository.hide(card.id) : repository.show(card.id);
    });
  }

  Future<bool> delete(WorkCardResult card) async {
    if (state.isSaving) {
      return false;
    }
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await ref.read(workCardRepositoryProvider).delete(card.id);
      state = state.copyWith(
        cards: state.cards.where((item) => item.id != card.id).toList(),
        isSaving: false,
        errorMessage: null,
      );
      await ref.read(workCardProfileRefreshProvider)();
      return true;
    } on ApiFailure catch (error) {
      _setFailure(error);
      return false;
    } catch (_) {
      _setUnknownFailure();
      return false;
    }
  }

  WorkCardResult? find(String id) {
    for (final card in state.cards) {
      if (card.id == id) {
        return card;
      }
    }
    return null;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null, fieldErrors: const {});
  }

  Future<bool> _mutate(Future<WorkCardResult> Function() action) async {
    if (state.isSaving) {
      return false;
    }
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final card = await action();
      _replace(card);
      await ref.read(workCardProfileRefreshProvider)();
      return true;
    } on ApiFailure catch (error) {
      _setFailure(error);
      return false;
    } catch (_) {
      _setUnknownFailure();
      return false;
    }
  }

  void _replace(WorkCardResult card) {
    final cards = [...state.cards];
    final index = cards.indexWhere((item) => item.id == card.id);
    if (index == -1) {
      cards.insert(0, card);
    } else {
      cards[index] = card;
    }
    state = state.copyWith(
      cards: cards,
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
