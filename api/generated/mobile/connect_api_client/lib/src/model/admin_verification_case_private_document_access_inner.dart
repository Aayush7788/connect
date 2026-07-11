//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_verification_case_private_document_access_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminVerificationCasePrivateDocumentAccessInner {
  /// Returns a new [AdminVerificationCasePrivateDocumentAccessInner] instance.
  AdminVerificationCasePrivateDocumentAccessInner({

     this.mediaAssetId,

     this.accessUrl,

     this.expiresAt,
  });

  @JsonKey(
    
    name: r'media_asset_id',
    required: false,
    includeIfNull: false,
  )


  final String? mediaAssetId;



  @JsonKey(
    
    name: r'access_url',
    required: false,
    includeIfNull: false,
  )


  final String? accessUrl;



  @JsonKey(
    
    name: r'expires_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminVerificationCasePrivateDocumentAccessInner &&
      other.mediaAssetId == mediaAssetId &&
      other.accessUrl == accessUrl &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        mediaAssetId.hashCode +
        accessUrl.hashCode +
        expiresAt.hashCode;

  factory AdminVerificationCasePrivateDocumentAccessInner.fromJson(Map<String, dynamic> json) => _$AdminVerificationCasePrivateDocumentAccessInnerFromJson(json);

  Map<String, dynamic> toJson() => _$AdminVerificationCasePrivateDocumentAccessInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

