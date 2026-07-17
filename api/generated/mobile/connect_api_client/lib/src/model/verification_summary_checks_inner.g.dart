// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_summary_checks_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VerificationSummaryChecksInnerCWProxy {
  VerificationSummaryChecksInner checkType(String checkType);

  VerificationSummaryChecksInner status(String status);

  VerificationSummaryChecksInner notesToUser(String? notesToUser);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationSummaryChecksInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationSummaryChecksInner(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationSummaryChecksInner call({
    String checkType,
    String status,
    String? notesToUser,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVerificationSummaryChecksInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVerificationSummaryChecksInner.copyWith.fieldName(...)`
class _$VerificationSummaryChecksInnerCWProxyImpl
    implements _$VerificationSummaryChecksInnerCWProxy {
  const _$VerificationSummaryChecksInnerCWProxyImpl(this._value);

  final VerificationSummaryChecksInner _value;

  @override
  VerificationSummaryChecksInner checkType(String checkType) =>
      this(checkType: checkType);

  @override
  VerificationSummaryChecksInner status(String status) => this(status: status);

  @override
  VerificationSummaryChecksInner notesToUser(String? notesToUser) =>
      this(notesToUser: notesToUser);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationSummaryChecksInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationSummaryChecksInner(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationSummaryChecksInner call({
    Object? checkType = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? notesToUser = const $CopyWithPlaceholder(),
  }) {
    return VerificationSummaryChecksInner(
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
    );
  }
}

extension $VerificationSummaryChecksInnerCopyWith
    on VerificationSummaryChecksInner {
  /// Returns a callable class that can be used as follows: `instanceOfVerificationSummaryChecksInner.copyWith(...)` or like so:`instanceOfVerificationSummaryChecksInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VerificationSummaryChecksInnerCWProxy get copyWith =>
      _$VerificationSummaryChecksInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationSummaryChecksInner _$VerificationSummaryChecksInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'VerificationSummaryChecksInner',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['check_type', 'status']);
    final val = VerificationSummaryChecksInner(
      checkType: $checkedConvert('check_type', (v) => v as String),
      status: $checkedConvert('status', (v) => v as String),
      notesToUser: $checkedConvert('notes_to_user', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'checkType': 'check_type',
    'notesToUser': 'notes_to_user',
  },
);

Map<String, dynamic> _$VerificationSummaryChecksInnerToJson(
  VerificationSummaryChecksInner instance,
) => <String, dynamic>{
  'check_type': instance.checkType,
  'status': instance.status,
  'notes_to_user': ?instance.notesToUser,
};
