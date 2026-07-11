//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/user_role.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_seed_profile_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminSeedProfileRequest {
  /// Returns a new [AdminSeedProfileRequest] instance.
  AdminSeedProfileRequest({

    required  this.role,

    required  this.displayName,

     this.profileData,

     this.makePublic = false,
  });

  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final UserRole role;



  @JsonKey(
    
    name: r'display_name',
    required: true,
    includeIfNull: false,
  )


  final String displayName;



  @JsonKey(
    
    name: r'profile_data',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? profileData;



  @JsonKey(
    defaultValue: false,
    name: r'make_public',
    required: false,
    includeIfNull: false,
  )


  final bool? makePublic;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminSeedProfileRequest &&
      other.role == role &&
      other.displayName == displayName &&
      other.profileData == profileData &&
      other.makePublic == makePublic;

    @override
    int get hashCode =>
        role.hashCode +
        displayName.hashCode +
        profileData.hashCode +
        makePublic.hashCode;

  factory AdminSeedProfileRequest.fromJson(Map<String, dynamic> json) => _$AdminSeedProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSeedProfileRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

