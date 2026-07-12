// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CategoryListResponseCWProxy {
  CategoryListResponse items(List<Category> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CategoryListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CategoryListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CategoryListResponse call({List<Category> items});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCategoryListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCategoryListResponse.copyWith.fieldName(...)`
class _$CategoryListResponseCWProxyImpl
    implements _$CategoryListResponseCWProxy {
  const _$CategoryListResponseCWProxyImpl(this._value);

  final CategoryListResponse _value;

  @override
  CategoryListResponse items(List<Category> items) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CategoryListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CategoryListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CategoryListResponse call({Object? items = const $CopyWithPlaceholder()}) {
    return CategoryListResponse(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<Category>,
    );
  }
}

extension $CategoryListResponseCopyWith on CategoryListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCategoryListResponse.copyWith(...)` or like so:`instanceOfCategoryListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CategoryListResponseCWProxy get copyWith =>
      _$CategoryListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryListResponse _$CategoryListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CategoryListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['items']);
  final val = CategoryListResponse(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$CategoryListResponseToJson(
  CategoryListResponse instance,
) => <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
