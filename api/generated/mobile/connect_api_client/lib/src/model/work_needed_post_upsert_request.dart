//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'work_needed_post_upsert_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkNeededPostUpsertRequest {
  /// Returns a new [WorkNeededPostUpsertRequest] instance.
  WorkNeededPostUpsertRequest({

     this.categoryId,

     this.customCategoryText,

     this.workNameId,

     this.customWorkName,

     this.productTypeIds,

     this.customProductTexts,

     this.description,
  });

  @JsonKey(
    
    name: r'category_id',
    required: false,
    includeIfNull: false,
  )


  final String? categoryId;



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
    
    name: r'custom_work_name',
    required: false,
    includeIfNull: false,
  )


  final String? customWorkName;



  @JsonKey(
    
    name: r'product_type_ids',
    required: false,
    includeIfNull: false,
  )


  final List<String>? productTypeIds;



  @JsonKey(
    
    name: r'custom_product_texts',
    required: false,
    includeIfNull: false,
  )


  final List<String>? customProductTexts;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WorkNeededPostUpsertRequest &&
      other.categoryId == categoryId &&
      other.customCategoryText == customCategoryText &&
      other.workNameId == workNameId &&
      other.customWorkName == customWorkName &&
      other.productTypeIds == productTypeIds &&
      other.customProductTexts == customProductTexts &&
      other.description == description;

    @override
    int get hashCode =>
        categoryId.hashCode +
        customCategoryText.hashCode +
        workNameId.hashCode +
        customWorkName.hashCode +
        productTypeIds.hashCode +
        customProductTexts.hashCode +
        description.hashCode;

  factory WorkNeededPostUpsertRequest.fromJson(Map<String, dynamic> json) => _$WorkNeededPostUpsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WorkNeededPostUpsertRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

