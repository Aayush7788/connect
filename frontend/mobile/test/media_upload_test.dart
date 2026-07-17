import 'dart:convert';
import 'dart:typed_data';

import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/features/media/full_screen_media_gallery.dart';
import 'package:connect_app/src/features/media/media_upload_grid.dart';
import 'package:connect_app/src/features/media/media_upload_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signed storage upload is multipart PUT with file field', () async {
    final adapter = _CapturingAdapter();
    final storageDio = Dio()..httpClientAdapter = adapter;
    final api = DioConnectApi(
      tokenStore: _MemoryTokenStore(),
      storageDio: storageDio,
    );
    await api.uploadMediaBytes(
      upload: UploadDetailsResult(
        url: 'https://storage.test/upload',
        formField: 'file',
        headers: const {},
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      ),
      bytes: _imageBytes,
      filename: 'shop.jpg',
      mimeType: 'image/jpeg',
      onProgress: (sent, total) {},
      cancelToken: CancelToken(),
    );

    final bodyText = latin1.decode(adapter.body);
    expect(adapter.options?.method, 'PUT');
    expect(adapter.options?.contentType, startsWith('multipart/form-data'));
    expect(bodyText, contains('name="file"'));
    expect(bodyText, contains('filename="shop.jpg"'));
  });

  test(
    'coordinator sends the target, reports progress, and completes',
    () async {
      final api = _FakeMediaApi();
      final coordinator = MediaUploadCoordinator(
        api: api,
        compressor: _FakeCompressor(),
      );
      final selected = SelectedMediaImage(name: 'shop.png', bytes: _imageBytes);
      final prepared = await coordinator.prepare(selected);
      final intent = await coordinator.createIntent(
        target: const MediaTargetConfig(
          entityType: 'work_card',
          entityId: 'work-1',
          documentType: 'work_photo',
          minimumPhotos: 3,
        ),
        image: prepared,
      );
      var progress = 0.0;

      final ready = await coordinator.uploadAndComplete(
        intent: intent,
        image: prepared,
        cancelToken: CancelToken(),
        onProgress: (sent, total) => progress = sent / total,
        onUploaded: () {},
      );

      expect(api.lastRequest?.entityType, 'work_card');
      expect(api.lastRequest?.documentType, 'work_photo');
      expect(api.lastRequest?.byteSize, prepared.bytes.length);
      expect(progress, 1);
      expect(ready.uploadStatus, 'ready');
    },
  );

  testWidgets('three uploaded photos satisfy minimum and open gallery', (
    tester,
  ) async {
    final picker = _FakePicker([
      SelectedMediaImage(name: 'one.png', bytes: _imageBytes),
      SelectedMediaImage(name: 'two.png', bytes: _imageBytes),
      SelectedMediaImage(name: 'three.png', bytes: _imageBytes),
    ]);
    final api = _FakeMediaApi();
    MediaUploadSummary? summary;
    await _pumpGrid(
      tester,
      picker: picker,
      api: api,
      onSummaryChanged: (value) => summary = value,
    );

    expect(find.text('Minimum 3 photos required'), findsOneWidget);
    await tester.tap(find.byKey(const Key('media-upload-button')));
    await tester.pumpAndSettle();

    expect(find.text('Uploaded'), findsNWidgets(3));
    expect(find.text('Minimum 3 photos required'), findsNothing);
    expect(summary?.readyCount, 3);
    expect(summary?.meetsMinimum, isTrue);

    await tester.tap(find.byKey(const Key('media-tile-local-0')));
    await tester.pumpAndSettle();
    expect(find.byType(FullScreenMediaGallery), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);
  });

  testWidgets('failed upload shows exact message and retries', (tester) async {
    final api = _FakeMediaApi()..remainingUploadFailures = 1;
    await _pumpGrid(
      tester,
      picker: _FakePicker([
        SelectedMediaImage(name: 'shop.png', bytes: _imageBytes),
      ]),
      api: api,
    );

    await tester.tap(find.byKey(const Key('media-upload-button')));
    await tester.pumpAndSettle();
    expect(find.text('Unable to upload, please retry'), findsOneWidget);

    await tester.tap(find.byTooltip('Retry upload'));
    await tester.pumpAndSettle();
    expect(find.text('Uploaded'), findsOneWidget);
    expect(api.retryCount, 1);
  });

  testWidgets('failed upload can be cancelled before replacement', (
    tester,
  ) async {
    final api = _FakeMediaApi()..remainingUploadFailures = 1;
    await _pumpGrid(
      tester,
      picker: _FakePicker([
        SelectedMediaImage(name: 'shop.png', bytes: _imageBytes),
      ]),
      api: api,
    );

    await tester.tap(find.byKey(const Key('media-upload-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cancel upload'));
    await tester.pumpAndSettle();

    expect(find.text('Unable to upload, please retry'), findsNothing);
    expect(api.cancelled, ['media-0']);
  });

  testWidgets('permission denial shows the required state', (tester) async {
    final settings = _FakeAppSettings();
    await _pumpGrid(
      tester,
      picker: _PermissionDeniedPicker(),
      api: _FakeMediaApi(),
      appSettings: settings,
    );

    await tester.tap(find.byKey(const Key('media-upload-button')));
    await tester.pumpAndSettle();

    expect(find.text('Permission required'), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    expect(settings.openCount, 1);
  });

  testWidgets('deleted server photo is not restored by a stale refresh', (
    tester,
  ) async {
    final api = _FakeMediaApi();
    const existing = MediaAssetResult(
      id: 'server-photo-1',
      mediaKind: 'image',
      visibility: 'public',
      uploadStatus: 'ready',
      sortOrder: 0,
      url: 'https://media.test/server-photo-1.jpg',
      thumbnailUrl: 'https://media.test/server-photo-1-thumbnail.jpg',
      documentType: 'shop_photo',
    );
    await _pumpGrid(
      tester,
      picker: _FakePicker(const []),
      api: api,
      existingMedia: const [existing],
      rebuildWithStaleMediaAfterChange: true,
    );

    expect(
      find.byKey(const Key('media-tile-server-server-photo-1')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Delete photo'));
    await tester.pumpAndSettle();

    expect(api.deleted, ['server-photo-1']);
    expect(
      find.byKey(const Key('media-tile-server-server-photo-1')),
      findsNothing,
    );
  });
}

Future<void> _pumpGrid(
  WidgetTester tester, {
  required MediaPickerGateway picker,
  required _FakeMediaApi api,
  ValueChanged<MediaUploadSummary>? onSummaryChanged,
  AppSettingsGateway? appSettings,
  List<MediaAssetResult> existingMedia = const [],
  bool rebuildWithStaleMediaAfterChange = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mediaPickerProvider.overrideWithValue(picker),
        mediaUploadCoordinatorProvider.overrideWithValue(
          MediaUploadCoordinator(api: api, compressor: _FakeCompressor()),
        ),
        if (appSettings != null)
          appSettingsGatewayProvider.overrideWithValue(appSettings),
      ],
      child: MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MediaUploadGrid(
                target: const MediaTargetConfig(
                  entityType: 'profile',
                  entityId: 'profile-1',
                  documentType: 'shop_photo',
                  minimumPhotos: 3,
                ),
                title: 'Shop photos',
                existingMedia: existingMedia,
                onSummaryChanged: onSummaryChanged,
                onMediaChanged: rebuildWithStaleMediaAfterChange
                    ? () async => setState(() {})
                    : null,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final Uint8List _imageBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);

class _FakePicker implements MediaPickerGateway {
  _FakePicker(this.images);

  final List<SelectedMediaImage> images;

  @override
  Future<List<SelectedMediaImage>> pickImages({required int limit}) async {
    return images.take(limit).toList(growable: false);
  }

  @override
  Future<List<SelectedMediaImage>> recoverLostImages() async => const [];
}

class _PermissionDeniedPicker implements MediaPickerGateway {
  @override
  Future<List<SelectedMediaImage>> pickImages({required int limit}) {
    throw const MediaSelectionFailure(
      'Permission required',
      permissionRequired: true,
    );
  }

  @override
  Future<List<SelectedMediaImage>> recoverLostImages() async => const [];
}

class _FakeCompressor implements MediaCompressor {
  @override
  Future<PreparedMediaImage> compress(SelectedMediaImage image) async {
    return PreparedMediaImage(
      filename: '${image.name}.jpg',
      bytes: image.bytes!,
    );
  }
}

class _FakeMediaApi implements MediaApiGateway {
  int sequence = 0;
  int retryCount = 0;
  int remainingUploadFailures = 0;
  MediaUploadIntentRequest? lastRequest;
  final List<String> cancelled = [];
  final List<String> deleted = [];

  @override
  Future<void> cancelMediaUpload(String mediaAssetId) async {
    cancelled.add(mediaAssetId);
  }

  @override
  Future<MediaAssetResult> completeMediaUpload(String mediaAssetId) async {
    return MediaAssetResult(
      id: mediaAssetId,
      mediaKind: 'image',
      visibility: 'public',
      uploadStatus: 'ready',
      sortOrder: sequence,
      url: 'https://media.test/$mediaAssetId.jpg',
      documentType: lastRequest?.documentType,
    );
  }

  @override
  Future<UploadIntentResult> createMediaUploadIntent(
    MediaUploadIntentRequest request,
  ) async {
    lastRequest = request;
    return _intent('media-${sequence++}', request.documentType);
  }

  @override
  Future<void> deleteMedia(String mediaAssetId) async {
    deleted.add(mediaAssetId);
  }

  @override
  Future<UploadIntentResult> retryMediaUpload(String mediaAssetId) async {
    retryCount += 1;
    return _intent(mediaAssetId, lastRequest?.documentType ?? 'shop_photo');
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
    if (remainingUploadFailures > 0) {
      remainingUploadFailures -= 1;
      throw const ApiFailure(
        code: 'upload_failed',
        message: 'Unable to upload, please retry',
      );
    }
    onProgress(bytes.length, bytes.length);
  }

  UploadIntentResult _intent(String id, String documentType) {
    return UploadIntentResult(
      mediaAsset: MediaAssetResult(
        id: id,
        mediaKind: 'image',
        visibility: 'public',
        uploadStatus: 'pending_upload',
        sortOrder: sequence,
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

class _MemoryTokenStore implements TokenStore {
  @override
  Future<void> clear() async {}

  @override
  Future<String?> readAccessToken() async => 'token';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

class _FakeAppSettings implements AppSettingsGateway {
  int openCount = 0;

  @override
  Future<void> openSettings() async {
    openCount += 1;
  }
}

class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? options;
  List<int> body = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    this.options = options;
    if (requestStream != null) {
      body = await requestStream.fold<List<int>>(
        <int>[],
        (bytes, chunk) => bytes..addAll(chunk),
      );
    }
    return ResponseBody.fromString('', 200);
  }
}
