// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OtpRequestCWProxy {
  OtpRequest mobile(String mobile);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpRequest call({String mobile});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOtpRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOtpRequest.copyWith.fieldName(...)`
class _$OtpRequestCWProxyImpl implements _$OtpRequestCWProxy {
  const _$OtpRequestCWProxyImpl(this._value);

  final OtpRequest _value;

  @override
  OtpRequest mobile(String mobile) => this(mobile: mobile);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpRequest call({Object? mobile = const $CopyWithPlaceholder()}) {
    return OtpRequest(
      mobile: mobile == const $CopyWithPlaceholder()
          ? _value.mobile
          // ignore: cast_nullable_to_non_nullable
          : mobile as String,
    );
  }
}

extension $OtpRequestCopyWith on OtpRequest {
  /// Returns a callable class that can be used as follows: `instanceOfOtpRequest.copyWith(...)` or like so:`instanceOfOtpRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OtpRequestCWProxy get copyWith => _$OtpRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpRequest _$OtpRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OtpRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['mobile']);
      final val = OtpRequest(
        mobile: $checkedConvert('mobile', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$OtpRequestToJson(OtpRequest instance) =>
    <String, dynamic>{'mobile': instance.mobile};
