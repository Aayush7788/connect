//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/profile_summary.dart';
import 'package:connect_api_client/src/model/media_asset.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'owner_profile_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OwnerProfileResponse {
  /// Returns a new [OwnerProfileResponse] instance.
  OwnerProfileResponse({

    required  this.profile,

     this.editableFields,

     this.lockedFields,

     this.roleSpecific,

     this.media,
  });

  @JsonKey(
    
    name: r'profile',
    required: true,
    includeIfNull: false,
  )


  final ProfileSummary profile;



  @JsonKey(
    
    name: r'editable_fields',
    required: false,
    includeIfNull: false,
  )


  final List<String>? editableFields;



  @JsonKey(
    
    name: r'locked_fields',
    required: false,
    includeIfNull: false,
  )


  final List<String>? lockedFields;



  @JsonKey(
    
    name: r'role_specific',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? roleSpecific;



  @JsonKey(
    
    name: r'media',
    required: false,
    includeIfNull: false,
  )


  final List<MediaAsset>? media;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OwnerProfileResponse &&
      other.profile == profile &&
      other.editableFields == editableFields &&
      other.lockedFields == lockedFields &&
      other.roleSpecific == roleSpecific &&
      other.media == media;

    @override
    int get hashCode =>
        profile.hashCode +
        editableFields.hashCode +
        lockedFields.hashCode +
        roleSpecific.hashCode +
        media.hashCode;

  factory OwnerProfileResponse.fromJson(Map<String, dynamic> json) => _$OwnerProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerProfileResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

