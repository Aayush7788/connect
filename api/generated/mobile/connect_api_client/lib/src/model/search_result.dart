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

     this.profileId,

    required  this.title,

     this.subtitle,

     this.category,

     this.productTypes,

     this.isVerified,

     this.photos,
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
    required: false,
    includeIfNull: false,
  )


  final String? profileId;



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
    
    name: r'is_verified',
    required: false,
    includeIfNull: false,
  )


  final bool? isVerified;



  @JsonKey(
    
    name: r'photos',
    required: false,
    includeIfNull: false,
  )


  final List<MediaAsset>? photos;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SearchResult &&
      other.resultType == resultType &&
      other.id == id &&
      other.profileId == profileId &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.category == category &&
      other.productTypes == productTypes &&
      other.isVerified == isVerified &&
      other.photos == photos;

    @override
    int get hashCode =>
        resultType.hashCode +
        id.hashCode +
        profileId.hashCode +
        title.hashCode +
        subtitle.hashCode +
        category.hashCode +
        productTypes.hashCode +
        isVerified.hashCode +
        photos.hashCode;

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


