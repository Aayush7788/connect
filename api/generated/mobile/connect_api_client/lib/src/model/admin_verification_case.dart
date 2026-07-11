//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/profile_summary.dart';
import 'package:connect_api_client/src/model/admin_verification_case_private_document_access_inner.dart';
import 'package:connect_api_client/src/model/verification_case_status.dart';
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

    required  this.id,

    required  this.status,

    required  this.profile,

     this.checks,

     this.privateDocumentAccess,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final VerificationCaseStatus status;



  @JsonKey(
    
    name: r'profile',
    required: true,
    includeIfNull: false,
  )


  final ProfileSummary profile;



  @JsonKey(
    
    name: r'checks',
    required: false,
    includeIfNull: false,
  )


  final List<Map<String, Object>>? checks;



  @JsonKey(
    
    name: r'private_document_access',
    required: false,
    includeIfNull: false,
  )


  final List<AdminVerificationCasePrivateDocumentAccessInner>? privateDocumentAccess;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminVerificationCase &&
      other.id == id &&
      other.status == status &&
      other.profile == profile &&
      other.checks == checks &&
      other.privateDocumentAccess == privateDocumentAccess;

    @override
    int get hashCode =>
        id.hashCode +
        status.hashCode +
        profile.hashCode +
        checks.hashCode +
        privateDocumentAccess.hashCode;

  factory AdminVerificationCase.fromJson(Map<String, dynamic> json) => _$AdminVerificationCaseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminVerificationCaseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

