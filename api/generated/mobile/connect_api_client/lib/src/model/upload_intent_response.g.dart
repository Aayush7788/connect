// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_intent_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadIntentResponseCWProxy {
  UploadIntentResponse mediaAsset(MediaAsset mediaAsset);

  UploadIntentResponse upload(UploadIntentResponseUpload upload);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadIntentResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadIntentResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadIntentResponse call({
    MediaAsset mediaAsset,
    UploadIntentResponseUpload upload,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadIntentResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadIntentResponse.copyWith.fieldName(...)`
class _$UploadIntentResponseCWProxyImpl
    implements _$UploadIntentResponseCWProxy {
  const _$UploadIntentResponseCWProxyImpl(this._value);

  final UploadIntentResponse _value;

  @override
  UploadIntentResponse mediaAsset(MediaAsset mediaAsset) =>
      this(mediaAsset: mediaAsset);

  @override
  UploadIntentResponse upload(UploadIntentResponseUpload upload) =>
      this(upload: upload);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadIntentResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadIntentResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadIntentResponse call({
    Object? mediaAsset = const $CopyWithPlaceholder(),
    Object? upload = const $CopyWithPlaceholder(),
  }) {
    return UploadIntentResponse(
      mediaAsset: mediaAsset == const $CopyWithPlaceholder()
          ? _value.mediaAsset
          // ignore: cast_nullable_to_non_nullable
          : mediaAsset as MediaAsset,
      upload: upload == const $CopyWithPlaceholder()
          ? _value.upload
          // ignore: cast_nullable_to_non_nullable
          : upload as UploadIntentResponseUpload,
    );
  }
}

extension $UploadIntentResponseCopyWith on UploadIntentResponse {
  /// Returns a callable class that can be used as follows: `instanceOfUploadIntentResponse.copyWith(...)` or like so:`instanceOfUploadIntentResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadIntentResponseCWProxy get copyWith =>
      _$UploadIntentResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadIntentResponse _$UploadIntentResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UploadIntentResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['media_asset', 'upload']);
  final val = UploadIntentResponse(
    mediaAsset: $checkedConvert(
      'media_asset',
      (v) => MediaAsset.fromJson(v as Map<String, dynamic>),
    ),
    upload: $checkedConvert(
      'upload',
      (v) => UploadIntentResponseUpload.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
}, fieldKeyMap: const {'mediaAsset': 'media_asset'});

Map<String, dynamic> _$UploadIntentResponseToJson(
  UploadIntentResponse instance,
) => <String, dynamic>{
  'media_asset': instance.mediaAsset.toJson(),
  'upload': instance.upload.toJson(),
};
