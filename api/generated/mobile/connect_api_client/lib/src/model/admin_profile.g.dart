// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_profile.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminProfileCWProxy {
  AdminProfile id(String id);

  AdminProfile role(UserRole role);

  AdminProfile displayName(String? displayName);

  AdminProfile visibilityStatus(ProfileVisibilityStatus visibilityStatus);

  AdminProfile completionScore(int completionScore);

  AdminProfile completionFlags(Map<String, bool>? completionFlags);

  AdminProfile verificationStatus(VerificationStatus verificationStatus);

  AdminProfile isVerified(bool isVerified);

  AdminProfile reverificationRequired(bool? reverificationRequired);

  AdminProfile ownerUserId(String? ownerUserId);

  AdminProfile isAdminSeeded(bool? isAdminSeeded);

  AdminProfile claimStatus(AdminProfileClaimStatusEnum? claimStatus);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminProfile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminProfile(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminProfile call({
    String id,
    UserRole role,
    String? displayName,
    ProfileVisibilityStatus visibilityStatus,
    int completionScore,
    Map<String, bool>? completionFlags,
    VerificationStatus verificationStatus,
    bool isVerified,
    bool? reverificationRequired,
    String? ownerUserId,
    bool? isAdminSeeded,
    AdminProfileClaimStatusEnum? claimStatus,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminProfile.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminProfile.copyWith.fieldName(...)`
class _$AdminProfileCWProxyImpl implements _$AdminProfileCWProxy {
  const _$AdminProfileCWProxyImpl(this._value);

  final AdminProfile _value;

  @override
  AdminProfile id(String id) => this(id: id);

  @override
  AdminProfile role(UserRole role) => this(role: role);

  @override
  AdminProfile displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  AdminProfile visibilityStatus(ProfileVisibilityStatus visibilityStatus) =>
      this(visibilityStatus: visibilityStatus);

  @override
  AdminProfile completionScore(int completionScore) =>
      this(completionScore: completionScore);

  @override
  AdminProfile completionFlags(Map<String, bool>? completionFlags) =>
      this(completionFlags: completionFlags);

  @override
  AdminProfile verificationStatus(VerificationStatus verificationStatus) =>
      this(verificationStatus: verificationStatus);

  @override
  AdminProfile isVerified(bool isVerified) => this(isVerified: isVerified);

  @override
  AdminProfile reverificationRequired(bool? reverificationRequired) =>
      this(reverificationRequired: reverificationRequired);

  @override
  AdminProfile ownerUserId(String? ownerUserId) =>
      this(ownerUserId: ownerUserId);

  @override
  AdminProfile isAdminSeeded(bool? isAdminSeeded) =>
      this(isAdminSeeded: isAdminSeeded);

  @override
  AdminProfile claimStatus(AdminProfileClaimStatusEnum? claimStatus) =>
      this(claimStatus: claimStatus);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminProfile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminProfile(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminProfile call({
    Object? id = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? visibilityStatus = const $CopyWithPlaceholder(),
    Object? completionScore = const $CopyWithPlaceholder(),
    Object? completionFlags = const $CopyWithPlaceholder(),
    Object? verificationStatus = const $CopyWithPlaceholder(),
    Object? isVerified = const $CopyWithPlaceholder(),
    Object? reverificationRequired = const $CopyWithPlaceholder(),
    Object? ownerUserId = const $CopyWithPlaceholder(),
    Object? isAdminSeeded = const $CopyWithPlaceholder(),
    Object? claimStatus = const $CopyWithPlaceholder(),
  }) {
    return AdminProfile(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as UserRole,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      visibilityStatus: visibilityStatus == const $CopyWithPlaceholder()
          ? _value.visibilityStatus
          // ignore: cast_nullable_to_non_nullable
          : visibilityStatus as ProfileVisibilityStatus,
      completionScore: completionScore == const $CopyWithPlaceholder()
          ? _value.completionScore
          // ignore: cast_nullable_to_non_nullable
          : completionScore as int,
      completionFlags: completionFlags == const $CopyWithPlaceholder()
          ? _value.completionFlags
          // ignore: cast_nullable_to_non_nullable
          : completionFlags as Map<String, bool>?,
      verificationStatus: verificationStatus == const $CopyWithPlaceholder()
          ? _value.verificationStatus
          // ignore: cast_nullable_to_non_nullable
          : verificationStatus as VerificationStatus,
      isVerified: isVerified == const $CopyWithPlaceholder()
          ? _value.isVerified
          // ignore: cast_nullable_to_non_nullable
          : isVerified as bool,
      reverificationRequired:
          reverificationRequired == const $CopyWithPlaceholder()
          ? _value.reverificationRequired
          // ignore: cast_nullable_to_non_nullable
          : reverificationRequired as bool?,
      ownerUserId: ownerUserId == const $CopyWithPlaceholder()
          ? _value.ownerUserId
          // ignore: cast_nullable_to_non_nullable
          : ownerUserId as String?,
      isAdminSeeded: isAdminSeeded == const $CopyWithPlaceholder()
          ? _value.isAdminSeeded
          // ignore: cast_nullable_to_non_nullable
          : isAdminSeeded as bool?,
      claimStatus: claimStatus == const $CopyWithPlaceholder()
          ? _value.claimStatus
          // ignore: cast_nullable_to_non_nullable
          : claimStatus as AdminProfileClaimStatusEnum?,
    );
  }
}

extension $AdminProfileCopyWith on AdminProfile {
  /// Returns a callable class that can be used as follows: `instanceOfAdminProfile.copyWith(...)` or like so:`instanceOfAdminProfile.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminProfileCWProxy get copyWith => _$AdminProfileCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminProfile _$AdminProfileFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdminProfile',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'role',
        'visibility_status',
        'completion_score',
        'verification_status',
        'is_verified',
      ],
    );
    final val = AdminProfile(
      id: $checkedConvert('id', (v) => v as String),
      role: $checkedConvert('role', (v) => $enumDecode(_$UserRoleEnumMap, v)),
      displayName: $checkedConvert('display_name', (v) => v as String?),
      visibilityStatus: $checkedConvert(
        'visibility_status',
        (v) => $enumDecode(_$ProfileVisibilityStatusEnumMap, v),
      ),
      completionScore: $checkedConvert(
        'completion_score',
        (v) => (v as num).toInt(),
      ),
      completionFlags: $checkedConvert(
        'completion_flags',
        (v) =>
            (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as bool)),
      ),
      verificationStatus: $checkedConvert(
        'verification_status',
        (v) => $enumDecode(_$VerificationStatusEnumMap, v),
      ),
      isVerified: $checkedConvert('is_verified', (v) => v as bool),
      reverificationRequired: $checkedConvert(
        'reverification_required',
        (v) => v as bool?,
      ),
      ownerUserId: $checkedConvert('owner_user_id', (v) => v as String?),
      isAdminSeeded: $checkedConvert('is_admin_seeded', (v) => v as bool?),
      claimStatus: $checkedConvert(
        'claim_status',
        (v) => $enumDecodeNullable(_$AdminProfileClaimStatusEnumEnumMap, v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'displayName': 'display_name',
    'visibilityStatus': 'visibility_status',
    'completionScore': 'completion_score',
    'completionFlags': 'completion_flags',
    'verificationStatus': 'verification_status',
    'isVerified': 'is_verified',
    'reverificationRequired': 'reverification_required',
    'ownerUserId': 'owner_user_id',
    'isAdminSeeded': 'is_admin_seeded',
    'claimStatus': 'claim_status',
  },
);

Map<String, dynamic> _$AdminProfileToJson(
  AdminProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'role': _$UserRoleEnumMap[instance.role]!,
  'display_name': ?instance.displayName,
  'visibility_status':
      _$ProfileVisibilityStatusEnumMap[instance.visibilityStatus]!,
  'completion_score': instance.completionScore,
  'completion_flags': ?instance.completionFlags,
  'verification_status':
      _$VerificationStatusEnumMap[instance.verificationStatus]!,
  'is_verified': instance.isVerified,
  'reverification_required': ?instance.reverificationRequired,
  'owner_user_id': ?instance.ownerUserId,
  'is_admin_seeded': ?instance.isAdminSeeded,
  'claim_status': ?_$AdminProfileClaimStatusEnumEnumMap[instance.claimStatus],
};

const _$UserRoleEnumMap = {
  UserRole.business: 'business',
  UserRole.jobWorker: 'job_worker',
  UserRole.skilledWorker: 'skilled_worker',
};

const _$ProfileVisibilityStatusEnumMap = {
  ProfileVisibilityStatus.draft: 'draft',
  ProfileVisibilityStatus.public: 'public',
  ProfileVisibilityStatus.hiddenByUser: 'hidden_by_user',
  ProfileVisibilityStatus.suspendedByAdmin: 'suspended_by_admin',
  ProfileVisibilityStatus.deleted: 'deleted',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.unverified: 'unverified',
  VerificationStatus.pending: 'pending',
  VerificationStatus.verified: 'verified',
  VerificationStatus.changesRequested: 'changes_requested',
  VerificationStatus.rejected: 'rejected',
};

const _$AdminProfileClaimStatusEnumEnumMap = {
  AdminProfileClaimStatusEnum.unclaimed: 'unclaimed',
  AdminProfileClaimStatusEnum.claimed: 'claimed',
  AdminProfileClaimStatusEnum.notApplicable: 'not_applicable',
};
