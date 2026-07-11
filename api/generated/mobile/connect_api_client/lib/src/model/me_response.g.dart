// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeResponseCWProxy {
  MeResponse user(User user);

  MeResponse profile(ProfileSummary? profile);

  MeResponse unreadNotificationCount(int? unreadNotificationCount);

  MeResponse allowedActions(List<String>? allowedActions);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MeResponse call({
    User user,
    ProfileSummary? profile,
    int? unreadNotificationCount,
    List<String>? allowedActions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeResponse.copyWith.fieldName(...)`
class _$MeResponseCWProxyImpl implements _$MeResponseCWProxy {
  const _$MeResponseCWProxyImpl(this._value);

  final MeResponse _value;

  @override
  MeResponse user(User user) => this(user: user);

  @override
  MeResponse profile(ProfileSummary? profile) => this(profile: profile);

  @override
  MeResponse unreadNotificationCount(int? unreadNotificationCount) =>
      this(unreadNotificationCount: unreadNotificationCount);

  @override
  MeResponse allowedActions(List<String>? allowedActions) =>
      this(allowedActions: allowedActions);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MeResponse call({
    Object? user = const $CopyWithPlaceholder(),
    Object? profile = const $CopyWithPlaceholder(),
    Object? unreadNotificationCount = const $CopyWithPlaceholder(),
    Object? allowedActions = const $CopyWithPlaceholder(),
  }) {
    return MeResponse(
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as User,
      profile: profile == const $CopyWithPlaceholder()
          ? _value.profile
          // ignore: cast_nullable_to_non_nullable
          : profile as ProfileSummary?,
      unreadNotificationCount:
          unreadNotificationCount == const $CopyWithPlaceholder()
          ? _value.unreadNotificationCount
          // ignore: cast_nullable_to_non_nullable
          : unreadNotificationCount as int?,
      allowedActions: allowedActions == const $CopyWithPlaceholder()
          ? _value.allowedActions
          // ignore: cast_nullable_to_non_nullable
          : allowedActions as List<String>?,
    );
  }
}

extension $MeResponseCopyWith on MeResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMeResponse.copyWith(...)` or like so:`instanceOfMeResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeResponseCWProxy get copyWith => _$MeResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeResponse _$MeResponseFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MeResponse',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['user']);
    final val = MeResponse(
      user: $checkedConvert(
        'user',
        (v) => User.fromJson(v as Map<String, dynamic>),
      ),
      profile: $checkedConvert(
        'profile',
        (v) => v == null
            ? null
            : ProfileSummary.fromJson(v as Map<String, dynamic>),
      ),
      unreadNotificationCount: $checkedConvert(
        'unread_notification_count',
        (v) => (v as num?)?.toInt(),
      ),
      allowedActions: $checkedConvert(
        'allowed_actions',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'unreadNotificationCount': 'unread_notification_count',
    'allowedActions': 'allowed_actions',
  },
);

Map<String, dynamic> _$MeResponseToJson(MeResponse instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'profile': ?instance.profile?.toJson(),
      'unread_notification_count': ?instance.unreadNotificationCount,
      'allowed_actions': ?instance.allowedActions,
    };
