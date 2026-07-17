//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/profile_summary.dart';
import 'package:connect_api_client/src/model/admin_verification_case_private_document_access_inner.dart';
import 'package:connect_api_client/src/model/verification_case_status.dart';
import 'package:connect_api_client/src/model/admin_verification_case_checks_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_verification_case.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminVerificationCase {
  /// Returns a new [AdminVerificationCase] instance.
  AdminVerificationCase({
    required this.id,

    required this.status,

    required this.caseReason,

    required this.profile,

    this.ownerMobile,

    this.fullAddress,

    this.submittedAt,

    this.reviewedAt,

    this.notesToUser,

    this.internalNotes,

    this.resubmissionCount,

    this.checks,

    this.privateDocumentAccess,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final VerificationCaseStatus status;

  @JsonKey(name: r'case_reason', required: true, includeIfNull: false)
  final String caseReason;

  @JsonKey(name: r'profile', required: true, includeIfNull: false)
  final ProfileSummary profile;

  @JsonKey(name: r'owner_mobile', required: false, includeIfNull: false)
  final String? ownerMobile;

  @JsonKey(name: r'full_address', required: false, includeIfNull: false)
  final String? fullAddress;

  @JsonKey(name: r'submitted_at', required: false, includeIfNull: false)
  final DateTime? submittedAt;

  @JsonKey(name: r'reviewed_at', required: false, includeIfNull: false)
  final DateTime? reviewedAt;

  @JsonKey(name: r'notes_to_user', required: false, includeIfNull: false)
  final String? notesToUser;

  @JsonKey(name: r'internal_notes', required: false, includeIfNull: false)
  final String? internalNotes;

  @JsonKey(name: r'resubmission_count', required: false, includeIfNull: false)
  final int? resubmissionCount;

  @JsonKey(name: r'checks', required: false, includeIfNull: false)
  final List<AdminVerificationCaseChecksInner>? checks;

  @JsonKey(
    name: r'private_document_access',
    required: false,
    includeIfNull: false,
  )
  final List<AdminVerificationCasePrivateDocumentAccessInner>?
  privateDocumentAccess;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminVerificationCase &&
          other.id == id &&
          other.status == status &&
          other.caseReason == caseReason &&
          other.profile == profile &&
          other.ownerMobile == ownerMobile &&
          other.fullAddress == fullAddress &&
          other.submittedAt == submittedAt &&
          other.reviewedAt == reviewedAt &&
          other.notesToUser == notesToUser &&
          other.internalNotes == internalNotes &&
          other.resubmissionCount == resubmissionCount &&
          other.checks == checks &&
          other.privateDocumentAccess == privateDocumentAccess;

  @override
  int get hashCode =>
      id.hashCode +
      status.hashCode +
      caseReason.hashCode +
      profile.hashCode +
      ownerMobile.hashCode +
      fullAddress.hashCode +
      submittedAt.hashCode +
      reviewedAt.hashCode +
      notesToUser.hashCode +
      internalNotes.hashCode +
      resubmissionCount.hashCode +
      checks.hashCode +
      privateDocumentAccess.hashCode;

  factory AdminVerificationCase.fromJson(Map<String, dynamic> json) =>
      _$AdminVerificationCaseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminVerificationCaseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
