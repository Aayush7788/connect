// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_profiles_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminProfilesResponseCWProxy {
  AdminProfilesResponse items(List<AdminProfile> items);

  AdminProfilesResponse nextCursor(String? nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminProfilesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminProfilesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminProfilesResponse call({List<AdminProfile> items, String? nextCursor});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminProfilesResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminProfilesResponse.copyWith.fieldName(...)`
class _$AdminProfilesResponseCWProxyImpl
    implements _$AdminProfilesResponseCWProxy {
  const _$AdminProfilesResponseCWProxyImpl(this._value);

  final AdminProfilesResponse _value;

  @override
  AdminProfilesResponse items(List<AdminProfile> items) => this(items: items);

  @override
  AdminProfilesResponse nextCursor(String? nextCursor) =>
      this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminProfilesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminProfilesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminProfilesResponse call({
    Object? items = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return AdminProfilesResponse(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<AdminProfile>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
    );
  }
}

extension $AdminProfilesResponseCopyWith on AdminProfilesResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAdminProfilesResponse.copyWith(...)` or like so:`instanceOfAdminProfilesResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminProfilesResponseCWProxy get copyWith =>
      _$AdminProfilesResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminProfilesResponse _$AdminProfilesResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AdminProfilesResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['items']);
  final val = AdminProfilesResponse(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => AdminProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    nextCursor: $checkedConvert('next_cursor', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'nextCursor': 'next_cursor'});

Map<String, dynamic> _$AdminProfilesResponseToJson(
  AdminProfilesResponse instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'next_cursor': ?instance.nextCursor,
};
