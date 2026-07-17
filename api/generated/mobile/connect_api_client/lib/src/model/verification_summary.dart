//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/verification_case_status.dart';
import 'package:connect_api_client/src/model/verification_summary_safe_documents_inner.dart';
import 'package:connect_api_client/src/model/verification_summary_checks_inner.dart';
import 'package:connect_api_client/src/model/verification_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verification_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerificationSummary {
  /// Returns a new [VerificationSummary] instance.
  VerificationSummary({
    required this.verificationStatus,

    required this.isVerified,

    this.reverificationRequired,

    this.activeCaseId,

    this.caseStatus,

    this.notesToUser,

    this.submittedAt,

    this.checks,

    this.safeDocuments,
  });

  @JsonKey(name: r'verification_status', required: true, includeIfNull: false)
  final VerificationStatus verificationStatus;

  @JsonKey(name: r'is_verified', required: true, includeIfNull: false)
  final bool isVerified;

  @JsonKey(
    name: r'reverification_required',
    required: false,
    includeIfNull: false,
  )
  final bool? reverificationRequired;

  @JsonKey(name: r'active_case_id', required: false, includeIfNull: false)
  final String? activeCaseId;

  @JsonKey(name: r'case_status', required: false, includeIfNull: false)
  final VerificationCaseStatus? caseStatus;

  @JsonKey(name: r'notes_to_user', required: false, includeIfNull: false)
  final String? notesToUser;

  @JsonKey(name: r'submitted_at', required: false, includeIfNull: false)
  final DateTime? submittedAt;

  @JsonKey(name: r'checks', required: false, includeIfNull: false)
  final List<VerificationSummaryChecksInner>? checks;

  @JsonKey(name: r'safe_documents', required: false, includeIfNull: false)
  final List<VerificationSummarySafeDocumentsInner>? safeDocuments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerificationSummary &&
          other.verificationStatus == verificationStatus &&
          other.isVerified == isVerified &&
          other.reverificationRequired == reverificationRequired &&
          other.activeCaseId == activeCaseId &&
          other.caseStatus == caseStatus &&
          other.notesToUser == notesToUser &&
          other.submittedAt == submittedAt &&
          other.checks == checks &&
          other.safeDocuments == safeDocuments;

  @override
  int get hashCode =>
      verificationStatus.hashCode +
      isVerified.hashCode +
      reverificationRequired.hashCode +
      activeCaseId.hashCode +
      caseStatus.hashCode +
      notesToUser.hashCode +
      submittedAt.hashCode +
      checks.hashCode +
      safeDocuments.hashCode;

  factory VerificationSummary.fromJson(Map<String, dynamic> json) =>
      _$VerificationSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
