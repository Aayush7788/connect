// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_submit_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VerificationSubmitRequestCWProxy {
  VerificationSubmitRequest consentVersion(String? consentVersion);

  VerificationSubmitRequest consentAccepted(bool? consentAccepted);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationSubmitRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationSubmitRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationSubmitRequest call({
    String? consentVersion,
    bool? consentAccepted,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVerificationSubmitRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVerificationSubmitRequest.copyWith.fieldName(...)`
class _$VerificationSubmitRequestCWProxyImpl
    implements _$VerificationSubmitRequestCWProxy {
  const _$VerificationSubmitRequestCWProxyImpl(this._value);

  final VerificationSubmitRequest _value;

  @override
  VerificationSubmitRequest consentVersion(String? consentVersion) =>
      this(consentVersion: consentVersion);

  @override
  VerificationSubmitRequest consentAccepted(bool? consentAccepted) =>
      this(consentAccepted: consentAccepted);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationSubmitRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationSubmitRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationSubmitRequest call({
    Object? consentVersion = const $CopyWithPlaceholder(),
    Object? consentAccepted = const $CopyWithPlaceholder(),
  }) {
    return VerificationSubmitRequest(
      consentVersion: consentVersion == const $CopyWithPlaceholder()
          ? _value.consentVersion
          // ignore: cast_nullable_to_non_nullable
          : consentVersion as String?,
      consentAccepted: consentAccepted == const $CopyWithPlaceholder()
          ? _value.consentAccepted
          // ignore: cast_nullable_to_non_nullable
          : consentAccepted as bool?,
    );
  }
}

extension $VerificationSubmitRequestCopyWith on VerificationSubmitRequest {
  /// Returns a callable class that can be used as follows: `instanceOfVerificationSubmitRequest.copyWith(...)` or like so:`instanceOfVerificationSubmitRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VerificationSubmitRequestCWProxy get copyWith =>
      _$VerificationSubmitRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationSubmitRequest _$VerificationSubmitRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'VerificationSubmitRequest',
  json,
  ($checkedConvert) {
    final val = VerificationSubmitRequest(
      consentVersion: $checkedConvert('consent_version', (v) => v as String?),
      consentAccepted: $checkedConvert(
        'consent_accepted',
        (v) => v as bool? ?? false,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'consentVersion': 'consent_version',
    'consentAccepted': 'consent_accepted',
  },
);

Map<String, dynamic> _$VerificationSubmitRequestToJson(
  VerificationSubmitRequest instance,
) => <String, dynamic>{
  'consent_version': ?instance.consentVersion,
  'consent_accepted': ?instance.consentAccepted,
};
