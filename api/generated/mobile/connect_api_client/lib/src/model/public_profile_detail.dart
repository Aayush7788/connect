//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/profile_summary.dart';
import 'package:connect_api_client/src/model/work_card.dart';
import 'package:connect_api_client/src/model/media_asset.dart';
import 'package:connect_api_client/src/model/work_needed_post.dart';
import 'package:connect_api_client/src/model/public_contact.dart';
import 'package:connect_api_client/src/model/public_address.dart';
import 'package:connect_api_client/src/model/search_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_profile_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicProfileDetail {
  /// Returns a new [PublicProfileDetail] instance.
  PublicProfileDetail({

    required  this.profile,

    required  this.roleSpecific,

    required  this.contact,

    required  this.address,

    required  this.media,

    required  this.workCards,

    required  this.workNeededPosts,

    required  this.similarProfiles,
  });

  @JsonKey(
    
    name: r'profile',
    required: true,
    includeIfNull: false,
  )


  final ProfileSummary profile;



      /// Public role-specific business, workshop, or skill fields.
  @JsonKey(
    
    name: r'role_specific',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> roleSpecific;



  @JsonKey(
    
    name: r'contact',
    required: true,
    includeIfNull: false,
  )


  final PublicContact contact;



  @JsonKey(
    
    name: r'address',
    required: true,
    includeIfNull: false,
  )


  final PublicAddress address;



  @JsonKey(
    
    name: r'media',
    required: true,
    includeIfNull: false,
  )


  final List<MediaAsset> media;



  @JsonKey(
    
    name: r'work_cards',
    required: true,
    includeIfNull: false,
  )


  final List<WorkCard> workCards;



  @JsonKey(
    
    name: r'work_needed_posts',
    required: true,
    includeIfNull: false,
  )


  final List<WorkNeededPost> workNeededPosts;



  @JsonKey(
    
    name: r'similar_profiles',
    required: true,
    includeIfNull: false,
  )


  final List<SearchResult> similarProfiles;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicProfileDetail &&
      other.profile == profile &&
      other.roleSpecific == roleSpecific &&
      other.contact == contact &&
      other.address == address &&
      other.media == media &&
      other.workCards == workCards &&
      other.workNeededPosts == workNeededPosts &&
      other.similarProfiles == similarProfiles;

    @override
    int get hashCode =>
        profile.hashCode +
        roleSpecific.hashCode +
        contact.hashCode +
        address.hashCode +
        media.hashCode +
        workCards.hashCode +
        workNeededPosts.hashCode +
        similarProfiles.hashCode;

  factory PublicProfileDetail.fromJson(Map<String, dynamic> json) => _$PublicProfileDetailFromJson(json);

  Map<String, dynamic> toJson() => _$PublicProfileDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

