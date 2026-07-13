import 'dart:typed_data';

import 'package:connect_app/src/connect_app.dart';
import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/discovery_models.dart';
import 'package:connect_app/src/data/engagement_models.dart';
import 'package:connect_app/src/data/work_card_models.dart';
import 'package:connect_app/src/data/work_needed_post_models.dart';
import 'package:connect_app/src/features/media/media_upload_service.dart';
import 'package:connect_app/src/features/profile/profile_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

    GoRouter.of(tester.element(find.byType(Navigator).first)).go('/splash');
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('job-worker-profile-tab')));
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

  testWidgets('business opens work-needed list and sticky add flow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _FakeConnectApi();

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

    GoRouter.of(tester.element(find.byType(Navigator).first)).go('/splash');
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Work Needed Posts'), findsOneWidget);
    expect(find.text('Find work by posting'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(api.ownerWorkNeededPosts, hasLength(1));
    expect(find.text('Add Work Needed'), findsOneWidget);
    expect(find.text('Save and Publish'), findsOneWidget);
  });

  testWidgets('search card hides contact and profile detail reveals it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _FakeConnectApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            _MemoryTokenStore(initialAccessToken: 'access-token'),
          ),
          connectApiProvider.overrideWithValue(api),
        ],
        child: const ConnectApp(),
      ),
    );
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.byType(Navigator).first)).go('/home');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Find Job Worker, Value Adder'));
    await tester.pumpAndSettle();

    expect(find.text('Flat hemming'), findsOneWidget);
    expect(find.text('+919999999999'), findsNothing);
    expect(find.text('Ring Road, Surat'), findsNothing);

    await tester.tap(find.text('Flat hemming'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, 'Profile'));
    await tester.pumpAndSettle();

    expect(find.text('+919999999999'), findsOneWidget);
    expect(find.text('Ring Road, Surat'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
  });

  testWidgets('profile can be saved and appears in persona saved tab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _FakeConnectApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            _MemoryTokenStore(initialAccessToken: 'access-token'),
          ),
          connectApiProvider.overrideWithValue(api),
        ],
        child: const ConnectApp(),
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(
      tester.element(find.byType(Navigator).first),
    ).go('/profiles/profile-1');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, 'Profile'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(OutlinedButton, 'Saved'), findsOneWidget);
    expect(api.saved, hasLength(1));

    GoRouter.of(tester.element(find.byType(Navigator).first)).go('/home');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Tab, 'Job Worker'), findsOneWidget);
    await tester.tap(find.widgetWithText(Tab, 'Job Worker'));
    await tester.pumpAndSettle();
    expect(find.text('Surat Hemming Works'), findsOneWidget);
  });

  testWidgets('notification bell opens list and marks a row read', (
    tester,
  ) async {
    final api = _FakeConnectApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            _MemoryTokenStore(initialAccessToken: 'access-token'),
          ),
          connectApiProvider.overrideWithValue(api),
        ],
        child: const ConnectApp(),
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Navigator).first)).go('/home');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Profile approved'), findsOneWidget);
    await tester.tap(find.text('Profile approved'));
    await tester.pumpAndSettle();
    expect(api.notificationRead, isTrue);
  });

  testWidgets('settings updates push preference through backend API', (
    tester,
  ) async {
    final api = _FakeConnectApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            _MemoryTokenStore(initialAccessToken: 'access-token'),
          ),
          connectApiProvider.overrideWithValue(api),
        ],
        child: const ConnectApp(),
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Navigator).first)).go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(SwitchListTile, 'Push notifications'));
    await tester.pumpAndSettle();

    expect(api.pushNotificationsEnabled, isFalse);
  });

  testWidgets('profile report requires a reason and submits', (tester) async {
    final api = _FakeConnectApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            _MemoryTokenStore(initialAccessToken: 'access-token'),
          ),
          connectApiProvider.overrideWithValue(api),
        ],
        child: const ConnectApp(),
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(
      tester.element(find.byType(Navigator).first),
    ).go('/profiles/profile-1');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wrong contact'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Submit report'));
    await tester.pumpAndSettle();

    expect(api.reportCount, 1);
    expect(find.text('Report submitted'), findsOneWidget);
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
  final List<WorkCardResult> ownerWorkCards = [];
  final List<WorkNeededPostResult> ownerWorkNeededPosts = [];
  Map<String, dynamic>? lastProfileUpdate;
  int mediaSequence = 0;
  final List<SavedItemResult> saved = [];
  bool notificationRead = false;
  bool pushNotificationsEnabled = true;
  int reportCount = 0;

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
  Future<void> deleteWorkCard(String workCardId) async {
    ownerWorkCards.removeWhere((card) => card.id == workCardId);
  }

  @override
  Future<WorkCardResult> createWorkCard(
    WorkCardUpsert fields, {
    String? idempotencyKey,
  }) async {
    final card = _workCard(id: 'work-${ownerWorkCards.length + 1}');
    ownerWorkCards.insert(0, card);
    return card;
  }

  @override
  Future<WorkCardResult> updateWorkCard(
    String workCardId,
    WorkCardUpsert fields,
  ) async {
    return ownerWorkCards.firstWhere((card) => card.id == workCardId);
  }

  @override
  Future<WorkCardResult> publishWorkCard(String workCardId) async {
    return ownerWorkCards.firstWhere((card) => card.id == workCardId);
  }

  @override
  Future<WorkCardResult> hideWorkCard(String workCardId) async {
    return ownerWorkCards.firstWhere((card) => card.id == workCardId);
  }

  @override
  Future<WorkCardResult> showWorkCard(String workCardId) async {
    return ownerWorkCards.firstWhere((card) => card.id == workCardId);
  }

  @override
  Future<List<WorkCardResult>> workCards() async => ownerWorkCards;

  @override
  Future<WorkNeededPostResult> closeWorkNeededPost(String postId) async {
    return ownerWorkNeededPosts.firstWhere((post) => post.id == postId);
  }

  @override
  Future<WorkNeededPostResult> createWorkNeededPost(
    WorkNeededPostUpsert fields, {
    String? idempotencyKey,
  }) async {
    final post = _workNeededPost(id: 'post-${ownerWorkNeededPosts.length + 1}');
    ownerWorkNeededPosts.insert(0, post);
    return post;
  }

  @override
  Future<void> deleteWorkNeededPost(String postId) async {
    ownerWorkNeededPosts.removeWhere((post) => post.id == postId);
  }

  @override
  Future<WorkNeededPostResult> pauseWorkNeededPost(String postId) async {
    return ownerWorkNeededPosts.firstWhere((post) => post.id == postId);
  }

  @override
  Future<WorkNeededPostResult> publishWorkNeededPost(String postId) async {
    return ownerWorkNeededPosts.firstWhere((post) => post.id == postId);
  }

  @override
  Future<WorkNeededPostResult> resumeWorkNeededPost(String postId) async {
    return ownerWorkNeededPosts.firstWhere((post) => post.id == postId);
  }

  @override
  Future<WorkNeededPostResult> updateWorkNeededPost(
    String postId,
    WorkNeededPostUpsert fields,
  ) async {
    return ownerWorkNeededPosts.firstWhere((post) => post.id == postId);
  }

  @override
  Future<List<WorkNeededPostResult>> workNeededPosts() async {
    return ownerWorkNeededPosts;
  }

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
  Future<MarketplaceSearchResponse> searchMarketplace(
    MarketplaceSearchRequest request,
  ) async {
    return const MarketplaceSearchResponse(
      items: [
        MarketplaceSearchResult(
          resultType: 'work_card',
          id: 'work-1',
          profileId: 'profile-1',
          title: 'Flat hemming',
          subtitle: 'Aayush Hemming',
          category: 'Stitching',
          productTypes: ['Dupatta'],
          locality: 'Ring Road',
          isVerified: true,
          photoCount: 3,
        ),
      ],
      resultCount: 1,
      searchLogId: 'search-log-1',
    );
  }

  @override
  Future<PublicProfileDetailResult> publicProfile(
    String profileId, {
    String? sourceType,
    String? sourceId,
  }) async {
    return PublicProfileDetailResult(
      profile: PublicProfileSummary(
        id: profileId,
        role: 'job_worker',
        visibilityStatus: 'public',
        completionScore: 100,
        verificationStatus: 'verified',
        isVerified: true,
        displayName: 'Aayush Hemming',
      ),
      roleSpecific: const {
        'owner_name': 'Aayush',
        'work_summary': 'Flat hemming',
      },
      contact: const PublicContactResult(
        mobile: '+919999999999',
        whatsappNumber: '+919999999999',
      ),
      address: const PublicAddressResult(
        locality: 'Ring Road',
        fullAddress: 'Ring Road, Surat',
      ),
      media: const [],
      workCards: [
        WorkCardResult(
          id: 'work-1',
          profileId: profileId,
          status: 'published',
          title: 'Flat hemming',
          categoryName: 'Stitching',
          productTypeIds: const [],
          customProductTexts: const ['Dupatta'],
          productTypes: const ['Dupatta'],
          description: 'Clean flat hemming for dupattas',
          photoCount: 3,
          photos: const [],
          createdAt: DateTime(2026, 7, 13),
          updatedAt: DateTime(2026, 7, 13),
        ),
      ],
      workNeededPosts: const [],
      similarProfiles: const [],
    );
  }

  @override
  Future<List<SavedItemResult>> savedItems() async => saved;

  @override
  Future<SavedItemResult> saveItem({
    required String targetType,
    required String targetId,
  }) async {
    final item = SavedItemResult(
      id: 'saved-${saved.length + 1}',
      targetType: targetType,
      targetId: targetId,
      profileRole: 'job_worker',
      card: MarketplaceSearchResult(
        resultType: 'profile',
        id: targetId,
        profileId: targetId,
        title: 'Surat Hemming Works',
        isVerified: true,
        photoCount: 3,
      ),
    );
    saved.add(item);
    return item;
  }

  @override
  Future<void> removeSavedItem(String savedItemId) async {
    saved.removeWhere((item) => item.id == savedItemId);
  }

  @override
  Future<void> createReport({
    required String targetType,
    required String targetId,
    required String reason,
  }) async {
    reportCount += 1;
  }

  @override
  Future<List<NotificationResult>> notifications() async => [
    NotificationResult(
      id: 'notification-1',
      title: 'Profile approved',
      message: 'Your profile is now verified.',
      createdAt: DateTime(2026, 7, 13, 10, 30),
      readAt: notificationRead ? DateTime(2026, 7, 13, 10, 31) : null,
    ),
  ];

  @override
  Future<NotificationResult> markNotificationRead(String notificationId) async {
    notificationRead = true;
    final now = DateTime.now();
    return NotificationResult(
      id: notificationId,
      title: 'Profile approved',
      message: 'Your profile is now verified.',
      createdAt: now,
      readAt: now,
    );
  }

  @override
  Future<UserSettingsResult> updateSettings({
    bool? pushNotificationsEnabled,
    bool? hiddenFromSearch,
  }) async {
    if (pushNotificationsEnabled != null) {
      this.pushNotificationsEnabled = pushNotificationsEnabled;
    }
    return UserSettingsResult(
      pushNotificationsEnabled: this.pushNotificationsEnabled,
      hiddenFromSearch: hiddenFromSearch ?? false,
    );
  }

  @override
  Future<UserSettingsResult> userSettings() async {
    return UserSettingsResult(
      pushNotificationsEnabled: pushNotificationsEnabled,
      hiddenFromSearch: false,
    );
  }

  @override
  Future<void> logContactAction({
    required String profileId,
    required String actionType,
    String? sourceType,
    String? sourceId,
  }) async {}

  @override
  Future<ShareLinkResult> createShareLink({
    required String targetType,
    required String targetId,
    String? channel,
  }) async {
    return ShareLinkResult(
      url: 'https://connect.example/profiles/$targetId',
      shareText: 'View this profile on Connect',
    );
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

WorkCardResult _workCard({required String id}) {
  final now = DateTime(2026, 7, 13);
  return WorkCardResult(
    id: id,
    profileId: 'profile-1',
    status: 'draft',
    title: '',
    productTypeIds: const [],
    customProductTexts: const [],
    productTypes: const [],
    photoCount: 0,
    photos: const [],
    createdAt: now,
    updatedAt: now,
  );
}

WorkNeededPostResult _workNeededPost({required String id}) {
  final now = DateTime(2026, 7, 13);
  return WorkNeededPostResult(
    id: id,
    profileId: 'profile-1',
    status: 'draft',
    title: '',
    productTypeIds: const [],
    customProductTexts: const [],
    productTypes: const [],
    photoCount: 0,
    photos: const [],
    createdAt: now,
    updatedAt: now,
  );
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
