// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_settings_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateSettingsRequestCWProxy {
  UpdateSettingsRequest pushNotificationsEnabled(
    bool? pushNotificationsEnabled,
  );

  UpdateSettingsRequest hiddenFromSearch(bool? hiddenFromSearch);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateSettingsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateSettingsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateSettingsRequest call({
    bool? pushNotificationsEnabled,
    bool? hiddenFromSearch,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateSettingsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateSettingsRequest.copyWith.fieldName(...)`
class _$UpdateSettingsRequestCWProxyImpl
    implements _$UpdateSettingsRequestCWProxy {
  const _$UpdateSettingsRequestCWProxyImpl(this._value);

  final UpdateSettingsRequest _value;

  @override
  UpdateSettingsRequest pushNotificationsEnabled(
    bool? pushNotificationsEnabled,
  ) => this(pushNotificationsEnabled: pushNotificationsEnabled);

  @override
  UpdateSettingsRequest hiddenFromSearch(bool? hiddenFromSearch) =>
      this(hiddenFromSearch: hiddenFromSearch);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateSettingsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateSettingsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateSettingsRequest call({
    Object? pushNotificationsEnabled = const $CopyWithPlaceholder(),
    Object? hiddenFromSearch = const $CopyWithPlaceholder(),
  }) {
    return UpdateSettingsRequest(
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

extension $UpdateSettingsRequestCopyWith on UpdateSettingsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateSettingsRequest.copyWith(...)` or like so:`instanceOfUpdateSettingsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateSettingsRequestCWProxy get copyWith =>
      _$UpdateSettingsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateSettingsRequest _$UpdateSettingsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'UpdateSettingsRequest',
  json,
  ($checkedConvert) {
    final val = UpdateSettingsRequest(
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

Map<String, dynamic> _$UpdateSettingsRequestToJson(
  UpdateSettingsRequest instance,
) => <String, dynamic>{
  'push_notifications_enabled': ?instance.pushNotificationsEnabled,
  'hidden_from_search': ?instance.hiddenFromSearch,
};
