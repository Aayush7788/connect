import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/features/profile/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final verificationControllerProvider =
    NotifierProvider<VerificationController, VerificationState>(
      VerificationController.new,
    );

class VerificationState {
  const VerificationState({
    this.summary,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final VerificationSummaryResult? summary;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  VerificationState copyWith({
    VerificationSummaryResult? summary,
    bool? isLoading,
    bool? isSubmitting,
    Object? errorMessage = _unchanged,
  }) {
    return VerificationState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _unchanged)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _unchanged = Object();

class VerificationController extends Notifier<VerificationState> {
  @override
  VerificationState build() => const VerificationState();

  Future<void> load() async {
    if (state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await ref.read(connectApiProvider).verificationSummary();
      state = state.copyWith(summary: summary, isLoading: false);
    } on ApiFailure catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Can't access internet",
      );
    }
  }

  Future<bool> submit({required bool resubmit}) async {
    if (state.isSubmitting) {
      return false;
    }
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final api = ref.read(connectApiProvider);
      final summary = resubmit
          ? await api.resubmitVerification()
          : await api.submitVerification();
      state = state.copyWith(summary: summary, isSubmitting: false);
      await ref.read(profileControllerProvider.notifier).load(force: true);
      return true;
    } on ApiFailure catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: "Can't access internet",
      );
      return false;
    }
  }
}
