//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum VerificationStatus {
      @JsonValue(r'unverified')
      unverified(r'unverified'),
      @JsonValue(r'pending')
      pending(r'pending'),
      @JsonValue(r'verified')
      verified(r'verified'),
      @JsonValue(r'changes_requested')
      changesRequested(r'changes_requested'),
      @JsonValue(r'rejected')
      rejected(r'rejected');

  const VerificationStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
