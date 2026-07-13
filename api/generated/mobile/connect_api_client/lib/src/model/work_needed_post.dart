//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/work_needed_post_status.dart';
import 'package:connect_api_client/src/model/media_asset.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'work_needed_post.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkNeededPost {
  /// Returns a new [WorkNeededPost] instance.
  WorkNeededPost({

    required  this.id,

    required  this.profileId,

    required  this.status,

    required  this.title,

     this.categoryId,

     this.categoryName,

     this.customCategoryText,

     this.workNameId,

     this.workName,

     this.customWorkName,

    required  this.productTypeIds,

    required  this.customProductTexts,

    required  this.productTypes,

     this.description,

    required  this.photoCount,

    required  this.photos,

     this.lastActivityAt,

     this.closedAt,

    required  this.createdAt,

    required  this.updatedAt,
  });

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

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final WorkNeededPostStatus status;



  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'category_id',
    required: false,
    includeIfNull: false,
  )


  final String? categoryId;



  @JsonKey(

    name: r'category_name',
    required: false,
    includeIfNull: false,
  )


  final String? categoryName;



  @JsonKey(

    name: r'custom_category_text',
    required: false,
    includeIfNull: false,
  )


  final String? customCategoryText;



  @JsonKey(

    name: r'work_name_id',
    required: false,
    includeIfNull: false,
  )


  final String? workNameId;



  @JsonKey(

    name: r'work_name',
    required: false,
    includeIfNull: false,
  )


  final String? workName;



  @JsonKey(

    name: r'custom_work_name',
    required: false,
    includeIfNull: false,
  )


  final String? customWorkName;



  @JsonKey(

    name: r'product_type_ids',
    required: true,
    includeIfNull: false,
  )


  final List<String> productTypeIds;



  @JsonKey(

    name: r'custom_product_texts',
    required: true,
    includeIfNull: false,
  )


  final List<String> customProductTexts;



  @JsonKey(

    name: r'product_types',
    required: true,
    includeIfNull: false,
  )


  final List<String> productTypes;



  @JsonKey(

    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



          // minimum: 0
  @JsonKey(

    name: r'photo_count',
    required: true,
    includeIfNull: false,
  )


  final int photoCount;



  @JsonKey(

    name: r'photos',
    required: true,
    includeIfNull: false,
  )


  final List<MediaAsset> photos;



  @JsonKey(

    name: r'last_activity_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastActivityAt;



  @JsonKey(

    name: r'closed_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? closedAt;



  @JsonKey(

    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(

    name: r'updated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WorkNeededPost &&
      other.id == id &&
      other.profileId == profileId &&
      other.status == status &&
      other.title == title &&
      other.categoryId == categoryId &&
      other.categoryName == categoryName &&
      other.customCategoryText == customCategoryText &&
      other.workNameId == workNameId &&
      other.workName == workName &&
      other.customWorkName == customWorkName &&
      other.productTypeIds == productTypeIds &&
      other.customProductTexts == customProductTexts &&
      other.productTypes == productTypes &&
      other.description == description &&
      other.photoCount == photoCount &&
      other.photos == photos &&
      other.lastActivityAt == lastActivityAt &&
      other.closedAt == closedAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        profileId.hashCode +
        status.hashCode +
        title.hashCode +
        categoryId.hashCode +
        categoryName.hashCode +
        customCategoryText.hashCode +
        workNameId.hashCode +
        workName.hashCode +
        customWorkName.hashCode +
        productTypeIds.hashCode +
        customProductTexts.hashCode +
        productTypes.hashCode +
        description.hashCode +
        photoCount.hashCode +
        photos.hashCode +
        lastActivityAt.hashCode +
        closedAt.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory WorkNeededPost.fromJson(Map<String, dynamic> json) => _$WorkNeededPostFromJson(json);

  Map<String, dynamic> toJson() => _$WorkNeededPostToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

