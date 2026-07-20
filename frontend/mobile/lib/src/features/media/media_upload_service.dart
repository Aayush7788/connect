import 'dart:io';
import 'dart:typed_data';

import 'package:app_settings/app_settings.dart';
import 'package:connect_app/src/data/connect_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

const maxMediaUploadBytes = 10 * 1024 * 1024;
const mediaUploadMaxDimension = 1440;
const mediaUploadJpegQuality = 72;

final mediaPickerProvider = Provider<MediaPickerGateway>((ref) {
  return DeviceMediaPicker(ImagePicker());
});

final mediaCropperProvider = Provider<MediaCropperGateway>((ref) {
  return DeviceMediaCropper(ImageCropper());
});

final mediaCompressorProvider = Provider<MediaCompressor>((ref) {
  return DeviceMediaCompressor();
});

final appSettingsGatewayProvider = Provider<AppSettingsGateway>((ref) {
  return DeviceAppSettingsGateway();
});

final mediaUploadCoordinatorProvider = Provider<MediaUploadCoordinator>((ref) {
  return MediaUploadCoordinator(
    api: ConnectMediaApiGateway(ref.watch(connectApiProvider)),
    compressor: ref.watch(mediaCompressorProvider),
  );
});

class MediaTargetConfig {
  const MediaTargetConfig({
    required this.entityType,
    required this.entityId,
    required this.documentType,
    required this.minimumPhotos,
    this.maximumPhotos = 5,
    this.cropToSquare = false,
  });

  final String entityType;
  final String entityId;
  final String documentType;
  final int minimumPhotos;
  final int maximumPhotos;
  final bool cropToSquare;
}

class SelectedMediaImage {
  const SelectedMediaImage({required this.name, this.path, this.bytes})
    : assert(path != null || bytes != null);

  final String name;
  final String? path;
  final Uint8List? bytes;
}

class PreparedMediaImage {
  const PreparedMediaImage({
    required this.filename,
    required this.bytes,
    this.mimeType = 'image/jpeg',
  });

  final String filename;
  final Uint8List bytes;
  final String mimeType;
}

class MediaSelectionFailure implements Exception {
  const MediaSelectionFailure(this.message, {this.permissionRequired = false});

  final String message;
  final bool permissionRequired;
}

abstract class AppSettingsGateway {
  Future<void> openSettings();
}

class DeviceAppSettingsGateway implements AppSettingsGateway {
  @override
  Future<void> openSettings() {
    return AppSettings.openAppSettings();
  }
}

abstract class MediaPickerGateway {
  Future<List<SelectedMediaImage>> pickImages({required int limit});

  Future<List<SelectedMediaImage>> recoverLostImages();
}

class DeviceMediaPicker implements MediaPickerGateway {
  DeviceMediaPicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<List<SelectedMediaImage>> pickImages({required int limit}) async {
    try {
      final files = await _picker.pickMultiImage(
        limit: limit,
        requestFullMetadata: false,
      );
      return _read(files);
    } on PlatformException catch (error) {
      throw _selectionFailure(error);
    }
  }

  @override
  Future<List<SelectedMediaImage>> recoverLostImages() async {
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) {
        return const [];
      }
      if (response.exception != null) {
        throw _selectionFailure(response.exception!);
      }
      final files =
          response.files ?? [if (response.file != null) response.file!];
      return _read(files);
    } on PlatformException catch (error) {
      throw _selectionFailure(error);
    }
  }

  Future<List<SelectedMediaImage>> _read(List<XFile> files) async {
    return files
        .map((file) => SelectedMediaImage(name: file.name, path: file.path))
        .toList(growable: false);
  }

  MediaSelectionFailure _selectionFailure(PlatformException error) {
    final code = error.code.toLowerCase();
    final permissionRequired =
        code.contains('denied') ||
        code.contains('permission') ||
        code.contains('access');
    return MediaSelectionFailure(
      permissionRequired ? 'Permission required' : 'Unable to open photos',
      permissionRequired: permissionRequired,
    );
  }
}

abstract class MediaCropperGateway {
  Future<SelectedMediaImage?> cropSquare(SelectedMediaImage image);
}

class DeviceMediaCropper implements MediaCropperGateway {
  DeviceMediaCropper(this._cropper);

  final ImageCropper _cropper;

  @override
  Future<SelectedMediaImage?> cropSquare(SelectedMediaImage image) async {
    if (image.path == null) {
      throw const MediaSelectionFailure('Unable to crop this photo.');
    }
    try {
      final cropped = await _cropper.cropImage(
        sourcePath: image.path!,
        maxWidth: mediaUploadMaxDimension,
        maxHeight: mediaUploadMaxDimension,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 95,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop your photo',
            toolbarColor: const Color(0xFF0F766E),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF0F766E),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: true,
            aspectRatioPresets: const [CropAspectRatioPreset.square],
          ),
        ],
      );
      if (cropped == null) {
        return null;
      }
      return SelectedMediaImage(name: 'profile-photo.jpg', path: cropped.path);
    } on PlatformException {
      throw const MediaSelectionFailure('Unable to crop this photo.');
    }
  }
}

