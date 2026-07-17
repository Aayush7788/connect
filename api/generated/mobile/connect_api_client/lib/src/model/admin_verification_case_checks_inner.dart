//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_verification_case_checks_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminVerificationCaseChecksInner {
  /// Returns a new [AdminVerificationCaseChecksInner] instance.
  AdminVerificationCaseChecksInner({
    required this.checkType,

    required this.status,

    this.notesToUser,

    this.internalNotes,
  });

  @JsonKey(name: r'check_type', required: true, includeIfNull: false)
  final String checkType;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @JsonKey(name: r'notes_to_user', required: false, includeIfNull: false)
  final String? notesToUser;

  @JsonKey(name: r'internal_notes', required: false, includeIfNull: false)
  final String? internalNotes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminVerificationCaseChecksInner &&
          other.checkType == checkType &&
          other.status == status &&
          other.notesToUser == notesToUser &&
          other.internalNotes == internalNotes;

  @override
  int get hashCode =>
      checkType.hashCode +
      status.hashCode +
      notesToUser.hashCode +
      internalNotes.hashCode;

  factory AdminVerificationCaseChecksInner.fromJson(
    Map<String, dynamic> json,
  ) => _$AdminVerificationCaseChecksInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AdminVerificationCaseChecksInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
