// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UserCWProxy {
  User id(String id);

  User displayName(String displayName);

  User primaryMobile(String primaryMobile);

  User accountStatus(AccountStatus accountStatus);

  User role(UserRole? role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `User(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// User(...).copyWith(id: 12, name: "My name")
  /// ````
  User call({
    String id,
    String displayName,
    String primaryMobile,
    AccountStatus accountStatus,
    UserRole? role,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUser.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUser.copyWith.fieldName(...)`
class _$UserCWProxyImpl implements _$UserCWProxy {
  const _$UserCWProxyImpl(this._value);

  final User _value;

  @override
  User id(String id) => this(id: id);

  @override
  User displayName(String displayName) => this(displayName: displayName);

  @override
  User primaryMobile(String primaryMobile) =>
      this(primaryMobile: primaryMobile);

  @override
  User accountStatus(AccountStatus accountStatus) =>
      this(accountStatus: accountStatus);

  @override
  User role(UserRole? role) => this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `User(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// User(...).copyWith(id: 12, name: "My name")
  /// ````
  User call({
    Object? id = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? primaryMobile = const $CopyWithPlaceholder(),
    Object? accountStatus = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return User(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String,
      primaryMobile: primaryMobile == const $CopyWithPlaceholder()
          ? _value.primaryMobile
          // ignore: cast_nullable_to_non_nullable
          : primaryMobile as String,
      accountStatus: accountStatus == const $CopyWithPlaceholder()
          ? _value.accountStatus
          // ignore: cast_nullable_to_non_nullable
          : accountStatus as AccountStatus,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as UserRole?,
    );
  }
}

extension $UserCopyWith on User {
  /// Returns a callable class that can be used as follows: `instanceOfUser.copyWith(...)` or like so:`instanceOfUser.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UserCWProxy get copyWith => _$UserCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => $checkedCreate(
  'User',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'display_name',
        'primary_mobile',
        'account_status',
      ],
    );
    final val = User(
      id: $checkedConvert('id', (v) => v as String),
      displayName: $checkedConvert('display_name', (v) => v as String),
      primaryMobile: $checkedConvert('primary_mobile', (v) => v as String),
      accountStatus: $checkedConvert(
        'account_status',
        (v) => $enumDecode(_$AccountStatusEnumMap, v),
      ),
      role: $checkedConvert(
        'role',
        (v) => $enumDecodeNullable(_$UserRoleEnumMap, v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'displayName': 'display_name',
    'primaryMobile': 'primary_mobile',
    'accountStatus': 'account_status',
  },
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'display_name': instance.displayName,
  'primary_mobile': instance.primaryMobile,
  'account_status': _$AccountStatusEnumMap[instance.accountStatus]!,
  'role': ?_$UserRoleEnumMap[instance.role],
};

const _$AccountStatusEnumMap = {
  AccountStatus.active: 'active',
  AccountStatus.suspended: 'suspended',
  AccountStatus.terminated: 'terminated',
};

const _$UserRoleEnumMap = {
  UserRole.business: 'business',
  UserRole.jobWorker: 'job_worker',
  UserRole.skilledWorker: 'skilled_worker',
};
