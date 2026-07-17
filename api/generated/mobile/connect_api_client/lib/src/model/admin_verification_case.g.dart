// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_verification_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminVerificationCaseCWProxy {
  AdminVerificationCase id(String id);

  AdminVerificationCase status(VerificationCaseStatus status);

  AdminVerificationCase caseReason(String caseReason);

  AdminVerificationCase profile(ProfileSummary profile);

  AdminVerificationCase ownerMobile(String? ownerMobile);

  AdminVerificationCase fullAddress(String? fullAddress);

  AdminVerificationCase submittedAt(DateTime? submittedAt);

  AdminVerificationCase reviewedAt(DateTime? reviewedAt);

  AdminVerificationCase notesToUser(String? notesToUser);

  AdminVerificationCase internalNotes(String? internalNotes);

  AdminVerificationCase resubmissionCount(int? resubmissionCount);

  AdminVerificationCase checks(List<AdminVerificationCaseChecksInner>? checks);

  AdminVerificationCase privateDocumentAccess(
    List<AdminVerificationCasePrivateDocumentAccessInner>?
    privateDocumentAccess,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminVerificationCase(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminVerificationCase(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminVerificationCase call({
    String id,
    VerificationCaseStatus status,
    String caseReason,
    ProfileSummary profile,
    String? ownerMobile,
    String? fullAddress,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? notesToUser,
    String? internalNotes,
    int? resubmissionCount,
    List<AdminVerificationCaseChecksInner>? checks,
    List<AdminVerificationCasePrivateDocumentAccessInner>?
    privateDocumentAccess,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminVerificationCase.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminVerificationCase.copyWith.fieldName(...)`
class _$AdminVerificationCaseCWProxyImpl
    implements _$AdminVerificationCaseCWProxy {
  const _$AdminVerificationCaseCWProxyImpl(this._value);

  final AdminVerificationCase _value;

  @override
  AdminVerificationCase id(String id) => this(id: id);

  @override
  AdminVerificationCase status(VerificationCaseStatus status) =>
      this(status: status);

  @override
  AdminVerificationCase caseReason(String caseReason) =>
      this(caseReason: caseReason);

  @override
  AdminVerificationCase profile(ProfileSummary profile) =>
      this(profile: profile);

  @override
  AdminVerificationCase ownerMobile(String? ownerMobile) =>
      this(ownerMobile: ownerMobile);

  @override
  AdminVerificationCase fullAddress(String? fullAddress) =>
      this(fullAddress: fullAddress);

  @override
  AdminVerificationCase submittedAt(DateTime? submittedAt) =>
      this(submittedAt: submittedAt);

  @override
  AdminVerificationCase reviewedAt(DateTime? reviewedAt) =>
      this(reviewedAt: reviewedAt);

  @override
  AdminVerificationCase notesToUser(String? notesToUser) =>
      this(notesToUser: notesToUser);

  @override
  AdminVerificationCase internalNotes(String? internalNotes) =>
      this(internalNotes: internalNotes);

  @override
  AdminVerificationCase resubmissionCount(int? resubmissionCount) =>
      this(resubmissionCount: resubmissionCount);

  @override
  AdminVerificationCase checks(
    List<AdminVerificationCaseChecksInner>? checks,
  ) => this(checks: checks);

  @override
  AdminVerificationCase privateDocumentAccess(
    List<AdminVerificationCasePrivateDocumentAccessInner>?
    privateDocumentAccess,
  ) => this(privateDocumentAccess: privateDocumentAccess);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminVerificationCase(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminVerificationCase(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminVerificationCase call({
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? caseReason = const $CopyWithPlaceholder(),
    Object? profile = const $CopyWithPlaceholder(),
    Object? ownerMobile = const $CopyWithPlaceholder(),
    Object? fullAddress = const $CopyWithPlaceholder(),
    Object? submittedAt = const $CopyWithPlaceholder(),
    Object? reviewedAt = const $CopyWithPlaceholder(),
    Object? notesToUser = const $CopyWithPlaceholder(),
    Object? internalNotes = const $CopyWithPlaceholder(),
    Object? resubmissionCount = const $CopyWithPlaceholder(),
    Object? checks = const $CopyWithPlaceholder(),
    Object? privateDocumentAccess = const $CopyWithPlaceholder(),
  }) {
    return AdminVerificationCase(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as VerificationCaseStatus,
      caseReason: caseReason == const $CopyWithPlaceholder()
          ? _value.caseReason
          // ignore: cast_nullable_to_non_nullable
          : caseReason as String,
      profile: profile == const $CopyWithPlaceholder()
          ? _value.profile
          // ignore: cast_nullable_to_non_nullable
          : profile as ProfileSummary,
      ownerMobile: ownerMobile == const $CopyWithPlaceholder()
          ? _value.ownerMobile
          // ignore: cast_nullable_to_non_nullable
          : ownerMobile as String?,
      fullAddress: fullAddress == const $CopyWithPlaceholder()
          ? _value.fullAddress
          // ignore: cast_nullable_to_non_nullable
          : fullAddress as String?,
      submittedAt: submittedAt == const $CopyWithPlaceholder()
          ? _value.submittedAt
          // ignore: cast_nullable_to_non_nullable
          : submittedAt as DateTime?,
      reviewedAt: reviewedAt == const $CopyWithPlaceholder()
          ? _value.reviewedAt
          // ignore: cast_nullable_to_non_nullable
          : reviewedAt as DateTime?,
      notesToUser: notesToUser == const $CopyWithPlaceholder()
          ? _value.notesToUser
          // ignore: cast_nullable_to_non_nullable
          : notesToUser as String?,
      internalNotes: internalNotes == const $CopyWithPlaceholder()
          ? _value.internalNotes
          // ignore: cast_nullable_to_non_nullable
          : internalNotes as String?,
      resubmissionCount: resubmissionCount == const $CopyWithPlaceholder()
          ? _value.resubmissionCount
          // ignore: cast_nullable_to_non_nullable
          : resubmissionCount as int?,
      checks: checks == const $CopyWithPlaceholder()
          ? _value.checks
          // ignore: cast_nullable_to_non_nullable
          : checks as List<AdminVerificationCaseChecksInner>?,
      privateDocumentAccess:
          privateDocumentAccess == const $CopyWithPlaceholder()
          ? _value.privateDocumentAccess
          // ignore: cast_nullable_to_non_nullable
          : privateDocumentAccess
                as List<AdminVerificationCasePrivateDocumentAccessInner>?,
    );
  }
}

extension $AdminVerificationCaseCopyWith on AdminVerificationCase {
  /// Returns a callable class that can be used as follows: `instanceOfAdminVerificationCase.copyWith(...)` or like so:`instanceOfAdminVerificationCase.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminVerificationCaseCWProxy get copyWith =>
      _$AdminVerificationCaseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminVerificationCase _$AdminVerificationCaseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdminVerificationCase',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['id', 'status', 'case_reason', 'profile'],
    );
    final val = AdminVerificationCase(
      id: $checkedConvert('id', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$VerificationCaseStatusEnumMap, v),
      ),
      caseReason: $checkedConvert('case_reason', (v) => v as String),
      profile: $checkedConvert(
        'profile',
        (v) => ProfileSummary.fromJson(v as Map<String, dynamic>),
      ),
      ownerMobile: $checkedConvert('owner_mobile', (v) => v as String?),
      fullAddress: $checkedConvert('full_address', (v) => v as String?),
      submittedAt: $checkedConvert(
        'submitted_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      reviewedAt: $checkedConvert(
        'reviewed_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      notesToUser: $checkedConvert('notes_to_user', (v) => v as String?),
      internalNotes: $checkedConvert('internal_notes', (v) => v as String?),
      resubmissionCount: $checkedConvert(
        'resubmission_count',
        (v) => (v as num?)?.toInt(),
      ),
      checks: $checkedConvert(
        'checks',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) => AdminVerificationCaseChecksInner.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
      privateDocumentAccess: $checkedConvert(
        'private_document_access',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) => AdminVerificationCasePrivateDocumentAccessInner.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'caseReason': 'case_reason',
    'ownerMobile': 'owner_mobile',
    'fullAddress': 'full_address',
    'submittedAt': 'submitted_at',
    'reviewedAt': 'reviewed_at',
    'notesToUser': 'notes_to_user',
    'internalNotes': 'internal_notes',
    'resubmissionCount': 'resubmission_count',
    'privateDocumentAccess': 'private_document_access',
  },
);

Map<String, dynamic> _$AdminVerificationCaseToJson(
  AdminVerificationCase instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': _$VerificationCaseStatusEnumMap[instance.status]!,
  'case_reason': instance.caseReason,
  'profile': instance.profile.toJson(),
  'owner_mobile': ?instance.ownerMobile,
  'full_address': ?instance.fullAddress,
  'submitted_at': ?instance.submittedAt?.toIso8601String(),
  'reviewed_at': ?instance.reviewedAt?.toIso8601String(),
  'notes_to_user': ?instance.notesToUser,
  'internal_notes': ?instance.internalNotes,
  'resubmission_count': ?instance.resubmissionCount,
  'checks': ?instance.checks?.map((e) => e.toJson()).toList(),
  'private_document_access': ?instance.privateDocumentAccess
      ?.map((e) => e.toJson())
      .toList(),
};

const _$VerificationCaseStatusEnumMap = {
  VerificationCaseStatus.draft: 'draft',
  VerificationCaseStatus.pendingReview: 'pending_review',
  VerificationCaseStatus.changesRequested: 'changes_requested',
  VerificationCaseStatus.approved: 'approved',
  VerificationCaseStatus.rejected: 'rejected',
  VerificationCaseStatus.cancelled: 'cancelled',
};
