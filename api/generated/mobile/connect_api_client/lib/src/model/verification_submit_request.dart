//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verification_submit_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerificationSubmitRequest {
  /// Returns a new [VerificationSubmitRequest] instance.
  VerificationSubmitRequest({
    this.consentVersion,

    this.consentAccepted = false,
  });

  @JsonKey(name: r'consent_version', required: false, includeIfNull: false)
  final String? consentVersion;

  @JsonKey(
    defaultValue: false,
    name: r'consent_accepted',
    required: false,
    includeIfNull: false,
  )
  final bool? consentAccepted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerificationSubmitRequest &&
          other.consentVersion == consentVersion &&
          other.consentAccepted == consentAccepted;

  @override
  int get hashCode => consentVersion.hashCode + consentAccepted.hashCode;

  factory VerificationSubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$VerificationSubmitRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationSubmitRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
