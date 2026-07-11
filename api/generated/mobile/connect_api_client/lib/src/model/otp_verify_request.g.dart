// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verify_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OtpVerifyRequestCWProxy {
  OtpVerifyRequest mobile(String mobile);

  OtpVerifyRequest otp(String otp);

  OtpVerifyRequest otpRequestId(String otpRequestId);

  OtpVerifyRequest device(DeviceInfo? device);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpVerifyRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpVerifyRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpVerifyRequest call({
    String mobile,
    String otp,
    String otpRequestId,
    DeviceInfo? device,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOtpVerifyRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOtpVerifyRequest.copyWith.fieldName(...)`
class _$OtpVerifyRequestCWProxyImpl implements _$OtpVerifyRequestCWProxy {
  const _$OtpVerifyRequestCWProxyImpl(this._value);

  final OtpVerifyRequest _value;

  @override
  OtpVerifyRequest mobile(String mobile) => this(mobile: mobile);

  @override
  OtpVerifyRequest otp(String otp) => this(otp: otp);

  @override
  OtpVerifyRequest otpRequestId(String otpRequestId) =>
      this(otpRequestId: otpRequestId);

  @override
  OtpVerifyRequest device(DeviceInfo? device) => this(device: device);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpVerifyRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpVerifyRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpVerifyRequest call({
    Object? mobile = const $CopyWithPlaceholder(),
    Object? otp = const $CopyWithPlaceholder(),
    Object? otpRequestId = const $CopyWithPlaceholder(),
    Object? device = const $CopyWithPlaceholder(),
  }) {
    return OtpVerifyRequest(
      mobile: mobile == const $CopyWithPlaceholder()
          ? _value.mobile
          // ignore: cast_nullable_to_non_nullable
          : mobile as String,
      otp: otp == const $CopyWithPlaceholder()
          ? _value.otp
          // ignore: cast_nullable_to_non_nullable
          : otp as String,
      otpRequestId: otpRequestId == const $CopyWithPlaceholder()
          ? _value.otpRequestId
          // ignore: cast_nullable_to_non_nullable
          : otpRequestId as String,
      device: device == const $CopyWithPlaceholder()
          ? _value.device
          // ignore: cast_nullable_to_non_nullable
          : device as DeviceInfo?,
    );
  }
}

extension $OtpVerifyRequestCopyWith on OtpVerifyRequest {
  /// Returns a callable class that can be used as follows: `instanceOfOtpVerifyRequest.copyWith(...)` or like so:`instanceOfOtpVerifyRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OtpVerifyRequestCWProxy get copyWith => _$OtpVerifyRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpVerifyRequest _$OtpVerifyRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OtpVerifyRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['mobile', 'otp', 'otp_request_id']);
      final val = OtpVerifyRequest(
        mobile: $checkedConvert('mobile', (v) => v as String),
        otp: $checkedConvert('otp', (v) => v as String),
        otpRequestId: $checkedConvert('otp_request_id', (v) => v as String),
        device: $checkedConvert(
          'device',
          (v) =>
              v == null ? null : DeviceInfo.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'otpRequestId': 'otp_request_id'});

Map<String, dynamic> _$OtpVerifyRequestToJson(OtpVerifyRequest instance) =>
    <String, dynamic>{
      'mobile': instance.mobile,
      'otp': instance.otp,
      'otp_request_id': instance.otpRequestId,
      'device': ?instance.device?.toJson(),
    };
