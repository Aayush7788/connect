import 'dart:typed_data';

import 'package:connect_app/src/connect_app.dart';
import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/features/media/media_upload_service.dart';
import 'package:connect_app/src/features/profile/profile_controller.dart';
import 'package:dio/dio.dart';
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

  test('profile controller saves an incomplete draft', () async {
    final api = _FakeConnectApi();
    final container = ProviderContainer(
      overrides: [connectApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);

    final controller = container.read(profileControllerProvider.notifier);
    await controller.load();
    final saved = await controller.save(const {
      'business_name': 'Surat Dupatta House',
      'locality': 'Ring Road',
    });

    expect(saved, isTrue);
    expect(api.lastProfileUpdate?['business_name'], 'Surat Dupatta House');
    expect(container.read(profileControllerProvider).profile, isNotNull);
  });

  test('profile controller exposes backend completion requirements', () async {
    final container = ProviderContainer(
      overrides: [connectApiProvider.overrideWithValue(_FakeConnectApi())],
    );
    addTearDown(container.dispose);

    await container.read(profileControllerProvider.notifier).load();
    final state = container.read(profileControllerProvider);

    expect(state.profile?.profile.completionScore, 25);
    expect(state.profile?.profile.completionFlags['address'], isFalse);
    expect(state.profile?.profile.completionFlags['shop_photos'], isFalse);
  });

  test('profile completion uses the backend completion state', () async {
    final container = ProviderContainer(
      overrides: [connectApiProvider.overrideWithValue(_FakeConnectApi())],
    );
    addTearDown(container.dispose);

    final controller = container.read(profileControllerProvider.notifier);
    await controller.load();
    expect(await controller.complete(), isTrue);

    final profile = container.read(profileControllerProvider).profile?.profile;
    expect(profile?.completionScore, 100);
    expect(profile?.completionFlags.values.every((value) => value), isTrue);
  });

  test('profile visibility follows the backend response', () async {
    final container = ProviderContainer(
      overrides: [connectApiProvider.overrideWithValue(_FakeConnectApi())],
    );
    addTearDown(container.dispose);

    final controller = container.read(profileControllerProvider.notifier);
    await controller.load();
    expect(await controller.setHidden(true), isTrue);
    expect(
      container
          .read(profileControllerProvider)
          .profile
          ?.profile
          .visibilityStatus,
      'hidden_by_user',
    );
  });

  testWidgets('job worker opens the role-specific completion form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _FakeConnectApi()..profile = _ownerProfile(role: 'job_worker');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            _MemoryTokenStore(initialAccessToken: 'access-token'),
          ),
          connectApiProvider.overrideWithValue(api),
          mediaPickerProvider.overrideWithValue(_NoopMediaPicker()),
        ],
        child: const ConnectApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Profile'));
    await tester.pumpAndSettle();
    expect(find.text('25% complete'), findsOneWidget);

    await tester.tap(find.text('Complete your profile to get business'));
    await tester.pumpAndSettle();

    expect(find.text('Complete Profile'), findsOneWidget);
    expect(find.text('Job Worker / Value Adder'), findsOneWidget);
    expect(find.text('I work from a workshop'), findsOneWidget);
    expect(find.text('Workshop name'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Workplace photos'), findsOneWidget);
    expect(find.text('Minimum 3 photos required'), findsOneWidget);
  });
}

class _NoopMediaPicker implements MediaPickerGateway {
  @override
  Future<List<SelectedMediaImage>> pickImages({required int limit}) async {
    return const [];
  }

  @override
  Future<List<SelectedMediaImage>> recoverLostImages() async => const [];
}

class _MemoryTokenStore implements TokenStore {
  _MemoryTokenStore({String? initialAccessToken})
    : _accessToken = initialAccessToken;

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
  OwnerProfileResult profile = _ownerProfile();
  Map<String, dynamic>? lastProfileUpdate;
  int mediaSequence = 0;

