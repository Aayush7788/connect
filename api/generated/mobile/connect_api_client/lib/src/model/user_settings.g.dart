// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UserSettingsCWProxy {
  UserSettings pushNotificationsEnabled(bool? pushNotificationsEnabled);

  UserSettings hiddenFromSearch(bool? hiddenFromSearch);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  UserSettings call({bool? pushNotificationsEnabled, bool? hiddenFromSearch});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUserSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUserSettings.copyWith.fieldName(...)`
class _$UserSettingsCWProxyImpl implements _$UserSettingsCWProxy {
  const _$UserSettingsCWProxyImpl(this._value);

  final UserSettings _value;

  @override
  UserSettings pushNotificationsEnabled(bool? pushNotificationsEnabled) =>
      this(pushNotificationsEnabled: pushNotificationsEnabled);

  @override
  UserSettings hiddenFromSearch(bool? hiddenFromSearch) =>
      this(hiddenFromSearch: hiddenFromSearch);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  UserSettings call({
    Object? pushNotificationsEnabled = const $CopyWithPlaceholder(),
    Object? hiddenFromSearch = const $CopyWithPlaceholder(),
  }) {
    return UserSettings(
      pushNotificationsEnabled:
          pushNotificationsEnabled == const $CopyWithPlaceholder()
          ? _value.pushNotificationsEnabled
          // ignore: cast_nullable_to_non_nullable
          : pushNotificationsEnabled as bool?,
      hiddenFromSearch: hiddenFromSearch == const $CopyWithPlaceholder()
          ? _value.hiddenFromSearch
          // ignore: cast_nullable_to_non_nullable
          : hiddenFromSearch as bool?,
    );
  }
}

extension $UserSettingsCopyWith on UserSettings {
  /// Returns a callable class that can be used as follows: `instanceOfUserSettings.copyWith(...)` or like so:`instanceOfUserSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UserSettingsCWProxy get copyWith => _$UserSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'UserSettings',
      json,
      ($checkedConvert) {
        final val = UserSettings(
          pushNotificationsEnabled: $checkedConvert(
            'push_notifications_enabled',
            (v) => v as bool?,
          ),
          hiddenFromSearch: $checkedConvert(
            'hidden_from_search',
            (v) => v as bool?,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'pushNotificationsEnabled': 'push_notifications_enabled',
        'hiddenFromSearch': 'hidden_from_search',
      },
    );

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'push_notifications_enabled': ?instance.pushNotificationsEnabled,
      'hidden_from_search': ?instance.hiddenFromSearch,
    };
