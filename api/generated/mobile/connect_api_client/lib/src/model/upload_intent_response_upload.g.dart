// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_intent_response_upload.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadIntentResponseUploadCWProxy {
  UploadIntentResponseUpload method(
    UploadIntentResponseUploadMethodEnum method,
  );

  UploadIntentResponseUpload url(String? url);

  UploadIntentResponseUpload headers(Map<String, String>? headers);

  UploadIntentResponseUpload expiresAt(DateTime? expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadIntentResponseUpload(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadIntentResponseUpload(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadIntentResponseUpload call({
    UploadIntentResponseUploadMethodEnum method,
    String? url,
    Map<String, String>? headers,
    DateTime? expiresAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadIntentResponseUpload.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadIntentResponseUpload.copyWith.fieldName(...)`
class _$UploadIntentResponseUploadCWProxyImpl
    implements _$UploadIntentResponseUploadCWProxy {
  const _$UploadIntentResponseUploadCWProxyImpl(this._value);

  final UploadIntentResponseUpload _value;

  @override
  UploadIntentResponseUpload method(
    UploadIntentResponseUploadMethodEnum method,
  ) => this(method: method);

  @override
  UploadIntentResponseUpload url(String? url) => this(url: url);

  @override
  UploadIntentResponseUpload headers(Map<String, String>? headers) =>
      this(headers: headers);

  @override
  UploadIntentResponseUpload expiresAt(DateTime? expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadIntentResponseUpload(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadIntentResponseUpload(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadIntentResponseUpload call({
    Object? method = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? headers = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return UploadIntentResponseUpload(
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as UploadIntentResponseUploadMethodEnum,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      headers: headers == const $CopyWithPlaceholder()
          ? _value.headers
          // ignore: cast_nullable_to_non_nullable
          : headers as Map<String, String>?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
    );
  }
}

extension $UploadIntentResponseUploadCopyWith on UploadIntentResponseUpload {
  /// Returns a callable class that can be used as follows: `instanceOfUploadIntentResponseUpload.copyWith(...)` or like so:`instanceOfUploadIntentResponseUpload.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadIntentResponseUploadCWProxy get copyWith =>
      _$UploadIntentResponseUploadCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadIntentResponseUpload _$UploadIntentResponseUploadFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UploadIntentResponseUpload', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['method']);
  final val = UploadIntentResponseUpload(
    method: $checkedConvert(
      'method',
      (v) => $enumDecode(_$UploadIntentResponseUploadMethodEnumEnumMap, v),
    ),
    url: $checkedConvert('url', (v) => v as String?),
    headers: $checkedConvert(
      'headers',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as String)),
    ),
    expiresAt: $checkedConvert(
      'expires_at',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
}, fieldKeyMap: const {'expiresAt': 'expires_at'});

Map<String, dynamic> _$UploadIntentResponseUploadToJson(
  UploadIntentResponseUpload instance,
) => <String, dynamic>{
  'method': _$UploadIntentResponseUploadMethodEnumEnumMap[instance.method]!,
  'url': ?instance.url,
  'headers': ?instance.headers,
  'expires_at': ?instance.expiresAt?.toIso8601String(),
};

const _$UploadIntentResponseUploadMethodEnumEnumMap = {
  UploadIntentResponseUploadMethodEnum.signedUrl: 'signed_url',
  UploadIntentResponseUploadMethodEnum.backendProxy: 'backend_proxy',
};
