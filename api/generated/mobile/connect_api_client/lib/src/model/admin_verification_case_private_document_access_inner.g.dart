// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_verification_case_private_document_access_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminVerificationCasePrivateDocumentAccessInnerCWProxy {
  AdminVerificationCasePrivateDocumentAccessInner mediaAssetId(
    String? mediaAssetId,
  );

  AdminVerificationCasePrivateDocumentAccessInner accessUrl(String? accessUrl);

  AdminVerificationCasePrivateDocumentAccessInner expiresAt(
    DateTime? expiresAt,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminVerificationCasePrivateDocumentAccessInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminVerificationCasePrivateDocumentAccessInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminVerificationCasePrivateDocumentAccessInner call({
    String? mediaAssetId,
    String? accessUrl,
    DateTime? expiresAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminVerificationCasePrivateDocumentAccessInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminVerificationCasePrivateDocumentAccessInner.copyWith.fieldName(...)`
class _$AdminVerificationCasePrivateDocumentAccessInnerCWProxyImpl
    implements _$AdminVerificationCasePrivateDocumentAccessInnerCWProxy {
  const _$AdminVerificationCasePrivateDocumentAccessInnerCWProxyImpl(
    this._value,
  );

  final AdminVerificationCasePrivateDocumentAccessInner _value;

  @override
  AdminVerificationCasePrivateDocumentAccessInner mediaAssetId(
    String? mediaAssetId,
  ) => this(mediaAssetId: mediaAssetId);

  @override
  AdminVerificationCasePrivateDocumentAccessInner accessUrl(
    String? accessUrl,
  ) => this(accessUrl: accessUrl);

  @override
  AdminVerificationCasePrivateDocumentAccessInner expiresAt(
    DateTime? expiresAt,
  ) => this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminVerificationCasePrivateDocumentAccessInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminVerificationCasePrivateDocumentAccessInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminVerificationCasePrivateDocumentAccessInner call({
    Object? mediaAssetId = const $CopyWithPlaceholder(),
    Object? accessUrl = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return AdminVerificationCasePrivateDocumentAccessInner(
      mediaAssetId: mediaAssetId == const $CopyWithPlaceholder()
          ? _value.mediaAssetId
          // ignore: cast_nullable_to_non_nullable
          : mediaAssetId as String?,
      accessUrl: accessUrl == const $CopyWithPlaceholder()
          ? _value.accessUrl
          // ignore: cast_nullable_to_non_nullable
          : accessUrl as String?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
    );
  }
}

extension $AdminVerificationCasePrivateDocumentAccessInnerCopyWith
    on AdminVerificationCasePrivateDocumentAccessInner {
  /// Returns a callable class that can be used as follows: `instanceOfAdminVerificationCasePrivateDocumentAccessInner.copyWith(...)` or like so:`instanceOfAdminVerificationCasePrivateDocumentAccessInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminVerificationCasePrivateDocumentAccessInnerCWProxy get copyWith =>
      _$AdminVerificationCasePrivateDocumentAccessInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminVerificationCasePrivateDocumentAccessInner
_$AdminVerificationCasePrivateDocumentAccessInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdminVerificationCasePrivateDocumentAccessInner',
  json,
  ($checkedConvert) {
    final val = AdminVerificationCasePrivateDocumentAccessInner(
      mediaAssetId: $checkedConvert('media_asset_id', (v) => v as String?),
      accessUrl: $checkedConvert('access_url', (v) => v as String?),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'mediaAssetId': 'media_asset_id',
    'accessUrl': 'access_url',
    'expiresAt': 'expires_at',
  },
);

Map<String, dynamic> _$AdminVerificationCasePrivateDocumentAccessInnerToJson(
  AdminVerificationCasePrivateDocumentAccessInner instance,
) => <String, dynamic>{
  'media_asset_id': ?instance.mediaAssetId,
  'access_url': ?instance.accessUrl,
  'expires_at': ?instance.expiresAt?.toIso8601String(),
};
