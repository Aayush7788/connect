// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_token_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RegisterDeviceTokenRequestCWProxy {
  RegisterDeviceTokenRequest fcmToken(String fcmToken);

  RegisterDeviceTokenRequest platform(
    RegisterDeviceTokenRequestPlatformEnum platform,
  );

  RegisterDeviceTokenRequest deviceId(String? deviceId);

  RegisterDeviceTokenRequest appVersion(String? appVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RegisterDeviceTokenRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RegisterDeviceTokenRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RegisterDeviceTokenRequest call({
    String fcmToken,
    RegisterDeviceTokenRequestPlatformEnum platform,
    String? deviceId,
    String? appVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRegisterDeviceTokenRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRegisterDeviceTokenRequest.copyWith.fieldName(...)`
class _$RegisterDeviceTokenRequestCWProxyImpl
    implements _$RegisterDeviceTokenRequestCWProxy {
  const _$RegisterDeviceTokenRequestCWProxyImpl(this._value);

  final RegisterDeviceTokenRequest _value;

  @override
  RegisterDeviceTokenRequest fcmToken(String fcmToken) =>
      this(fcmToken: fcmToken);

  @override
  RegisterDeviceTokenRequest platform(
    RegisterDeviceTokenRequestPlatformEnum platform,
  ) => this(platform: platform);

  @override
  RegisterDeviceTokenRequest deviceId(String? deviceId) =>
      this(deviceId: deviceId);

  @override
  RegisterDeviceTokenRequest appVersion(String? appVersion) =>
      this(appVersion: appVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RegisterDeviceTokenRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RegisterDeviceTokenRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RegisterDeviceTokenRequest call({
    Object? fcmToken = const $CopyWithPlaceholder(),
    Object? platform = const $CopyWithPlaceholder(),
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? appVersion = const $CopyWithPlaceholder(),
  }) {
    return RegisterDeviceTokenRequest(
      fcmToken: fcmToken == const $CopyWithPlaceholder()
          ? _value.fcmToken
          // ignore: cast_nullable_to_non_nullable
          : fcmToken as String,
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as RegisterDeviceTokenRequestPlatformEnum,
      deviceId: deviceId == const $CopyWithPlaceholder()
          ? _value.deviceId
          // ignore: cast_nullable_to_non_nullable
          : deviceId as String?,
      appVersion: appVersion == const $CopyWithPlaceholder()
          ? _value.appVersion
          // ignore: cast_nullable_to_non_nullable
          : appVersion as String?,
    );
  }
}

extension $RegisterDeviceTokenRequestCopyWith on RegisterDeviceTokenRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRegisterDeviceTokenRequest.copyWith(...)` or like so:`instanceOfRegisterDeviceTokenRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RegisterDeviceTokenRequestCWProxy get copyWith =>
      _$RegisterDeviceTokenRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterDeviceTokenRequest _$RegisterDeviceTokenRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'RegisterDeviceTokenRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['fcm_token', 'platform']);
    final val = RegisterDeviceTokenRequest(
      fcmToken: $checkedConvert('fcm_token', (v) => v as String),
      platform: $checkedConvert(
        'platform',
        (v) => $enumDecode(_$RegisterDeviceTokenRequestPlatformEnumEnumMap, v),
      ),
      deviceId: $checkedConvert('device_id', (v) => v as String?),
      appVersion: $checkedConvert('app_version', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'fcmToken': 'fcm_token',
    'deviceId': 'device_id',
    'appVersion': 'app_version',
  },
);

Map<String, dynamic> _$RegisterDeviceTokenRequestToJson(
  RegisterDeviceTokenRequest instance,
) => <String, dynamic>{
  'fcm_token': instance.fcmToken,
  'platform':
      _$RegisterDeviceTokenRequestPlatformEnumEnumMap[instance.platform]!,
  'device_id': ?instance.deviceId,
  'app_version': ?instance.appVersion,
};

const _$RegisterDeviceTokenRequestPlatformEnumEnumMap = {
  RegisterDeviceTokenRequestPlatformEnum.android: 'android',
};
