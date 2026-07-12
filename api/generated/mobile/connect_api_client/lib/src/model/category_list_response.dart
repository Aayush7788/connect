//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/category.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_list_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CategoryListResponse {
  /// Returns a new [CategoryListResponse] instance.
  CategoryListResponse({

    required  this.items,
  });

  @JsonKey(

    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<Category> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CategoryListResponse &&
      other.items == items;

    @override
    int get hashCode =>
        items.hashCode;

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) => _$CategoryListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
