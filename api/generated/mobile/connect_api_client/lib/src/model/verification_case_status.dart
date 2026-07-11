//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum VerificationCaseStatus {
      @JsonValue(r'pending')
      pending(r'pending'),
      @JsonValue(r'approved')
      approved(r'approved'),
      @JsonValue(r'changes_requested')
      changesRequested(r'changes_requested'),
      @JsonValue(r'rejected')
      rejected(r'rejected');

  const VerificationCaseStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
