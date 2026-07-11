// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminUserCWProxy {
  AdminUser id(String id);

  AdminUser email(String? email);

  AdminUser role(AdminUserRoleEnum role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminUser(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminUser(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminUser call({String id, String? email, AdminUserRoleEnum role});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminUser.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminUser.copyWith.fieldName(...)`
class _$AdminUserCWProxyImpl implements _$AdminUserCWProxy {
  const _$AdminUserCWProxyImpl(this._value);

  final AdminUser _value;

  @override
  AdminUser id(String id) => this(id: id);

  @override
  AdminUser email(String? email) => this(email: email);

  @override
  AdminUser role(AdminUserRoleEnum role) => this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminUser(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminUser(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminUser call({
    Object? id = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return AdminUser(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as AdminUserRoleEnum,
    );
  }
}

extension $AdminUserCopyWith on AdminUser {
  /// Returns a callable class that can be used as follows: `instanceOfAdminUser.copyWith(...)` or like so:`instanceOfAdminUser.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminUserCWProxy get copyWith => _$AdminUserCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUser _$AdminUserFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AdminUser', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'role']);
      final val = AdminUser(
        id: $checkedConvert('id', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String?),
        role: $checkedConvert(
          'role',
          (v) => $enumDecode(_$AdminUserRoleEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AdminUserToJson(AdminUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': ?instance.email,
  'role': _$AdminUserRoleEnumEnumMap[instance.role]!,
};

const _$AdminUserRoleEnumEnumMap = {
  AdminUserRoleEnum.superAdmin: 'super_admin',
};
