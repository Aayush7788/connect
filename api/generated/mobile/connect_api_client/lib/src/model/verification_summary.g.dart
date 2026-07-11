// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VerificationSummaryCWProxy {
  VerificationSummary verificationStatus(VerificationStatus verificationStatus);

  VerificationSummary isVerified(bool isVerified);

  VerificationSummary reverificationRequired(bool? reverificationRequired);

  VerificationSummary activeCaseId(String? activeCaseId);

  VerificationSummary notesToUser(String? notesToUser);

  VerificationSummary safeDocuments(
    List<VerificationSummarySafeDocumentsInner>? safeDocuments,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationSummary call({
    VerificationStatus verificationStatus,
    bool isVerified,
    bool? reverificationRequired,
    String? activeCaseId,
    String? notesToUser,
    List<VerificationSummarySafeDocumentsInner>? safeDocuments,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVerificationSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVerificationSummary.copyWith.fieldName(...)`
class _$VerificationSummaryCWProxyImpl implements _$VerificationSummaryCWProxy {
  const _$VerificationSummaryCWProxyImpl(this._value);

  final VerificationSummary _value;

  @override
  VerificationSummary verificationStatus(
    VerificationStatus verificationStatus,
  ) => this(verificationStatus: verificationStatus);

  @override
  VerificationSummary isVerified(bool isVerified) =>
      this(isVerified: isVerified);

  @override
  VerificationSummary reverificationRequired(bool? reverificationRequired) =>
      this(reverificationRequired: reverificationRequired);

  @override
  VerificationSummary activeCaseId(String? activeCaseId) =>
      this(activeCaseId: activeCaseId);

  @override
  VerificationSummary notesToUser(String? notesToUser) =>
      this(notesToUser: notesToUser);

  @override
  VerificationSummary safeDocuments(
    List<VerificationSummarySafeDocumentsInner>? safeDocuments,
  ) => this(safeDocuments: safeDocuments);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationSummary call({
    Object? verificationStatus = const $CopyWithPlaceholder(),
    Object? isVerified = const $CopyWithPlaceholder(),
    Object? reverificationRequired = const $CopyWithPlaceholder(),
    Object? activeCaseId = const $CopyWithPlaceholder(),
    Object? notesToUser = const $CopyWithPlaceholder(),
    Object? safeDocuments = const $CopyWithPlaceholder(),
  }) {
    return VerificationSummary(
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
      activeCaseId: activeCaseId == const $CopyWithPlaceholder()
          ? _value.activeCaseId
          // ignore: cast_nullable_to_non_nullable
          : activeCaseId as String?,
      notesToUser: notesToUser == const $CopyWithPlaceholder()
          ? _value.notesToUser
          // ignore: cast_nullable_to_non_nullable
          : notesToUser as String?,
      safeDocuments: safeDocuments == const $CopyWithPlaceholder()
          ? _value.safeDocuments
          // ignore: cast_nullable_to_non_nullable
          : safeDocuments as List<VerificationSummarySafeDocumentsInner>?,
    );
  }
}

extension $VerificationSummaryCopyWith on VerificationSummary {
  /// Returns a callable class that can be used as follows: `instanceOfVerificationSummary.copyWith(...)` or like so:`instanceOfVerificationSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VerificationSummaryCWProxy get copyWith =>
      _$VerificationSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationSummary _$VerificationSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'VerificationSummary',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['verification_status', 'is_verified'],
        );
        final val = VerificationSummary(
          verificationStatus: $checkedConvert(
            'verification_status',
            (v) => $enumDecode(_$VerificationStatusEnumMap, v),
          ),
          isVerified: $checkedConvert('is_verified', (v) => v as bool),
          reverificationRequired: $checkedConvert(
            'reverification_required',
            (v) => v as bool?,
          ),
          activeCaseId: $checkedConvert('active_case_id', (v) => v as String?),
          notesToUser: $checkedConvert('notes_to_user', (v) => v as String?),
          safeDocuments: $checkedConvert(
            'safe_documents',
            (v) => (v as List<dynamic>?)
                ?.map(
                  (e) => VerificationSummarySafeDocumentsInner.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'verificationStatus': 'verification_status',
        'isVerified': 'is_verified',
        'reverificationRequired': 'reverification_required',
        'activeCaseId': 'active_case_id',
        'notesToUser': 'notes_to_user',
        'safeDocuments': 'safe_documents',
      },
    );

Map<String, dynamic> _$VerificationSummaryToJson(
  VerificationSummary instance,
) => <String, dynamic>{
  'verification_status':
      _$VerificationStatusEnumMap[instance.verificationStatus]!,
  'is_verified': instance.isVerified,
  'reverification_required': ?instance.reverificationRequired,
  'active_case_id': ?instance.activeCaseId,
  'notes_to_user': ?instance.notesToUser,
  'safe_documents': ?instance.safeDocuments?.map((e) => e.toJson()).toList(),
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.unverified: 'unverified',
  VerificationStatus.pending: 'pending',
  VerificationStatus.verified: 'verified',
  VerificationStatus.changesRequested: 'changes_requested',
  VerificationStatus.rejected: 'rejected',
};
