// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_role_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConfirmRoleRequestCWProxy {
  ConfirmRoleRequest role(UserRole role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmRoleRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmRoleRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmRoleRequest call({UserRole role});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConfirmRoleRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConfirmRoleRequest.copyWith.fieldName(...)`
class _$ConfirmRoleRequestCWProxyImpl implements _$ConfirmRoleRequestCWProxy {
  const _$ConfirmRoleRequestCWProxyImpl(this._value);

  final ConfirmRoleRequest _value;

  @override
  ConfirmRoleRequest role(UserRole role) => this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmRoleRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmRoleRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmRoleRequest call({Object? role = const $CopyWithPlaceholder()}) {
    return ConfirmRoleRequest(
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as UserRole,
    );
  }
}

extension $ConfirmRoleRequestCopyWith on ConfirmRoleRequest {
  /// Returns a callable class that can be used as follows: `instanceOfConfirmRoleRequest.copyWith(...)` or like so:`instanceOfConfirmRoleRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConfirmRoleRequestCWProxy get copyWith =>
      _$ConfirmRoleRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmRoleRequest _$ConfirmRoleRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConfirmRoleRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['role']);
      final val = ConfirmRoleRequest(
        role: $checkedConvert('role', (v) => $enumDecode(_$UserRoleEnumMap, v)),
      );
      return val;
    });

Map<String, dynamic> _$ConfirmRoleRequestToJson(ConfirmRoleRequest instance) =>
    <String, dynamic>{'role': _$UserRoleEnumMap[instance.role]!};

const _$UserRoleEnumMap = {
  UserRole.business: 'business',
  UserRole.jobWorker: 'job_worker',
  UserRole.skilledWorker: 'skilled_worker',
};
