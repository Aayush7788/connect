// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_seed_profile_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminSeedProfileRequestCWProxy {
  AdminSeedProfileRequest role(UserRole role);

  AdminSeedProfileRequest displayName(String displayName);

  AdminSeedProfileRequest profileData(Map<String, Object>? profileData);

  AdminSeedProfileRequest makePublic(bool? makePublic);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminSeedProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminSeedProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminSeedProfileRequest call({
    UserRole role,
    String displayName,
    Map<String, Object>? profileData,
    bool? makePublic,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminSeedProfileRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminSeedProfileRequest.copyWith.fieldName(...)`
class _$AdminSeedProfileRequestCWProxyImpl
    implements _$AdminSeedProfileRequestCWProxy {
  const _$AdminSeedProfileRequestCWProxyImpl(this._value);

  final AdminSeedProfileRequest _value;

  @override
  AdminSeedProfileRequest role(UserRole role) => this(role: role);

  @override
  AdminSeedProfileRequest displayName(String displayName) =>
      this(displayName: displayName);

  @override
  AdminSeedProfileRequest profileData(Map<String, Object>? profileData) =>
      this(profileData: profileData);

  @override
  AdminSeedProfileRequest makePublic(bool? makePublic) =>
      this(makePublic: makePublic);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminSeedProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminSeedProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminSeedProfileRequest call({
    Object? role = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? profileData = const $CopyWithPlaceholder(),
    Object? makePublic = const $CopyWithPlaceholder(),
  }) {
    return AdminSeedProfileRequest(
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as UserRole,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String,
      profileData: profileData == const $CopyWithPlaceholder()
          ? _value.profileData
          // ignore: cast_nullable_to_non_nullable
          : profileData as Map<String, Object>?,
      makePublic: makePublic == const $CopyWithPlaceholder()
          ? _value.makePublic
          // ignore: cast_nullable_to_non_nullable
          : makePublic as bool?,
    );
  }
}

extension $AdminSeedProfileRequestCopyWith on AdminSeedProfileRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAdminSeedProfileRequest.copyWith(...)` or like so:`instanceOfAdminSeedProfileRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminSeedProfileRequestCWProxy get copyWith =>
      _$AdminSeedProfileRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminSeedProfileRequest _$AdminSeedProfileRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdminSeedProfileRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['role', 'display_name']);
    final val = AdminSeedProfileRequest(
      role: $checkedConvert('role', (v) => $enumDecode(_$UserRoleEnumMap, v)),
      displayName: $checkedConvert('display_name', (v) => v as String),
      profileData: $checkedConvert(
        'profile_data',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
      makePublic: $checkedConvert('make_public', (v) => v as bool? ?? false),
    );
    return val;
  },
  fieldKeyMap: const {
    'displayName': 'display_name',
    'profileData': 'profile_data',
    'makePublic': 'make_public',
  },
);

Map<String, dynamic> _$AdminSeedProfileRequestToJson(
  AdminSeedProfileRequest instance,
) => <String, dynamic>{
  'role': _$UserRoleEnumMap[instance.role]!,
  'display_name': instance.displayName,
  'profile_data': ?instance.profileData,
  'make_public': ?instance.makePublic,
};

const _$UserRoleEnumMap = {
  UserRole.business: 'business',
  UserRole.jobWorker: 'job_worker',
  UserRole.skilledWorker: 'skilled_worker',
};
