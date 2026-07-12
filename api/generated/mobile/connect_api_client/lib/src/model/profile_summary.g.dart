// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProfileSummaryCWProxy {
  ProfileSummary id(String id);

  ProfileSummary role(UserRole role);

  ProfileSummary displayName(String? displayName);

  ProfileSummary visibilityStatus(ProfileVisibilityStatus visibilityStatus);

  ProfileSummary completionScore(int completionScore);

  ProfileSummary completionFlags(Map<String, bool>? completionFlags);

  ProfileSummary verificationStatus(VerificationStatus verificationStatus);

  ProfileSummary isVerified(bool isVerified);

  ProfileSummary reverificationRequired(bool? reverificationRequired);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProfileSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProfileSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  ProfileSummary call({
    String id,
    UserRole role,
    String? displayName,
    ProfileVisibilityStatus visibilityStatus,
    int completionScore,
    Map<String, bool>? completionFlags,
    VerificationStatus verificationStatus,
    bool isVerified,
    bool? reverificationRequired,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProfileSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProfileSummary.copyWith.fieldName(...)`
class _$ProfileSummaryCWProxyImpl implements _$ProfileSummaryCWProxy {
  const _$ProfileSummaryCWProxyImpl(this._value);

  final ProfileSummary _value;

  @override
  ProfileSummary id(String id) => this(id: id);

  @override
  ProfileSummary role(UserRole role) => this(role: role);

  @override
  ProfileSummary displayName(String? displayName) =>
      this(displayName: displayName);

  @override
  ProfileSummary visibilityStatus(ProfileVisibilityStatus visibilityStatus) =>
      this(visibilityStatus: visibilityStatus);

  @override
  ProfileSummary completionScore(int completionScore) =>
      this(completionScore: completionScore);

  @override
  ProfileSummary completionFlags(Map<String, bool>? completionFlags) =>
      this(completionFlags: completionFlags);

  @override
  ProfileSummary verificationStatus(VerificationStatus verificationStatus) =>
      this(verificationStatus: verificationStatus);

  @override
  ProfileSummary isVerified(bool isVerified) => this(isVerified: isVerified);

  @override
  ProfileSummary reverificationRequired(bool? reverificationRequired) =>
      this(reverificationRequired: reverificationRequired);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProfileSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProfileSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  ProfileSummary call({
    Object? id = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? visibilityStatus = const $CopyWithPlaceholder(),
    Object? completionScore = const $CopyWithPlaceholder(),
    Object? completionFlags = const $CopyWithPlaceholder(),
    Object? verificationStatus = const $CopyWithPlaceholder(),
    Object? isVerified = const $CopyWithPlaceholder(),
    Object? reverificationRequired = const $CopyWithPlaceholder(),
  }) {
    return ProfileSummary(
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
    );
  }
}

extension $ProfileSummaryCopyWith on ProfileSummary {
  /// Returns a callable class that can be used as follows: `instanceOfProfileSummary.copyWith(...)` or like so:`instanceOfProfileSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProfileSummaryCWProxy get copyWith => _$ProfileSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileSummary _$ProfileSummaryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ProfileSummary',
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
    final val = ProfileSummary(
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
  },
);

Map<String, dynamic> _$ProfileSummaryToJson(ProfileSummary instance) =>
    <String, dynamic>{
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
