// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_account_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BasicAccountRequestCWProxy {
  BasicAccountRequest displayName(String displayName);

  BasicAccountRequest acceptedTermsVersion(String acceptedTermsVersion);

  BasicAccountRequest acceptedPrivacyVersion(String acceptedPrivacyVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BasicAccountRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BasicAccountRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BasicAccountRequest call({
    String displayName,
    String acceptedTermsVersion,
    String acceptedPrivacyVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBasicAccountRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBasicAccountRequest.copyWith.fieldName(...)`
class _$BasicAccountRequestCWProxyImpl implements _$BasicAccountRequestCWProxy {
  const _$BasicAccountRequestCWProxyImpl(this._value);

  final BasicAccountRequest _value;

  @override
  BasicAccountRequest displayName(String displayName) =>
      this(displayName: displayName);

  @override
  BasicAccountRequest acceptedTermsVersion(String acceptedTermsVersion) =>
      this(acceptedTermsVersion: acceptedTermsVersion);

  @override
  BasicAccountRequest acceptedPrivacyVersion(String acceptedPrivacyVersion) =>
      this(acceptedPrivacyVersion: acceptedPrivacyVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BasicAccountRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BasicAccountRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BasicAccountRequest call({
    Object? displayName = const $CopyWithPlaceholder(),
    Object? acceptedTermsVersion = const $CopyWithPlaceholder(),
    Object? acceptedPrivacyVersion = const $CopyWithPlaceholder(),
  }) {
    return BasicAccountRequest(
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String,
      acceptedTermsVersion: acceptedTermsVersion == const $CopyWithPlaceholder()
          ? _value.acceptedTermsVersion
          // ignore: cast_nullable_to_non_nullable
          : acceptedTermsVersion as String,
      acceptedPrivacyVersion:
          acceptedPrivacyVersion == const $CopyWithPlaceholder()
          ? _value.acceptedPrivacyVersion
          // ignore: cast_nullable_to_non_nullable
          : acceptedPrivacyVersion as String,
    );
  }
}

extension $BasicAccountRequestCopyWith on BasicAccountRequest {
  /// Returns a callable class that can be used as follows: `instanceOfBasicAccountRequest.copyWith(...)` or like so:`instanceOfBasicAccountRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BasicAccountRequestCWProxy get copyWith =>
      _$BasicAccountRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicAccountRequest _$BasicAccountRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'BasicAccountRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'display_name',
            'accepted_terms_version',
            'accepted_privacy_version',
          ],
        );
        final val = BasicAccountRequest(
          displayName: $checkedConvert('display_name', (v) => v as String),
          acceptedTermsVersion: $checkedConvert(
            'accepted_terms_version',
            (v) => v as String,
          ),
          acceptedPrivacyVersion: $checkedConvert(
            'accepted_privacy_version',
            (v) => v as String,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'displayName': 'display_name',
        'acceptedTermsVersion': 'accepted_terms_version',
        'acceptedPrivacyVersion': 'accepted_privacy_version',
      },
    );

Map<String, dynamic> _$BasicAccountRequestToJson(
  BasicAccountRequest instance,
) => <String, dynamic>{
  'display_name': instance.displayName,
  'accepted_terms_version': instance.acceptedTermsVersion,
  'accepted_privacy_version': instance.acceptedPrivacyVersion,
};
