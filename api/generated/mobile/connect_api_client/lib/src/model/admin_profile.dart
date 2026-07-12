//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/profile_visibility_status.dart';
import 'package:connect_api_client/src/model/user_role.dart';
import 'package:connect_api_client/src/model/verification_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_profile.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminProfile {
  /// Returns a new [AdminProfile] instance.
  AdminProfile({

    required  this.id,

    required  this.role,

     this.displayName,

    required  this.visibilityStatus,

    required  this.completionScore,

     this.completionFlags,

    required  this.verificationStatus,

    required  this.isVerified,

     this.reverificationRequired,

     this.ownerUserId,

     this.isAdminSeeded,

     this.claimStatus,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final UserRole role;



  @JsonKey(
    
    name: r'display_name',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'visibility_status',
    required: true,
    includeIfNull: false,
  )


  final ProfileVisibilityStatus visibilityStatus;



          // minimum: 0
          // maximum: 100
  @JsonKey(
    
    name: r'completion_score',
    required: true,
    includeIfNull: false,
  )


  final int completionScore;



  @JsonKey(
    
    name: r'completion_flags',
    required: false,
    includeIfNull: false,
  )


  final Map<String, bool>? completionFlags;



  @JsonKey(
    
    name: r'verification_status',
    required: true,
    includeIfNull: false,
  )


  final VerificationStatus verificationStatus;



  @JsonKey(
    
    name: r'is_verified',
    required: true,
    includeIfNull: false,
  )


  final bool isVerified;



  @JsonKey(
    
    name: r'reverification_required',
    required: false,
    includeIfNull: false,
  )


  final bool? reverificationRequired;



  @JsonKey(
    
    name: r'owner_user_id',
    required: false,
    includeIfNull: false,
  )


  final String? ownerUserId;



  @JsonKey(
    
    name: r'is_admin_seeded',
    required: false,
    includeIfNull: false,
  )


  final bool? isAdminSeeded;



  @JsonKey(
    
    name: r'claim_status',
    required: false,
    includeIfNull: false,
  )


  final AdminProfileClaimStatusEnum? claimStatus;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminProfile &&
      other.id == id &&
      other.role == role &&
      other.displayName == displayName &&
      other.visibilityStatus == visibilityStatus &&
      other.completionScore == completionScore &&
      other.completionFlags == completionFlags &&
      other.verificationStatus == verificationStatus &&
      other.isVerified == isVerified &&
      other.reverificationRequired == reverificationRequired &&
      other.ownerUserId == ownerUserId &&
      other.isAdminSeeded == isAdminSeeded &&
      other.claimStatus == claimStatus;

    @override
    int get hashCode =>
        id.hashCode +
        role.hashCode +
        displayName.hashCode +
        visibilityStatus.hashCode +
        completionScore.hashCode +
        completionFlags.hashCode +
        verificationStatus.hashCode +
        isVerified.hashCode +
        reverificationRequired.hashCode +
        ownerUserId.hashCode +
        isAdminSeeded.hashCode +
        claimStatus.hashCode;

  factory AdminProfile.fromJson(Map<String, dynamic> json) => _$AdminProfileFromJson(json);

  Map<String, dynamic> toJson() => _$AdminProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AdminProfileClaimStatusEnum {
@JsonValue(r'unclaimed')
unclaimed(r'unclaimed'),
@JsonValue(r'claimed')
claimed(r'claimed'),
@JsonValue(r'not_applicable')
notApplicable(r'not_applicable');

const AdminProfileClaimStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