abstract class MediaCompressor {
  Future<PreparedMediaImage> compress(SelectedMediaImage image);
}

class DeviceMediaCompressor implements MediaCompressor {
  @override
  Future<PreparedMediaImage> compress(SelectedMediaImage image) async {
    final bytes = image.path == null
        ? await FlutterImageCompress.compressWithList(
            image.bytes!,
            minWidth: mediaUploadMaxDimension,
            minHeight: mediaUploadMaxDimension,
            quality: mediaUploadJpegQuality,
            format: CompressFormat.jpeg,
            keepExif: false,
          )
        : await _compressFile(image.path!);
    if (bytes.isEmpty || bytes.length > maxMediaUploadBytes) {
      throw const MediaSelectionFailure(
        'Photo is too large. Choose another photo.',
      );
    }
    final stem = image.name
        .replaceFirst(RegExp(r'\.[^.]+$'), '')
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final safeStem = stem.isEmpty ? 'photo' : stem;
    return PreparedMediaImage(
      filename: '${safeStem.substring(0, safeStem.length.clamp(1, 80))}.jpg',
      bytes: bytes,
    );
  }

  Future<Uint8List> _compressFile(String sourcePath) async {
    final targetPath =
        '$sourcePath.connect-${DateTime.now().microsecondsSinceEpoch}.jpg';
    final compressed = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      minWidth: mediaUploadMaxDimension,
      minHeight: mediaUploadMaxDimension,
      quality: mediaUploadJpegQuality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    if (compressed == null) {
      throw const MediaSelectionFailure('Unable to prepare photo.');
    }
    try {
      return await compressed.readAsBytes();
    } finally {
      final file = File(compressed.path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}

abstract class MediaApiGateway {
  Future<UploadIntentResult> createMediaUploadIntent(
    MediaUploadIntentRequest request,
  );

  Future<UploadIntentResult> retryMediaUpload(String mediaAssetId);

  Future<MediaAssetResult> completeMediaUpload(String mediaAssetId);

  Future<void> cancelMediaUpload(String mediaAssetId);

  Future<void> deleteMedia(String mediaAssetId);

  Future<void> uploadMediaBytes({
    required UploadDetailsResult upload,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required ProgressCallback onProgress,
    required CancelToken cancelToken,
  });
}

class ConnectMediaApiGateway implements MediaApiGateway {
  const ConnectMediaApiGateway(this._api);

  final ConnectApi _api;

  @override
  Future<void> cancelMediaUpload(String mediaAssetId) {
    return _api.cancelMediaUpload(mediaAssetId);
  }

  @override
  Future<MediaAssetResult> completeMediaUpload(String mediaAssetId) {
    return _api.completeMediaUpload(mediaAssetId);
  }

  @override
  Future<UploadIntentResult> createMediaUploadIntent(
    MediaUploadIntentRequest request,
  ) {
    return _api.createMediaUploadIntent(request);
  }

  @override
  Future<void> deleteMedia(String mediaAssetId) {
    return _api.deleteMedia(mediaAssetId);
  }

  @override
  Future<UploadIntentResult> retryMediaUpload(String mediaAssetId) {
    return _api.retryMediaUpload(mediaAssetId);
  }

  @override
  Future<void> uploadMediaBytes({
    required UploadDetailsResult upload,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required ProgressCallback onProgress,
    required CancelToken cancelToken,
  }) {
    return _api.uploadMediaBytes(
      upload: upload,
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
  }
}

class MediaUploadCoordinator {
  const MediaUploadCoordinator({required this.api, required this.compressor});

  final MediaApiGateway api;
  final MediaCompressor compressor;

  Future<PreparedMediaImage> prepare(SelectedMediaImage image) {
    return compressor.compress(image);
  }

  Future<UploadIntentResult> createIntent({
    required MediaTargetConfig target,
    required PreparedMediaImage image,
  }) {
    return api.createMediaUploadIntent(
      MediaUploadIntentRequest(
        entityType: target.entityType,
        entityId: target.entityId,
        mediaKind: 'image',
        visibility: 'public',
        documentType: target.documentType,
        filename: image.filename,
        mimeType: image.mimeType,
        byteSize: image.bytes.length,
      ),
    );
  }

  Future<MediaAssetResult> uploadAndComplete({
    required UploadIntentResult intent,
    required PreparedMediaImage image,
    required ProgressCallback onProgress,
    required CancelToken cancelToken,
    required VoidCallback onUploaded,
  }) async {
    await api.uploadMediaBytes(
      upload: intent.upload,
      bytes: image.bytes,
      filename: image.filename,
      mimeType: image.mimeType,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
    onUploaded();
    return api.completeMediaUpload(intent.mediaAsset.id);
  }

  Future<UploadIntentResult> retry(String mediaAssetId) {
    return api.retryMediaUpload(mediaAssetId);
  }

  Future<void> cancel(String mediaAssetId) {
    return api.cancelMediaUpload(mediaAssetId);
  }

  Future<void> delete(String mediaAssetId) {
    return api.deleteMedia(mediaAssetId);
  }
}
