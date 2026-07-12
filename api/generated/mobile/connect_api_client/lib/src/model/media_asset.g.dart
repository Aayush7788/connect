// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_asset.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaAssetCWProxy {
  MediaAsset id(String id);

  MediaAsset mediaKind(MediaKind mediaKind);

  MediaAsset visibility(MediaVisibility visibility);

  MediaAsset uploadStatus(UploadStatus uploadStatus);

  MediaAsset url(String? url);

  MediaAsset thumbnailUrl(String? thumbnailUrl);

  MediaAsset sortOrder(int sortOrder);

  MediaAsset documentType(String? documentType);

  MediaAsset safeDisplayName(String? safeDisplayName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaAsset(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaAsset(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaAsset call({
    String id,
    MediaKind mediaKind,
    MediaVisibility visibility,
    UploadStatus uploadStatus,
    String? url,
    String? thumbnailUrl,
    int sortOrder,
    String? documentType,
    String? safeDisplayName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaAsset.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaAsset.copyWith.fieldName(...)`
class _$MediaAssetCWProxyImpl implements _$MediaAssetCWProxy {
  const _$MediaAssetCWProxyImpl(this._value);

  final MediaAsset _value;

  @override
  MediaAsset id(String id) => this(id: id);

  @override
  MediaAsset mediaKind(MediaKind mediaKind) => this(mediaKind: mediaKind);

  @override
  MediaAsset visibility(MediaVisibility visibility) =>
      this(visibility: visibility);

  @override
  MediaAsset uploadStatus(UploadStatus uploadStatus) =>
      this(uploadStatus: uploadStatus);

  @override
  MediaAsset url(String? url) => this(url: url);

  @override
  MediaAsset thumbnailUrl(String? thumbnailUrl) =>
      this(thumbnailUrl: thumbnailUrl);

  @override
  MediaAsset sortOrder(int sortOrder) => this(sortOrder: sortOrder);

  @override
  MediaAsset documentType(String? documentType) =>
      this(documentType: documentType);

  @override
  MediaAsset safeDisplayName(String? safeDisplayName) =>
      this(safeDisplayName: safeDisplayName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaAsset(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaAsset(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaAsset call({
    Object? id = const $CopyWithPlaceholder(),
    Object? mediaKind = const $CopyWithPlaceholder(),
    Object? visibility = const $CopyWithPlaceholder(),
    Object? uploadStatus = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? thumbnailUrl = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? documentType = const $CopyWithPlaceholder(),
    Object? safeDisplayName = const $CopyWithPlaceholder(),
  }) {
    return MediaAsset(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      mediaKind: mediaKind == const $CopyWithPlaceholder()
          ? _value.mediaKind
          // ignore: cast_nullable_to_non_nullable
          : mediaKind as MediaKind,
      visibility: visibility == const $CopyWithPlaceholder()
          ? _value.visibility
          // ignore: cast_nullable_to_non_nullable
          : visibility as MediaVisibility,
      uploadStatus: uploadStatus == const $CopyWithPlaceholder()
          ? _value.uploadStatus
          // ignore: cast_nullable_to_non_nullable
          : uploadStatus as UploadStatus,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      thumbnailUrl: thumbnailUrl == const $CopyWithPlaceholder()
          ? _value.thumbnailUrl
          // ignore: cast_nullable_to_non_nullable
          : thumbnailUrl as String?,
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int,
      documentType: documentType == const $CopyWithPlaceholder()
          ? _value.documentType
          // ignore: cast_nullable_to_non_nullable
          : documentType as String?,
      safeDisplayName: safeDisplayName == const $CopyWithPlaceholder()
          ? _value.safeDisplayName
          // ignore: cast_nullable_to_non_nullable
          : safeDisplayName as String?,
    );
  }
}

extension $MediaAssetCopyWith on MediaAsset {
  /// Returns a callable class that can be used as follows: `instanceOfMediaAsset.copyWith(...)` or like so:`instanceOfMediaAsset.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaAssetCWProxy get copyWith => _$MediaAssetCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaAsset _$MediaAssetFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MediaAsset',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'media_kind',
        'visibility',
        'upload_status',
        'sort_order',
      ],
    );
    final val = MediaAsset(
      id: $checkedConvert('id', (v) => v as String),
      mediaKind: $checkedConvert(
        'media_kind',
        (v) => $enumDecode(_$MediaKindEnumMap, v),
      ),
      visibility: $checkedConvert(
        'visibility',
        (v) => $enumDecode(_$MediaVisibilityEnumMap, v),
      ),
      uploadStatus: $checkedConvert(
        'upload_status',
        (v) => $enumDecode(_$UploadStatusEnumMap, v),
      ),
      url: $checkedConvert('url', (v) => v as String?),
      thumbnailUrl: $checkedConvert('thumbnail_url', (v) => v as String?),
      sortOrder: $checkedConvert('sort_order', (v) => (v as num).toInt()),
      documentType: $checkedConvert('document_type', (v) => v as String?),
      safeDisplayName: $checkedConvert(
        'safe_display_name',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'mediaKind': 'media_kind',
    'uploadStatus': 'upload_status',
    'thumbnailUrl': 'thumbnail_url',
    'sortOrder': 'sort_order',
    'documentType': 'document_type',
    'safeDisplayName': 'safe_display_name',
  },
);

Map<String, dynamic> _$MediaAssetToJson(MediaAsset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'media_kind': _$MediaKindEnumMap[instance.mediaKind]!,
      'visibility': _$MediaVisibilityEnumMap[instance.visibility]!,
      'upload_status': _$UploadStatusEnumMap[instance.uploadStatus]!,
      'url': ?instance.url,
      'thumbnail_url': ?instance.thumbnailUrl,
      'sort_order': instance.sortOrder,
      'document_type': ?instance.documentType,
      'safe_display_name': ?instance.safeDisplayName,
    };

const _$MediaKindEnumMap = {
  MediaKind.image: 'image',
  MediaKind.document: 'document',
};

const _$MediaVisibilityEnumMap = {
  MediaVisibility.public: 'public',
  MediaVisibility.privateAdminOnly: 'private_admin_only',
};

const _$UploadStatusEnumMap = {
  UploadStatus.pendingUpload: 'pending_upload',
  UploadStatus.uploaded: 'uploaded',
  UploadStatus.processing: 'processing',
  UploadStatus.ready: 'ready',
  UploadStatus.failed: 'failed',
  UploadStatus.deleted: 'deleted',
};
