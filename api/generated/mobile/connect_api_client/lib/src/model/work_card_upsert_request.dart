//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'work_card_upsert_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkCardUpsertRequest {
  /// Returns a new [WorkCardUpsertRequest] instance.
  WorkCardUpsertRequest({

     this.categoryId,

     this.customCategoryText,

     this.workNameId,

     this.customWorkName,

     this.productTypeIds,

     this.customProductTexts,

     this.description,

     this.experienceYears,
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



          // minimum: 0
          // maximum: 100
  @JsonKey(

    name: r'experience_years',
    required: false,
    includeIfNull: false,
  )


  final int? experienceYears;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WorkCardUpsertRequest &&
      other.categoryId == categoryId &&
      other.customCategoryText == customCategoryText &&
      other.workNameId == workNameId &&
      other.customWorkName == customWorkName &&
      other.productTypeIds == productTypeIds &&
      other.customProductTexts == customProductTexts &&
      other.description == description &&
      other.experienceYears == experienceYears;

    @override
    int get hashCode =>
        categoryId.hashCode +
        customCategoryText.hashCode +
        workNameId.hashCode +
        customWorkName.hashCode +
        productTypeIds.hashCode +
        customProductTexts.hashCode +
        description.hashCode +
        experienceYears.hashCode;

  factory WorkCardUpsertRequest.fromJson(Map<String, dynamic> json) => _$WorkCardUpsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WorkCardUpsertRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
