// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_reports_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminReportsResponseCWProxy {
  AdminReportsResponse items(List<Map<String, Object>> items);

  AdminReportsResponse nextCursor(String? nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminReportsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminReportsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminReportsResponse call({
    List<Map<String, Object>> items,
    String? nextCursor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminReportsResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminReportsResponse.copyWith.fieldName(...)`
class _$AdminReportsResponseCWProxyImpl
    implements _$AdminReportsResponseCWProxy {
  const _$AdminReportsResponseCWProxyImpl(this._value);

  final AdminReportsResponse _value;

  @override
  AdminReportsResponse items(List<Map<String, Object>> items) =>
      this(items: items);

  @override
  AdminReportsResponse nextCursor(String? nextCursor) =>
      this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminReportsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminReportsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminReportsResponse call({
    Object? items = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return AdminReportsResponse(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<Map<String, Object>>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
    );
  }
}

extension $AdminReportsResponseCopyWith on AdminReportsResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAdminReportsResponse.copyWith(...)` or like so:`instanceOfAdminReportsResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminReportsResponseCWProxy get copyWith =>
      _$AdminReportsResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminReportsResponse _$AdminReportsResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AdminReportsResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['items']);
  final val = AdminReportsResponse(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map(
            (e) => (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, e as Object),
            ),
          )
          .toList(),
    ),
    nextCursor: $checkedConvert('next_cursor', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'nextCursor': 'next_cursor'});

Map<String, dynamic> _$AdminReportsResponseToJson(
  AdminReportsResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'next_cursor': ?instance.nextCursor,
};