  @override
  Future<List<CategoryOption>> categories({
    required String categoryType,
  }) async {
    return const [];
  }

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
  Future<void> cancelMediaUpload(String mediaAssetId) async {}

  @override
  Future<MediaAssetResult> completeMediaUpload(String mediaAssetId) async {
    return MediaAssetResult(
      id: mediaAssetId,
      mediaKind: 'image',
      visibility: 'public',
      uploadStatus: 'ready',
      sortOrder: 0,
      url: 'https://media.test/$mediaAssetId.jpg',
      documentType: 'shop_photo',
    );
  }

  @override
  Future<UploadIntentResult> createMediaUploadIntent(
    MediaUploadIntentRequest request,
  ) async {
    final id = 'media-${mediaSequence++}';
    return _uploadIntent(id, request.documentType);
  }

  @override
  Future<void> deleteMedia(String mediaAssetId) async {}

  @override
  Future<MeResult> confirmRole({required String role}) async {
    profile = _ownerProfile(role: role);
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
  Future<OwnerProfileResult> completeOwnerProfile() async {
    profile = _ownerProfile(
      role: profile.profile.role,
      visibilityStatus: profile.profile.visibilityStatus,
      completionScore: 100,
      completionFlags: const {
        'owner_name': true,
        'address': true,
        'shop_photos': true,
      },
    );
    return profile;
  }

  @override
  Future<OwnerProfileResult> hideOwnerProfile() async {
    profile = _ownerProfile(
      role: profile.profile.role,
      visibilityStatus: 'hidden_by_user',
    );
    return profile;
  }

  @override
  Future<MeResult> me() async {
    return MeResult(
      user: UserSummary(
        id: 'user-1',
        displayName: 'Aayush',
        primaryMobile: '+919999999999',
        accountStatus: 'active',
        role: profile.profile.role,
      ),
      nextState: 'home',
      profile: profile.profile,
      allowedActions: const ['search', 'view_profile', 'logout'],
      unreadNotificationCount: 0,
    );
  }

  @override
  Future<OwnerProfileResult> ownerProfile() async => profile;

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
  Future<UploadIntentResult> retryMediaUpload(String mediaAssetId) async {
    return _uploadIntent(mediaAssetId, 'shop_photo');
  }

  @override
  Future<OwnerProfileResult> showOwnerProfile() async {
    profile = _ownerProfile(role: profile.profile.role);
    return profile;
  }

  @override
  Future<OwnerProfileResult> updateOwnerProfile(
    Map<String, dynamic> fields,
  ) async {
    lastProfileUpdate = fields;
    return profile;
  }

  @override
  Future<void> uploadMediaBytes({
    required UploadDetailsResult upload,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required ProgressCallback onProgress,
    required CancelToken cancelToken,
  }) async {
    onProgress(bytes.length, bytes.length);
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

  UploadIntentResult _uploadIntent(String id, String documentType) {
    return UploadIntentResult(
      mediaAsset: MediaAssetResult(
        id: id,
        mediaKind: 'image',
        visibility: 'public',
        uploadStatus: 'pending_upload',
        sortOrder: mediaSequence,
        documentType: documentType,
      ),
      upload: UploadDetailsResult(
        url: 'https://storage.test/$id',
        formField: 'file',
        headers: const {},
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      ),
    );
  }
}

OwnerProfileResult _ownerProfile({
  String role = 'business',
  String visibilityStatus = 'draft',
  int completionScore = 25,
  Map<String, bool> completionFlags = const {
    'owner_name': true,
    'address': false,
    'shop_photos': false,
  },
}) {
  return OwnerProfileResult(
    profile: ProfileSummary(
      id: 'profile-1',
      role: role,
      displayName: 'Aayush',
      visibilityStatus: visibilityStatus,
      completionScore: completionScore,
      verificationStatus: 'unverified',
      isVerified: false,
      completionFlags: completionFlags,
    ),
    editableFields: const [],
    lockedFields: const [],
    roleSpecific: const {'owner_name': 'Aayush'},
  );
}
