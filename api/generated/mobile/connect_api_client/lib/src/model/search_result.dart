//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/media_asset.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SearchResult {
  /// Returns a new [SearchResult] instance.
  SearchResult({

    required  this.resultType,

    required  this.id,

    required  this.profileId,

    required  this.title,

     this.subtitle,

     this.category,

     this.productTypes,

     this.description,

     this.locality,

     this.experienceYears,

    required  this.isVerified,

    required  this.photoCount,

     this.photos,

     this.lastActivityAt,
  });

  @JsonKey(
    
    name: r'result_type',
    required: true,
    includeIfNull: false,
  )


  final SearchResultResultTypeEnum resultType;



  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'profile_id',
    required: true,
    includeIfNull: false,
  )


  final String profileId;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'subtitle',
    required: false,
    includeIfNull: false,
  )


  final String? subtitle;



  @JsonKey(
    
    name: r'category',
    required: false,
    includeIfNull: false,
  )


  final String? category;



  @JsonKey(
    
    name: r'product_types',
    required: false,
    includeIfNull: false,
  )


  final List<String>? productTypes;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'locality',
    required: false,
    includeIfNull: false,
  )


  final String? locality;



          // minimum: 0
          // maximum: 100
  @JsonKey(
    
    name: r'experience_years',
    required: false,
    includeIfNull: false,
  )


  final int? experienceYears;



  @JsonKey(
    
    name: r'is_verified',
    required: true,
    includeIfNull: false,
  )


  final bool isVerified;



          // minimum: 0
  @JsonKey(
    
    name: r'photo_count',
    required: true,
    includeIfNull: false,
  )


  final int photoCount;



  @JsonKey(
    
    name: r'photos',
    required: false,
    includeIfNull: false,
  )


  final List<MediaAsset>? photos;



  @JsonKey(
    
    name: r'last_activity_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastActivityAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SearchResult &&
      other.resultType == resultType &&
      other.id == id &&
      other.profileId == profileId &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.category == category &&
      other.productTypes == productTypes &&
      other.description == description &&
      other.locality == locality &&
      other.experienceYears == experienceYears &&
      other.isVerified == isVerified &&
      other.photoCount == photoCount &&
      other.photos == photos &&
      other.lastActivityAt == lastActivityAt;

    @override
    int get hashCode =>
        resultType.hashCode +
        id.hashCode +
        profileId.hashCode +
        title.hashCode +
        subtitle.hashCode +
        category.hashCode +
        productTypes.hashCode +
        description.hashCode +
        locality.hashCode +
        experienceYears.hashCode +
        isVerified.hashCode +
        photoCount.hashCode +
        photos.hashCode +
        lastActivityAt.hashCode;

  factory SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum SearchResultResultTypeEnum {
@JsonValue(r'profile')
profile(r'profile'),
@JsonValue(r'work_card')
workCard(r'work_card'),
@JsonValue(r'work_needed_post')
workNeededPost(r'work_needed_post');

const SearchResultResultTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


