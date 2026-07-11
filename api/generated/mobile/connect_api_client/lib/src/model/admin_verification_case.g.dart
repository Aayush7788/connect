// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_verification_case.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminVerificationCaseCWProxy {
  AdminVerificationCase id(String id);

  AdminVerificationCase status(VerificationCaseStatus status);

  AdminVerificationCase profile(ProfileSummary profile);

  AdminVerificationCase checks(List<Map<String, Object>>? checks);

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
    ProfileSummary profile,
    List<Map<String, Object>>? checks,
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
  AdminVerificationCase profile(ProfileSummary profile) =>
      this(profile: profile);

  @override
  AdminVerificationCase checks(List<Map<String, Object>>? checks) =>
      this(checks: checks);

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
    Object? profile = const $CopyWithPlaceholder(),
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
      profile: profile == const $CopyWithPlaceholder()
          ? _value.profile
          // ignore: cast_nullable_to_non_nullable
          : profile as ProfileSummary,
      checks: checks == const $CopyWithPlaceholder()
          ? _value.checks
          // ignore: cast_nullable_to_non_nullable
          : checks as List<Map<String, Object>>?,
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
    $checkKeys(json, requiredKeys: const ['id', 'status', 'profile']);
    final val = AdminVerificationCase(
      id: $checkedConvert('id', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$VerificationCaseStatusEnumMap, v),
      ),
      profile: $checkedConvert(
        'profile',
        (v) => ProfileSummary.fromJson(v as Map<String, dynamic>),
      ),
      checks: $checkedConvert(
        'checks',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) => (e as Map<String, dynamic>).map(
                (k, e) => MapEntry(k, e as Object),
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
  fieldKeyMap: const {'privateDocumentAccess': 'private_document_access'},
);

Map<String, dynamic> _$AdminVerificationCaseToJson(
  AdminVerificationCase instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': _$VerificationCaseStatusEnumMap[instance.status]!,
  'profile': instance.profile.toJson(),
  'checks': ?instance.checks,
  'private_document_access': ?instance.privateDocumentAccess
      ?.map((e) => e.toJson())
      .toList(),
};

const _$VerificationCaseStatusEnumMap = {
  VerificationCaseStatus.pending: 'pending',
  VerificationCaseStatus.approved: 'approved',
  VerificationCaseStatus.changesRequested: 'changes_requested',
  VerificationCaseStatus.rejected: 'rejected',
};
