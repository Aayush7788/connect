import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/features/discovery/discovery_controller.dart';
import 'package:connect_app/src/features/discovery/profile_detail_screen.dart';
import 'package:connect_app/src/features/engagement/engagement_controller.dart';
import 'package:connect_app/src/features/profile/profile_controller.dart';
import 'package:connect_app/src/features/profile/verification_controller.dart';
import 'package:connect_app/src/features/work_cards/work_card_controller.dart';
import 'package:connect_app/src/features/work_needed_posts/work_needed_post_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

enum AppRoute {
  splash('/splash'),
  createAccount('/create-account'),
  otp('/otp'),
  selectRole('/select-role'),
  confirmRole('/confirm-role'),
  blocked('/blocked'),
  home('/home'),
  search('/search'),
  completeProfile('/profile/complete'),
  addWorkCard('/work-cards/new'),
  addWorkNeededPost('/work-needed-posts/new'),
  notifications('/notifications'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}

class AuthState {
  const AuthState({
    this.pendingName = '',
    this.pendingMobile = '',
    this.otpRequestId,
    this.selectedRole,
    this.me,
    this.isLoading = false,
    this.errorMessage,
  });

  final String pendingName;
  final String pendingMobile;
  final String? otpRequestId;
  final String? selectedRole;
  final MeResult? me;
  final bool isLoading;
  final String? errorMessage;

  String get displayName {
    final serverName = me?.user.displayName.trim();
    if (serverName != null && serverName.isNotEmpty) {
      return serverName;
    }
    return pendingName.trim();
  }

  AuthState copyWith({
    String? pendingName,
    String? pendingMobile,
    String? otpRequestId,
    String? selectedRole,
    MeResult? me,
    bool? isLoading,
    Object? errorMessage = _unchanged,
  }) {
    return AuthState(
      pendingName: pendingName ?? this.pendingName,
      pendingMobile: pendingMobile ?? this.pendingMobile,
      otpRequestId: otpRequestId ?? this.otpRequestId,
      selectedRole: selectedRole ?? this.selectedRole,
      me: me ?? this.me,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unchanged)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _unchanged = Object();

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<AppRoute> bootstrap() async {
    final tokenStore = ref.read(tokenStoreProvider);
    final token = await tokenStore.readAccessToken();
    if (token == null || token.isEmpty) {
      return AppRoute.createAccount;
    }

    try {
      final me = await ref.read(connectApiProvider).me();
      state = state.copyWith(me: me, errorMessage: null);
      return routeForNextState(me.nextState);
    } on DioException {
      await tokenStore.clear();
      return AppRoute.createAccount;
    }
  }

  Future<void> requestOtp({
    required String name,
    required String mobile,
  }) async {
    state = state.copyWith(
      pendingName: name.trim(),
      pendingMobile: mobile.trim(),
      isLoading: true,
      errorMessage: null,
    );
    try {
      final response = await ref
          .read(connectApiProvider)
          .requestOtp(mobile: mobile.trim());
      state = state.copyWith(
        otpRequestId: response.otpRequestId,
        isLoading: false,
        errorMessage: null,
      );
    } on ApiFailure catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to send OTP. Please retry.',
      );
      rethrow;
    }
  }

  Future<AppRoute> verifyOtp(String otp) async {
    final otpRequestId = state.otpRequestId;
    if (otpRequestId == null) {
      state = state.copyWith(errorMessage: 'Please request OTP again.');
      return AppRoute.createAccount;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final session = await ref
          .read(connectApiProvider)
          .verifyOtp(
            mobile: state.pendingMobile,
            otp: otp.trim(),
            otpRequestId: otpRequestId,
          );
      await ref
          .read(tokenStoreProvider)
          .saveTokens(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
          );

      var nextState = session.nextState;
      MeResult? me;
      if (nextState == 'complete_basic_account') {
        if (state.pendingName.trim().isEmpty) {
          state = state.copyWith(isLoading: false);
          return AppRoute.createAccount;
        }
        me = await ref
            .read(connectApiProvider)
            .completeBasicAccount(displayName: state.pendingName);
        nextState = me.nextState;
      } else {
        me = await ref.read(connectApiProvider).me();
        nextState = me.nextState;
      }

      state = state.copyWith(me: me, isLoading: false, errorMessage: null);
      return routeForNextState(nextState);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Incorrect OTP');
      rethrow;
    }
  }

  void selectRole(String role) {
    state = state.copyWith(selectedRole: role, errorMessage: null);
  }

  Future<AppRoute> confirmRole() async {
    final role = state.selectedRole;
    if (role == null) {
      state = state.copyWith(errorMessage: 'Please select a role.');
      return AppRoute.selectRole;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final me = await ref.read(connectApiProvider).confirmRole(role: role);
      state = state.copyWith(me: me, isLoading: false, errorMessage: null);
      return routeForNextState(me.nextState);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to save role. Please retry.',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(connectApiProvider).logout();
    } finally {
      try {
        await ref.read(tokenStoreProvider).clear();
      } finally {
        _invalidateAccountState();
        state = const AuthState();
      }
    }
  }

  void _invalidateAccountState() {
    ref.invalidate(profileControllerProvider);
    ref.invalidate(workCardControllerProvider);
    ref.invalidate(workNeededPostControllerProvider);
    ref.invalidate(verificationControllerProvider);
    ref.invalidate(engagementControllerProvider);
    ref.invalidate(discoveryControllerProvider);
    ref.invalidate(publicProfileDetailProvider);
  }

  void updateProfileSummary(ProfileSummary profile) {
    final me = state.me;
    if (me != null) {
      state = state.copyWith(me: me.withProfile(profile));
    }
  }

  AppRoute routeForNextState(String nextState) {
    return switch (nextState) {
      'home' => AppRoute.home,
      'role_selection_required' => AppRoute.selectRole,
      'account_blocked' => AppRoute.blocked,
      _ => AppRoute.createAccount,
    };
  }
}
