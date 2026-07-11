// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_approve_verification_case_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminApproveVerificationCaseRequestCWProxy {
  AdminApproveVerificationCaseRequest notesToUser(String? notesToUser);

  AdminApproveVerificationCaseRequest internalNote(String? internalNote);

  AdminApproveVerificationCaseRequest reason(String? reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminApproveVerificationCaseRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminApproveVerificationCaseRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminApproveVerificationCaseRequest call({
    String? notesToUser,
    String? internalNote,
    String? reason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminApproveVerificationCaseRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminApproveVerificationCaseRequest.copyWith.fieldName(...)`
class _$AdminApproveVerificationCaseRequestCWProxyImpl
    implements _$AdminApproveVerificationCaseRequestCWProxy {
  const _$AdminApproveVerificationCaseRequestCWProxyImpl(this._value);

  final AdminApproveVerificationCaseRequest _value;

  @override
  AdminApproveVerificationCaseRequest notesToUser(String? notesToUser) =>
      this(notesToUser: notesToUser);

  @override
  AdminApproveVerificationCaseRequest internalNote(String? internalNote) =>
      this(internalNote: internalNote);

  @override
  AdminApproveVerificationCaseRequest reason(String? reason) =>
      this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminApproveVerificationCaseRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminApproveVerificationCaseRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminApproveVerificationCaseRequest call({
    Object? notesToUser = const $CopyWithPlaceholder(),
    Object? internalNote = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return AdminApproveVerificationCaseRequest(
      notesToUser: notesToUser == const $CopyWithPlaceholder()
          ? _value.notesToUser
          // ignore: cast_nullable_to_non_nullable
          : notesToUser as String?,
      internalNote: internalNote == const $CopyWithPlaceholder()
          ? _value.internalNote
          // ignore: cast_nullable_to_non_nullable
          : internalNote as String?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
    );
  }
}

extension $AdminApproveVerificationCaseRequestCopyWith
    on AdminApproveVerificationCaseRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAdminApproveVerificationCaseRequest.copyWith(...)` or like so:`instanceOfAdminApproveVerificationCaseRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminApproveVerificationCaseRequestCWProxy get copyWith =>
      _$AdminApproveVerificationCaseRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminApproveVerificationCaseRequest
_$AdminApproveVerificationCaseRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AdminApproveVerificationCaseRequest',
      json,
      ($checkedConvert) {
        final val = AdminApproveVerificationCaseRequest(
          notesToUser: $checkedConvert('notes_to_user', (v) => v as String?),
          internalNote: $checkedConvert('internal_note', (v) => v as String?),
          reason: $checkedConvert('reason', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'notesToUser': 'notes_to_user',
        'internalNote': 'internal_note',
      },
    );

Map<String, dynamic> _$AdminApproveVerificationCaseRequestToJson(
  AdminApproveVerificationCaseRequest instance,
) => <String, dynamic>{
  'notes_to_user': ?instance.notesToUser,
  'internal_note': ?instance.internalNote,
  'reason': ?instance.reason,
};
