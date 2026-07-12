//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum CategoryType {
      @JsonValue(r'business_category')
      businessCategory(r'business_category'),
      @JsonValue(r'work_category')
      workCategory(r'work_category'),
      @JsonValue(r'work_name')
      workName(r'work_name'),
      @JsonValue(r'product_type')
      productType(r'product_type'),
      @JsonValue(r'skill')
      skill(r'skill');

  const CategoryType(this.value);

  final String value;

  @override
  String toString() => value;
}
