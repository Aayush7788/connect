import 'package:connect_app/src/connect_app.dart';
import 'package:connect_app/src/data/connect_api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('new user sees create account after splash', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
          connectApiProvider.overrideWithValue(_FakeConnectApi()),
        ],
        child: const ConnectApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('create account validates required fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
          connectApiProvider.overrideWithValue(_FakeConnectApi()),
        ],
        child: const ConnectApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Please enter the name'), findsOneWidget);
    expect(find.text('Please enter the mobile number'), findsOneWidget);
  });

  testWidgets('otp and role confirmation reaches home', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
          connectApiProvider.overrideWithValue(_FakeConnectApi()),
        ],
        child: const ConnectApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).first, 'Aayush');
    await tester.enterText(find.byType(EditableText).last, '9999999999');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Enter OTP'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), '123456');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(find.text('Select your role'), findsOneWidget);
    await tester.tap(find.text('Job Worker / Value Adder'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm role'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Who are you looking for?'), findsOneWidget);
    expect(find.text('Complete your profile'), findsOneWidget);
  });
}

class _MemoryTokenStore implements TokenStore {
  String? _accessToken;

  @override
  Future<void> clear() async {
    _accessToken = null;
  }

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
  }
}

class _FakeConnectApi implements ConnectApi {
  @override
  Future<MeResult> completeBasicAccount({required String displayName}) async {
    return MeResult(
      user: UserSummary(
        id: 'user-1',
        displayName: displayName,
        primaryMobile: '+919999999999',
        accountStatus: 'active',
      ),
      nextState: 'role_selection_required',
      allowedActions: const ['select_role', 'logout'],
      unreadNotificationCount: 0,
    );
  }

  @override
  Future<MeResult> confirmRole({required String role}) async {
    return MeResult(
      user: UserSummary(
        id: 'user-1',
        displayName: 'Aayush',
        primaryMobile: '+919999999999',
        accountStatus: 'active',
        role: role,
      ),
      nextState: 'home',
      profile: ProfileSummary(
        id: 'profile-1',
        role: role,
        visibilityStatus: 'draft',
        completionScore: 0,
        verificationStatus: 'unverified',
        isVerified: false,
      ),
      allowedActions: const ['search', 'view_profile', 'logout'],
      unreadNotificationCount: 0,
    );
  }

  @override
  Future<MeResult> me() {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<OtpRequestResult> requestOtp({required String mobile}) async {
    return const OtpRequestResult(
      otpRequestId: '00000000-0000-0000-0000-000000000001',
      message: 'OTP sent',
    );
  }

  @override
  Future<AuthSessionResult> verifyOtp({
    required String mobile,
    required String otp,
    required String otpRequestId,
  }) async {
    return AuthSessionResult(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      nextState: 'complete_basic_account',
      user: UserSummary(
        id: 'user-1',
        displayName: '',
        primaryMobile: mobile,
        accountStatus: 'active',
      ),
    );
  }
}
