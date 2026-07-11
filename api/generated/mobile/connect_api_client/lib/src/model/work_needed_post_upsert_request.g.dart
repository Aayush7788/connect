// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_needed_post_upsert_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkNeededPostUpsertRequestCWProxy {
  WorkNeededPostUpsertRequest categoryId(String? categoryId);

  WorkNeededPostUpsertRequest customCategoryText(String? customCategoryText);

  WorkNeededPostUpsertRequest workNameId(String? workNameId);

  WorkNeededPostUpsertRequest customWorkName(String? customWorkName);

  WorkNeededPostUpsertRequest productTypeIds(List<String>? productTypeIds);

  WorkNeededPostUpsertRequest customProductTexts(
    List<String>? customProductTexts,
  );

  WorkNeededPostUpsertRequest description(String? description);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkNeededPostUpsertRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkNeededPostUpsertRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkNeededPostUpsertRequest call({
    String? categoryId,
    String? customCategoryText,
    String? workNameId,
    String? customWorkName,
    List<String>? productTypeIds,
    List<String>? customProductTexts,
    String? description,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkNeededPostUpsertRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkNeededPostUpsertRequest.copyWith.fieldName(...)`
class _$WorkNeededPostUpsertRequestCWProxyImpl
    implements _$WorkNeededPostUpsertRequestCWProxy {
  const _$WorkNeededPostUpsertRequestCWProxyImpl(this._value);

  final WorkNeededPostUpsertRequest _value;

  @override
  WorkNeededPostUpsertRequest categoryId(String? categoryId) =>
      this(categoryId: categoryId);

  @override
  WorkNeededPostUpsertRequest customCategoryText(String? customCategoryText) =>
      this(customCategoryText: customCategoryText);

  @override
  WorkNeededPostUpsertRequest workNameId(String? workNameId) =>
      this(workNameId: workNameId);

  @override
  WorkNeededPostUpsertRequest customWorkName(String? customWorkName) =>
      this(customWorkName: customWorkName);

  @override
  WorkNeededPostUpsertRequest productTypeIds(List<String>? productTypeIds) =>
      this(productTypeIds: productTypeIds);

  @override
  WorkNeededPostUpsertRequest customProductTexts(
    List<String>? customProductTexts,
  ) => this(customProductTexts: customProductTexts);

  @override
  WorkNeededPostUpsertRequest description(String? description) =>
      this(description: description);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkNeededPostUpsertRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkNeededPostUpsertRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkNeededPostUpsertRequest call({
    Object? categoryId = const $CopyWithPlaceholder(),
    Object? customCategoryText = const $CopyWithPlaceholder(),
    Object? workNameId = const $CopyWithPlaceholder(),
    Object? customWorkName = const $CopyWithPlaceholder(),
    Object? productTypeIds = const $CopyWithPlaceholder(),
    Object? customProductTexts = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
  }) {
    return WorkNeededPostUpsertRequest(
      categoryId: categoryId == const $CopyWithPlaceholder()
          ? _value.categoryId
          // ignore: cast_nullable_to_non_nullable
          : categoryId as String?,
      customCategoryText: customCategoryText == const $CopyWithPlaceholder()
          ? _value.customCategoryText
          // ignore: cast_nullable_to_non_nullable
          : customCategoryText as String?,
      workNameId: workNameId == const $CopyWithPlaceholder()
          ? _value.workNameId
          // ignore: cast_nullable_to_non_nullable
          : workNameId as String?,
      customWorkName: customWorkName == const $CopyWithPlaceholder()
          ? _value.customWorkName
          // ignore: cast_nullable_to_non_nullable
          : customWorkName as String?,
      productTypeIds: productTypeIds == const $CopyWithPlaceholder()
          ? _value.productTypeIds
          // ignore: cast_nullable_to_non_nullable
          : productTypeIds as List<String>?,
      customProductTexts: customProductTexts == const $CopyWithPlaceholder()
          ? _value.customProductTexts
          // ignore: cast_nullable_to_non_nullable
          : customProductTexts as List<String>?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
    );
  }
}

extension $WorkNeededPostUpsertRequestCopyWith on WorkNeededPostUpsertRequest {
  /// Returns a callable class that can be used as follows: `instanceOfWorkNeededPostUpsertRequest.copyWith(...)` or like so:`instanceOfWorkNeededPostUpsertRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkNeededPostUpsertRequestCWProxy get copyWith =>
      _$WorkNeededPostUpsertRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkNeededPostUpsertRequest _$WorkNeededPostUpsertRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'WorkNeededPostUpsertRequest',
  json,
  ($checkedConvert) {
    final val = WorkNeededPostUpsertRequest(
      categoryId: $checkedConvert('category_id', (v) => v as String?),
      customCategoryText: $checkedConvert(
        'custom_category_text',
        (v) => v as String?,
      ),
      workNameId: $checkedConvert('work_name_id', (v) => v as String?),
      customWorkName: $checkedConvert('custom_work_name', (v) => v as String?),
      productTypeIds: $checkedConvert(
        'product_type_ids',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      customProductTexts: $checkedConvert(
        'custom_product_texts',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      description: $checkedConvert('description', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'categoryId': 'category_id',
    'customCategoryText': 'custom_category_text',
    'workNameId': 'work_name_id',
    'customWorkName': 'custom_work_name',
    'productTypeIds': 'product_type_ids',
    'customProductTexts': 'custom_product_texts',
  },
);

Map<String, dynamic> _$WorkNeededPostUpsertRequestToJson(
  WorkNeededPostUpsertRequest instance,
) => <String, dynamic>{
  'category_id': ?instance.categoryId,
  'custom_category_text': ?instance.customCategoryText,
  'work_name_id': ?instance.workNameId,
  'custom_work_name': ?instance.customWorkName,
  'product_type_ids': ?instance.productTypeIds,
  'custom_product_texts': ?instance.customProductTexts,
  'description': ?instance.description,
};
