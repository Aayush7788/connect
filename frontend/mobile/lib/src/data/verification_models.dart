class VerificationCheckResult {
  const VerificationCheckResult({
    required this.checkType,
    required this.status,
    this.notesToUser,
  });

  factory VerificationCheckResult.fromJson(Map<String, dynamic> json) {
    return VerificationCheckResult(
      checkType: json['check_type'] as String,
      status: json['status'] as String,
      notesToUser: json['notes_to_user'] as String?,
    );
  }

  final String checkType;
  final String status;
  final String? notesToUser;
}

class VerificationSummaryResult {
  const VerificationSummaryResult({
    required this.verificationStatus,
    required this.isVerified,
    required this.reverificationRequired,
    required this.checks,
    this.activeCaseId,
    this.caseStatus,
    this.notesToUser,
    this.submittedAt,
  });

  factory VerificationSummaryResult.fromJson(Map<String, dynamic> json) {
    final checks = json['checks'] as List<dynamic>? ?? const [];
    return VerificationSummaryResult(
      verificationStatus: json['verification_status'] as String,
      isVerified: json['is_verified'] as bool,
      reverificationRequired: json['reverification_required'] as bool? ?? false,
      activeCaseId: json['active_case_id'] as String?,
      caseStatus: json['case_status'] as String?,
      notesToUser: json['notes_to_user'] as String?,
      submittedAt: json['submitted_at'] == null
          ? null
          : DateTime.parse(json['submitted_at'] as String),
      checks: checks
          .map(
            (item) =>
                VerificationCheckResult.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  final String verificationStatus;
  final bool isVerified;
  final bool reverificationRequired;
  final String? activeCaseId;
  final String? caseStatus;
  final String? notesToUser;
  final DateTime? submittedAt;
  final List<VerificationCheckResult> checks;
}
