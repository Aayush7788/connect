//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum VerificationCaseStatus {
  @JsonValue(r'draft')
  draft(r'draft'),
  @JsonValue(r'pending_review')
  pendingReview(r'pending_review'),
  @JsonValue(r'changes_requested')
  changesRequested(r'changes_requested'),
  @JsonValue(r'approved')
  approved(r'approved'),
  @JsonValue(r'rejected')
  rejected(r'rejected'),
  @JsonValue(r'cancelled')
  cancelled(r'cancelled');

  const VerificationCaseStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
