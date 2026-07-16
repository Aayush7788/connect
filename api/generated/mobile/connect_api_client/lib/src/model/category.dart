//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/category_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Category {
  /// Returns a new [Category] instance.
  Category({

    required  this.id,

     this.parentId,

    required  this.categoryType,

    required  this.name,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'parent_id',
    required: false,
    includeIfNull: false,
  )


  final String? parentId;



  @JsonKey(
    
    name: r'category_type',
    required: true,
    includeIfNull: false,
  )


  final CategoryType categoryType;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Category &&
      other.id == id &&
      other.parentId == parentId &&
      other.categoryType == categoryType &&
      other.name == name;

    @override
    int get hashCode =>
        id.hashCode +
        parentId.hashCode +
        categoryType.hashCode +
        name.hashCode;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

