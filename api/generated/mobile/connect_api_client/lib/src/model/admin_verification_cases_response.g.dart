// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_verification_cases_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminVerificationCasesResponseCWProxy {
  AdminVerificationCasesResponse items(List<AdminVerificationCase> items);

  AdminVerificationCasesResponse nextCursor(String? nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminVerificationCasesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminVerificationCasesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminVerificationCasesResponse call({
    List<AdminVerificationCase> items,
    String? nextCursor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminVerificationCasesResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminVerificationCasesResponse.copyWith.fieldName(...)`
class _$AdminVerificationCasesResponseCWProxyImpl
    implements _$AdminVerificationCasesResponseCWProxy {
  const _$AdminVerificationCasesResponseCWProxyImpl(this._value);

  final AdminVerificationCasesResponse _value;

  @override
  AdminVerificationCasesResponse items(List<AdminVerificationCase> items) =>
      this(items: items);

  @override
  AdminVerificationCasesResponse nextCursor(String? nextCursor) =>
      this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminVerificationCasesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminVerificationCasesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminVerificationCasesResponse call({
    Object? items = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return AdminVerificationCasesResponse(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<AdminVerificationCase>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
    );
  }
}

extension $AdminVerificationCasesResponseCopyWith
    on AdminVerificationCasesResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAdminVerificationCasesResponse.copyWith(...)` or like so:`instanceOfAdminVerificationCasesResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminVerificationCasesResponseCWProxy get copyWith =>
      _$AdminVerificationCasesResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminVerificationCasesResponse _$AdminVerificationCasesResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdminVerificationCasesResponse',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['items']);
    final val = AdminVerificationCasesResponse(
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map(
              (e) => AdminVerificationCase.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      ),
      nextCursor: $checkedConvert('next_cursor', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'nextCursor': 'next_cursor'},
);

Map<String, dynamic> _$AdminVerificationCasesResponseToJson(
  AdminVerificationCasesResponse instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'next_cursor': ?instance.nextCursor,
};
