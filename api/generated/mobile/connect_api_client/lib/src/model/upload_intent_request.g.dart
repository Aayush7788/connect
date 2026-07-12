// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_intent_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadIntentRequestCWProxy {
  UploadIntentRequest entityType(UploadIntentRequestEntityTypeEnum entityType);

  UploadIntentRequest entityId(String entityId);

  UploadIntentRequest mediaKind(MediaKind mediaKind);

  UploadIntentRequest visibility(MediaVisibility visibility);

  UploadIntentRequest documentType(
    UploadIntentRequestDocumentTypeEnum? documentType,
  );

  UploadIntentRequest filename(String filename);

  UploadIntentRequest mimeType(UploadIntentRequestMimeTypeEnum mimeType);

  UploadIntentRequest byteSize(int byteSize);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadIntentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadIntentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadIntentRequest call({
    UploadIntentRequestEntityTypeEnum entityType,
    String entityId,
    MediaKind mediaKind,
    MediaVisibility visibility,
    UploadIntentRequestDocumentTypeEnum? documentType,
    String filename,
    UploadIntentRequestMimeTypeEnum mimeType,
    int byteSize,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadIntentRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadIntentRequest.copyWith.fieldName(...)`
class _$UploadIntentRequestCWProxyImpl implements _$UploadIntentRequestCWProxy {
  const _$UploadIntentRequestCWProxyImpl(this._value);

  final UploadIntentRequest _value;

  @override
  UploadIntentRequest entityType(
    UploadIntentRequestEntityTypeEnum entityType,
  ) => this(entityType: entityType);

  @override
  UploadIntentRequest entityId(String entityId) => this(entityId: entityId);

  @override
  UploadIntentRequest mediaKind(MediaKind mediaKind) =>
      this(mediaKind: mediaKind);

  @override
  UploadIntentRequest visibility(MediaVisibility visibility) =>
      this(visibility: visibility);

  @override
  UploadIntentRequest documentType(
    UploadIntentRequestDocumentTypeEnum? documentType,
  ) => this(documentType: documentType);

  @override
  UploadIntentRequest filename(String filename) => this(filename: filename);

  @override
  UploadIntentRequest mimeType(UploadIntentRequestMimeTypeEnum mimeType) =>
      this(mimeType: mimeType);

  @override
  UploadIntentRequest byteSize(int byteSize) => this(byteSize: byteSize);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadIntentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadIntentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadIntentRequest call({
    Object? entityType = const $CopyWithPlaceholder(),
    Object? entityId = const $CopyWithPlaceholder(),
    Object? mediaKind = const $CopyWithPlaceholder(),
    Object? visibility = const $CopyWithPlaceholder(),
    Object? documentType = const $CopyWithPlaceholder(),
    Object? filename = const $CopyWithPlaceholder(),
    Object? mimeType = const $CopyWithPlaceholder(),
    Object? byteSize = const $CopyWithPlaceholder(),
  }) {
    return UploadIntentRequest(
      entityType: entityType == const $CopyWithPlaceholder()
          ? _value.entityType
          // ignore: cast_nullable_to_non_nullable
          : entityType as UploadIntentRequestEntityTypeEnum,
      entityId: entityId == const $CopyWithPlaceholder()
          ? _value.entityId
          // ignore: cast_nullable_to_non_nullable
          : entityId as String,
      mediaKind: mediaKind == const $CopyWithPlaceholder()
          ? _value.mediaKind
          // ignore: cast_nullable_to_non_nullable
          : mediaKind as MediaKind,
      visibility: visibility == const $CopyWithPlaceholder()
          ? _value.visibility
          // ignore: cast_nullable_to_non_nullable
          : visibility as MediaVisibility,
      documentType: documentType == const $CopyWithPlaceholder()
          ? _value.documentType
          // ignore: cast_nullable_to_non_nullable
          : documentType as UploadIntentRequestDocumentTypeEnum?,
      filename: filename == const $CopyWithPlaceholder()
          ? _value.filename
          // ignore: cast_nullable_to_non_nullable
          : filename as String,
      mimeType: mimeType == const $CopyWithPlaceholder()
          ? _value.mimeType
          // ignore: cast_nullable_to_non_nullable
          : mimeType as UploadIntentRequestMimeTypeEnum,
      byteSize: byteSize == const $CopyWithPlaceholder()
          ? _value.byteSize
          // ignore: cast_nullable_to_non_nullable
          : byteSize as int,
    );
  }
}

extension $UploadIntentRequestCopyWith on UploadIntentRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUploadIntentRequest.copyWith(...)` or like so:`instanceOfUploadIntentRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadIntentRequestCWProxy get copyWith =>
      _$UploadIntentRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadIntentRequest _$UploadIntentRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'UploadIntentRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'entity_type',
            'entity_id',
            'media_kind',
            'visibility',
            'filename',
            'mime_type',
            'byte_size',
          ],
        );
        final val = UploadIntentRequest(
          entityType: $checkedConvert(
            'entity_type',
            (v) => $enumDecode(_$UploadIntentRequestEntityTypeEnumEnumMap, v),
          ),
          entityId: $checkedConvert('entity_id', (v) => v as String),
          mediaKind: $checkedConvert(
            'media_kind',
            (v) => $enumDecode(_$MediaKindEnumMap, v),
          ),
          visibility: $checkedConvert(
            'visibility',
            (v) => $enumDecode(_$MediaVisibilityEnumMap, v),
          ),
          documentType: $checkedConvert(
            'document_type',
            (v) => $enumDecodeNullable(
              _$UploadIntentRequestDocumentTypeEnumEnumMap,
              v,
            ),
          ),
          filename: $checkedConvert('filename', (v) => v as String),
          mimeType: $checkedConvert(
            'mime_type',
            (v) => $enumDecode(_$UploadIntentRequestMimeTypeEnumEnumMap, v),
          ),
          byteSize: $checkedConvert('byte_size', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'entityType': 'entity_type',
        'entityId': 'entity_id',
        'mediaKind': 'media_kind',
        'documentType': 'document_type',
        'mimeType': 'mime_type',
        'byteSize': 'byte_size',
      },
    );

Map<String, dynamic> _$UploadIntentRequestToJson(
  UploadIntentRequest instance,
) => <String, dynamic>{
  'entity_type':
      _$UploadIntentRequestEntityTypeEnumEnumMap[instance.entityType]!,
  'entity_id': instance.entityId,
  'media_kind': _$MediaKindEnumMap[instance.mediaKind]!,
  'visibility': _$MediaVisibilityEnumMap[instance.visibility]!,
  'document_type':
      ?_$UploadIntentRequestDocumentTypeEnumEnumMap[instance.documentType],
  'filename': instance.filename,
  'mime_type': _$UploadIntentRequestMimeTypeEnumEnumMap[instance.mimeType]!,
  'byte_size': instance.byteSize,
};

const _$UploadIntentRequestEntityTypeEnumEnumMap = {
  UploadIntentRequestEntityTypeEnum.profile: 'profile',
  UploadIntentRequestEntityTypeEnum.workCard: 'work_card',
  UploadIntentRequestEntityTypeEnum.workNeededPost: 'work_needed_post',
  UploadIntentRequestEntityTypeEnum.verificationCase: 'verification_case',
};

const _$MediaKindEnumMap = {
  MediaKind.image: 'image',
  MediaKind.document: 'document',
};

const _$MediaVisibilityEnumMap = {
  MediaVisibility.public: 'public',
  MediaVisibility.privateAdminOnly: 'private_admin_only',
};

const _$UploadIntentRequestDocumentTypeEnumEnumMap = {
  UploadIntentRequestDocumentTypeEnum.identityProof: 'identity_proof',
  UploadIntentRequestDocumentTypeEnum.maskedAadhaar: 'masked_aadhaar',
  UploadIntentRequestDocumentTypeEnum.gstProof: 'gst_proof',
  UploadIntentRequestDocumentTypeEnum.shopPhoto: 'shop_photo',
  UploadIntentRequestDocumentTypeEnum.workplacePhoto: 'workplace_photo',
  UploadIntentRequestDocumentTypeEnum.workPhoto: 'work_photo',
  UploadIntentRequestDocumentTypeEnum.other: 'other',
};

const _$UploadIntentRequestMimeTypeEnumEnumMap = {
  UploadIntentRequestMimeTypeEnum.imageSlashJpeg: 'image/jpeg',
  UploadIntentRequestMimeTypeEnum.imageSlashPng: 'image/png',
  UploadIntentRequestMimeTypeEnum.imageSlashWebp: 'image/webp',
  UploadIntentRequestMimeTypeEnum.applicationSlashPdf: 'application/pdf',
};
