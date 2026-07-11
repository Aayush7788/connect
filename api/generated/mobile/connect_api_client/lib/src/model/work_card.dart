//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/work_card_status.dart';
import 'package:connect_api_client/src/model/media_asset.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'work_card.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkCard {
  /// Returns a new [WorkCard] instance.
  WorkCard({

    required  this.id,

    required  this.status,

    required  this.workName,

     this.customWorkName,

     this.categoryId,

    required  this.categoryName,

    required  this.productTypes,

     this.description,

    required  this.photoCount,

     this.photos,
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


  final WorkCardStatus status;



  @JsonKey(
    
    name: r'work_name',
    required: true,
    includeIfNull: false,
  )


  final String workName;



  @JsonKey(
    
    name: r'custom_work_name',
    required: false,
    includeIfNull: false,
  )


  final String? customWorkName;



  @JsonKey(
    
    name: r'category_id',
    required: false,
    includeIfNull: false,
  )


  final String? categoryId;



  @JsonKey(
    
    name: r'category_name',
    required: true,
    includeIfNull: false,
  )


  final String categoryName;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is WorkCard &&
      other.id == id &&
      other.status == status &&
      other.workName == workName &&
      other.customWorkName == customWorkName &&
      other.categoryId == categoryId &&
      other.categoryName == categoryName &&
      other.productTypes == productTypes &&
      other.description == description &&
      other.photoCount == photoCount &&
      other.photos == photos;

    @override
    int get hashCode =>
        id.hashCode +
        status.hashCode +
        workName.hashCode +
        customWorkName.hashCode +
        categoryId.hashCode +
        categoryName.hashCode +
        productTypes.hashCode +
        description.hashCode +
        photoCount.hashCode +
        photos.hashCode;

  factory WorkCard.fromJson(Map<String, dynamic> json) => _$WorkCardFromJson(json);

  Map<String, dynamic> toJson() => _$WorkCardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

