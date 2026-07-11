// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NotificationsResponseCWProxy {
  NotificationsResponse items(List<Notification> items);

  NotificationsResponse nextCursor(String? nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationsResponse call({List<Notification> items, String? nextCursor});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNotificationsResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNotificationsResponse.copyWith.fieldName(...)`
class _$NotificationsResponseCWProxyImpl
    implements _$NotificationsResponseCWProxy {
  const _$NotificationsResponseCWProxyImpl(this._value);

  final NotificationsResponse _value;

  @override
  NotificationsResponse items(List<Notification> items) => this(items: items);

  @override
  NotificationsResponse nextCursor(String? nextCursor) =>
      this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationsResponse call({
    Object? items = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return NotificationsResponse(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<Notification>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
    );
  }
}

extension $NotificationsResponseCopyWith on NotificationsResponse {
  /// Returns a callable class that can be used as follows: `instanceOfNotificationsResponse.copyWith(...)` or like so:`instanceOfNotificationsResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NotificationsResponseCWProxy get copyWith =>
      _$NotificationsResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationsResponse _$NotificationsResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NotificationsResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['items']);
  final val = NotificationsResponse(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    nextCursor: $checkedConvert('next_cursor', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'nextCursor': 'next_cursor'});

Map<String, dynamic> _$NotificationsResponseToJson(
  NotificationsResponse instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'next_cursor': ?instance.nextCursor,
};
