//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verification_summary_checks_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerificationSummaryChecksInner {
  /// Returns a new [VerificationSummaryChecksInner] instance.
  VerificationSummaryChecksInner({
    required this.checkType,

    required this.status,

    this.notesToUser,
  });

  @JsonKey(name: r'check_type', required: true, includeIfNull: false)
  final String checkType;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @JsonKey(name: r'notes_to_user', required: false, includeIfNull: false)
  final String? notesToUser;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerificationSummaryChecksInner &&
          other.checkType == checkType &&
          other.status == status &&
          other.notesToUser == notesToUser;

  @override
  int get hashCode =>
      checkType.hashCode + status.hashCode + notesToUser.hashCode;

  factory VerificationSummaryChecksInner.fromJson(Map<String, dynamic> json) =>
      _$VerificationSummaryChecksInnerFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationSummaryChecksInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
