// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_verification_case_checks_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminVerificationCaseChecksInnerCWProxy {
  AdminVerificationCaseChecksInner checkType(String checkType);

  AdminVerificationCaseChecksInner status(String status);

  AdminVerificationCaseChecksInner notesToUser(String? notesToUser);

  AdminVerificationCaseChecksInner internalNotes(String? internalNotes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminVerificationCaseChecksInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminVerificationCaseChecksInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminVerificationCaseChecksInner call({
    String checkType,
    String status,
    String? notesToUser,
    String? internalNotes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminVerificationCaseChecksInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminVerificationCaseChecksInner.copyWith.fieldName(...)`
class _$AdminVerificationCaseChecksInnerCWProxyImpl
    implements _$AdminVerificationCaseChecksInnerCWProxy {
  const _$AdminVerificationCaseChecksInnerCWProxyImpl(this._value);

  final AdminVerificationCaseChecksInner _value;

  @override
  AdminVerificationCaseChecksInner checkType(String checkType) =>
      this(checkType: checkType);

  @override
  AdminVerificationCaseChecksInner status(String status) =>
      this(status: status);

  @override
  AdminVerificationCaseChecksInner notesToUser(String? notesToUser) =>
      this(notesToUser: notesToUser);

  @override
  AdminVerificationCaseChecksInner internalNotes(String? internalNotes) =>
      this(internalNotes: internalNotes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminVerificationCaseChecksInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminVerificationCaseChecksInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminVerificationCaseChecksInner call({
    Object? checkType = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? notesToUser = const $CopyWithPlaceholder(),
    Object? internalNotes = const $CopyWithPlaceholder(),
  }) {
    return AdminVerificationCaseChecksInner(
      checkType: checkType == const $CopyWithPlaceholder()
          ? _value.checkType
          // ignore: cast_nullable_to_non_nullable
          : checkType as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String,
      notesToUser: notesToUser == const $CopyWithPlaceholder()
          ? _value.notesToUser
          // ignore: cast_nullable_to_non_nullable
          : notesToUser as String?,
      internalNotes: internalNotes == const $CopyWithPlaceholder()
          ? _value.internalNotes
          // ignore: cast_nullable_to_non_nullable
          : internalNotes as String?,
    );
  }
}

extension $AdminVerificationCaseChecksInnerCopyWith
    on AdminVerificationCaseChecksInner {
  /// Returns a callable class that can be used as follows: `instanceOfAdminVerificationCaseChecksInner.copyWith(...)` or like so:`instanceOfAdminVerificationCaseChecksInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminVerificationCaseChecksInnerCWProxy get copyWith =>
      _$AdminVerificationCaseChecksInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminVerificationCaseChecksInner _$AdminVerificationCaseChecksInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdminVerificationCaseChecksInner',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['check_type', 'status']);
    final val = AdminVerificationCaseChecksInner(
      checkType: $checkedConvert('check_type', (v) => v as String),
      status: $checkedConvert('status', (v) => v as String),
      notesToUser: $checkedConvert('notes_to_user', (v) => v as String?),
      internalNotes: $checkedConvert('internal_notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'checkType': 'check_type',
    'notesToUser': 'notes_to_user',
    'internalNotes': 'internal_notes',
  },
);

Map<String, dynamic> _$AdminVerificationCaseChecksInnerToJson(
  AdminVerificationCaseChecksInner instance,
) => <String, dynamic>{
  'check_type': instance.checkType,
  'status': instance.status,
  'notes_to_user': ?instance.notesToUser,
  'internal_notes': ?instance.internalNotes,
};
