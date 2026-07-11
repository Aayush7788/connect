// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NotificationCWProxy {
  Notification id(String id);

  Notification title(String title);

  Notification message(String message);

  Notification createdAt(DateTime createdAt);

  Notification readAt(DateTime? readAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Notification(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Notification(...).copyWith(id: 12, name: "My name")
  /// ````
  Notification call({
    String id,
    String title,
    String message,
    DateTime createdAt,
    DateTime? readAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNotification.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNotification.copyWith.fieldName(...)`
class _$NotificationCWProxyImpl implements _$NotificationCWProxy {
  const _$NotificationCWProxyImpl(this._value);

  final Notification _value;

  @override
  Notification id(String id) => this(id: id);

  @override
  Notification title(String title) => this(title: title);

  @override
  Notification message(String message) => this(message: message);

  @override
  Notification createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Notification readAt(DateTime? readAt) => this(readAt: readAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Notification(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Notification(...).copyWith(id: 12, name: "My name")
  /// ````
  Notification call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? readAt = const $CopyWithPlaceholder(),
  }) {
    return Notification(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      readAt: readAt == const $CopyWithPlaceholder()
          ? _value.readAt
          // ignore: cast_nullable_to_non_nullable
          : readAt as DateTime?,
    );
  }
}

extension $NotificationCopyWith on Notification {
  /// Returns a callable class that can be used as follows: `instanceOfNotification.copyWith(...)` or like so:`instanceOfNotification.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NotificationCWProxy get copyWith => _$NotificationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'Notification',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['id', 'title', 'message', 'created_at'],
        );
        final val = Notification(
          id: $checkedConvert('id', (v) => v as String),
          title: $checkedConvert('title', (v) => v as String),
          message: $checkedConvert('message', (v) => v as String),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
          readAt: $checkedConvert(
            'read_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {'createdAt': 'created_at', 'readAt': 'read_at'},
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'created_at': instance.createdAt.toIso8601String(),
      'read_at': ?instance.readAt?.toIso8601String(),
    };
