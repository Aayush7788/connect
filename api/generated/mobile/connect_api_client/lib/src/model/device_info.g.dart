// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeviceInfoCWProxy {
  DeviceInfo deviceId(String? deviceId);

  DeviceInfo platform(DeviceInfoPlatformEnum? platform);

  DeviceInfo appVersion(String? appVersion);

  DeviceInfo fcmToken(String? fcmToken);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceInfo call({
    String? deviceId,
    DeviceInfoPlatformEnum? platform,
    String? appVersion,
    String? fcmToken,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeviceInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeviceInfo.copyWith.fieldName(...)`
class _$DeviceInfoCWProxyImpl implements _$DeviceInfoCWProxy {
  const _$DeviceInfoCWProxyImpl(this._value);

  final DeviceInfo _value;

  @override
  DeviceInfo deviceId(String? deviceId) => this(deviceId: deviceId);

  @override
  DeviceInfo platform(DeviceInfoPlatformEnum? platform) =>
      this(platform: platform);

  @override
  DeviceInfo appVersion(String? appVersion) => this(appVersion: appVersion);

  @override
  DeviceInfo fcmToken(String? fcmToken) => this(fcmToken: fcmToken);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeviceInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeviceInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  DeviceInfo call({
    Object? deviceId = const $CopyWithPlaceholder(),
    Object? platform = const $CopyWithPlaceholder(),
    Object? appVersion = const $CopyWithPlaceholder(),
    Object? fcmToken = const $CopyWithPlaceholder(),
  }) {
    return DeviceInfo(
      deviceId: deviceId == const $CopyWithPlaceholder()
          ? _value.deviceId
          // ignore: cast_nullable_to_non_nullable
          : deviceId as String?,
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as DeviceInfoPlatformEnum?,
      appVersion: appVersion == const $CopyWithPlaceholder()
          ? _value.appVersion
          // ignore: cast_nullable_to_non_nullable
          : appVersion as String?,
      fcmToken: fcmToken == const $CopyWithPlaceholder()
          ? _value.fcmToken
          // ignore: cast_nullable_to_non_nullable
          : fcmToken as String?,
    );
  }
}

extension $DeviceInfoCopyWith on DeviceInfo {
  /// Returns a callable class that can be used as follows: `instanceOfDeviceInfo.copyWith(...)` or like so:`instanceOfDeviceInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeviceInfoCWProxy get copyWith => _$DeviceInfoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'DeviceInfo',
  json,
  ($checkedConvert) {
    final val = DeviceInfo(
      deviceId: $checkedConvert('device_id', (v) => v as String?),
      platform: $checkedConvert(
        'platform',
        (v) => $enumDecodeNullable(_$DeviceInfoPlatformEnumEnumMap, v),
      ),
      appVersion: $checkedConvert('app_version', (v) => v as String?),
      fcmToken: $checkedConvert('fcm_token', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'deviceId': 'device_id',
    'appVersion': 'app_version',
    'fcmToken': 'fcm_token',
  },
);

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      'device_id': ?instance.deviceId,
      'platform': ?_$DeviceInfoPlatformEnumEnumMap[instance.platform],
      'app_version': ?instance.appVersion,
      'fcm_token': ?instance.fcmToken,
    };

const _$DeviceInfoPlatformEnumEnumMap = {
  DeviceInfoPlatformEnum.android: 'android',
};
