//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_approve_verification_case_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminApproveVerificationCaseRequest {
  /// Returns a new [AdminApproveVerificationCaseRequest] instance.
  AdminApproveVerificationCaseRequest({this.notes});

  @JsonKey(name: r'notes', required: false, includeIfNull: false)
  final String? notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminApproveVerificationCaseRequest && other.notes == notes;

  @override
  int get hashCode => notes.hashCode;

  factory AdminApproveVerificationCaseRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$AdminApproveVerificationCaseRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AdminApproveVerificationCaseRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
