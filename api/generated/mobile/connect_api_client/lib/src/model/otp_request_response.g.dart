// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_request_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OtpRequestResponseCWProxy {
  OtpRequestResponse otpRequestId(String otpRequestId);

  OtpRequestResponse message(String message);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpRequestResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpRequestResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpRequestResponse call({String otpRequestId, String message});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOtpRequestResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOtpRequestResponse.copyWith.fieldName(...)`
class _$OtpRequestResponseCWProxyImpl implements _$OtpRequestResponseCWProxy {
  const _$OtpRequestResponseCWProxyImpl(this._value);

  final OtpRequestResponse _value;

  @override
  OtpRequestResponse otpRequestId(String otpRequestId) =>
      this(otpRequestId: otpRequestId);

  @override
  OtpRequestResponse message(String message) => this(message: message);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpRequestResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpRequestResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpRequestResponse call({
    Object? otpRequestId = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
  }) {
    return OtpRequestResponse(
      otpRequestId: otpRequestId == const $CopyWithPlaceholder()
          ? _value.otpRequestId
          // ignore: cast_nullable_to_non_nullable
          : otpRequestId as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
    );
  }
}

extension $OtpRequestResponseCopyWith on OtpRequestResponse {
  /// Returns a callable class that can be used as follows: `instanceOfOtpRequestResponse.copyWith(...)` or like so:`instanceOfOtpRequestResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OtpRequestResponseCWProxy get copyWith =>
      _$OtpRequestResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpRequestResponse _$OtpRequestResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OtpRequestResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['otp_request_id', 'message']);
      final val = OtpRequestResponse(
        otpRequestId: $checkedConvert('otp_request_id', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'otpRequestId': 'otp_request_id'});

Map<String, dynamic> _$OtpRequestResponseToJson(OtpRequestResponse instance) =>
    <String, dynamic>{
      'otp_request_id': instance.otpRequestId,
      'message': instance.message,
    };
