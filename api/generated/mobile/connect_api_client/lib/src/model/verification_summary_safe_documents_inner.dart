//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verification_summary_safe_documents_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerificationSummarySafeDocumentsInner {
  /// Returns a new [VerificationSummarySafeDocumentsInner] instance.
  VerificationSummarySafeDocumentsInner({
    required this.mediaAssetId,

    required this.documentType,

    required this.status,

    required this.safeDisplayName,
  });

  @JsonKey(name: r'media_asset_id', required: true, includeIfNull: false)
  final String mediaAssetId;

  @JsonKey(name: r'document_type', required: true, includeIfNull: false)
  final String documentType;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @JsonKey(name: r'safe_display_name', required: true, includeIfNull: false)
  final String safeDisplayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerificationSummarySafeDocumentsInner &&
          other.mediaAssetId == mediaAssetId &&
          other.documentType == documentType &&
          other.status == status &&
          other.safeDisplayName == safeDisplayName;

  @override
  int get hashCode =>
      mediaAssetId.hashCode +
      documentType.hashCode +
      status.hashCode +
      safeDisplayName.hashCode;

  factory VerificationSummarySafeDocumentsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$VerificationSummarySafeDocumentsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$VerificationSummarySafeDocumentsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
