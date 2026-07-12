// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_details.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadDetailsCWProxy {
  UploadDetails method(UploadDetailsMethodEnum method);

  UploadDetails httpMethod(UploadDetailsHttpMethodEnum httpMethod);

  UploadDetails formField(UploadDetailsFormFieldEnum formField);

  UploadDetails url(String url);

  UploadDetails headers(Map<String, String> headers);

  UploadDetails expiresAt(DateTime expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadDetails(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadDetails call({
    UploadDetailsMethodEnum method,
    UploadDetailsHttpMethodEnum httpMethod,
    UploadDetailsFormFieldEnum formField,
    String url,
    Map<String, String> headers,
    DateTime expiresAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadDetails.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadDetails.copyWith.fieldName(...)`
class _$UploadDetailsCWProxyImpl implements _$UploadDetailsCWProxy {
  const _$UploadDetailsCWProxyImpl(this._value);

  final UploadDetails _value;

  @override
  UploadDetails method(UploadDetailsMethodEnum method) => this(method: method);

  @override
  UploadDetails httpMethod(UploadDetailsHttpMethodEnum httpMethod) =>
      this(httpMethod: httpMethod);

  @override
  UploadDetails formField(UploadDetailsFormFieldEnum formField) =>
      this(formField: formField);

  @override
  UploadDetails url(String url) => this(url: url);

  @override
  UploadDetails headers(Map<String, String> headers) => this(headers: headers);

  @override
  UploadDetails expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadDetails(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadDetails call({
    Object? method = const $CopyWithPlaceholder(),
    Object? httpMethod = const $CopyWithPlaceholder(),
    Object? formField = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? headers = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return UploadDetails(
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as UploadDetailsMethodEnum,
      httpMethod: httpMethod == const $CopyWithPlaceholder()
          ? _value.httpMethod
          // ignore: cast_nullable_to_non_nullable
          : httpMethod as UploadDetailsHttpMethodEnum,
      formField: formField == const $CopyWithPlaceholder()
          ? _value.formField
          // ignore: cast_nullable_to_non_nullable
          : formField as UploadDetailsFormFieldEnum,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      headers: headers == const $CopyWithPlaceholder()
          ? _value.headers
          // ignore: cast_nullable_to_non_nullable
          : headers as Map<String, String>,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $UploadDetailsCopyWith on UploadDetails {
  /// Returns a callable class that can be used as follows: `instanceOfUploadDetails.copyWith(...)` or like so:`instanceOfUploadDetails.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadDetailsCWProxy get copyWith => _$UploadDetailsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadDetails _$UploadDetailsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'UploadDetails',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'method',
            'http_method',
            'form_field',
            'url',
            'headers',
            'expires_at',
          ],
        );
        final val = UploadDetails(
          method: $checkedConvert(
            'method',
            (v) => $enumDecode(_$UploadDetailsMethodEnumEnumMap, v),
          ),
          httpMethod: $checkedConvert(
            'http_method',
            (v) => $enumDecode(_$UploadDetailsHttpMethodEnumEnumMap, v),
          ),
          formField: $checkedConvert(
            'form_field',
            (v) => $enumDecode(_$UploadDetailsFormFieldEnumEnumMap, v),
          ),
          url: $checkedConvert('url', (v) => v as String),
          headers: $checkedConvert(
            'headers',
            (v) => Map<String, String>.from(v as Map),
          ),
          expiresAt: $checkedConvert(
            'expires_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'httpMethod': 'http_method',
        'formField': 'form_field',
        'expiresAt': 'expires_at',
      },
    );

Map<String, dynamic> _$UploadDetailsToJson(UploadDetails instance) =>
    <String, dynamic>{
      'method': _$UploadDetailsMethodEnumEnumMap[instance.method]!,
      'http_method': _$UploadDetailsHttpMethodEnumEnumMap[instance.httpMethod]!,
      'form_field': _$UploadDetailsFormFieldEnumEnumMap[instance.formField]!,
      'url': instance.url,
      'headers': instance.headers,
      'expires_at': instance.expiresAt.toIso8601String(),
    };

const _$UploadDetailsMethodEnumEnumMap = {
  UploadDetailsMethodEnum.signedUrl: 'signed_url',
};

const _$UploadDetailsHttpMethodEnumEnumMap = {
  UploadDetailsHttpMethodEnum.PUT: 'PUT',
};

const _$UploadDetailsFormFieldEnumEnumMap = {
  UploadDetailsFormFieldEnum.file: 'file',
};
