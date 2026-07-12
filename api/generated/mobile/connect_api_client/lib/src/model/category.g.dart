// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CategoryCWProxy {
  Category id(String id);

  Category parentId(String? parentId);

  Category categoryType(CategoryType categoryType);

  Category name(String name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Category(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Category(...).copyWith(id: 12, name: "My name")
  /// ````
  Category call({
    String id,
    String? parentId,
    CategoryType categoryType,
    String name,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCategory.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCategory.copyWith.fieldName(...)`
class _$CategoryCWProxyImpl implements _$CategoryCWProxy {
  const _$CategoryCWProxyImpl(this._value);

  final Category _value;

  @override
  Category id(String id) => this(id: id);

  @override
  Category parentId(String? parentId) => this(parentId: parentId);

  @override
  Category categoryType(CategoryType categoryType) =>
      this(categoryType: categoryType);

  @override
  Category name(String name) => this(name: name);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Category(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Category(...).copyWith(id: 12, name: "My name")
  /// ````
  Category call({
    Object? id = const $CopyWithPlaceholder(),
    Object? parentId = const $CopyWithPlaceholder(),
    Object? categoryType = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return Category(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      parentId: parentId == const $CopyWithPlaceholder()
          ? _value.parentId
          // ignore: cast_nullable_to_non_nullable
          : parentId as String?,
      categoryType: categoryType == const $CopyWithPlaceholder()
          ? _value.categoryType
          // ignore: cast_nullable_to_non_nullable
          : categoryType as CategoryType,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $CategoryCopyWith on Category {
  /// Returns a callable class that can be used as follows: `instanceOfCategory.copyWith(...)` or like so:`instanceOfCategory.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CategoryCWProxy get copyWith => _$CategoryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Category',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['id', 'category_type', 'name']);
    final val = Category(
      id: $checkedConvert('id', (v) => v as String),
      parentId: $checkedConvert('parent_id', (v) => v as String?),
      categoryType: $checkedConvert(
        'category_type',
        (v) => $enumDecode(_$CategoryTypeEnumMap, v),
      ),
      name: $checkedConvert('name', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {'parentId': 'parent_id', 'categoryType': 'category_type'},
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'parent_id': ?instance.parentId,
  'category_type': _$CategoryTypeEnumMap[instance.categoryType]!,
  'name': instance.name,
};

const _$CategoryTypeEnumMap = {
  CategoryType.businessCategory: 'business_category',
  CategoryType.workCategory: 'work_category',
  CategoryType.workName: 'work_name',
  CategoryType.productType: 'product_type',
  CategoryType.skill: 'skill',
};
