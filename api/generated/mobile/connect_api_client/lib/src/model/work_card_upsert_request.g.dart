// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_card_upsert_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkCardUpsertRequestCWProxy {
  WorkCardUpsertRequest categoryId(String? categoryId);

  WorkCardUpsertRequest customCategoryText(String? customCategoryText);

  WorkCardUpsertRequest workNameId(String? workNameId);

  WorkCardUpsertRequest customWorkName(String? customWorkName);

  WorkCardUpsertRequest productTypeIds(List<String>? productTypeIds);

  WorkCardUpsertRequest customProductTexts(List<String>? customProductTexts);

  WorkCardUpsertRequest description(String? description);

  WorkCardUpsertRequest experienceYears(int? experienceYears);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkCardUpsertRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkCardUpsertRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkCardUpsertRequest call({
    String? categoryId,
    String? customCategoryText,
    String? workNameId,
    String? customWorkName,
    List<String>? productTypeIds,
    List<String>? customProductTexts,
    String? description,
    int? experienceYears,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkCardUpsertRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkCardUpsertRequest.copyWith.fieldName(...)`
class _$WorkCardUpsertRequestCWProxyImpl
    implements _$WorkCardUpsertRequestCWProxy {
  const _$WorkCardUpsertRequestCWProxyImpl(this._value);

  final WorkCardUpsertRequest _value;

  @override
  WorkCardUpsertRequest categoryId(String? categoryId) =>
      this(categoryId: categoryId);

  @override
  WorkCardUpsertRequest customCategoryText(String? customCategoryText) =>
      this(customCategoryText: customCategoryText);

  @override
  WorkCardUpsertRequest workNameId(String? workNameId) =>
      this(workNameId: workNameId);

  @override
  WorkCardUpsertRequest customWorkName(String? customWorkName) =>
      this(customWorkName: customWorkName);

  @override
  WorkCardUpsertRequest productTypeIds(List<String>? productTypeIds) =>
      this(productTypeIds: productTypeIds);

  @override
  WorkCardUpsertRequest customProductTexts(List<String>? customProductTexts) =>
      this(customProductTexts: customProductTexts);

  @override
  WorkCardUpsertRequest description(String? description) =>
      this(description: description);

  @override
  WorkCardUpsertRequest experienceYears(int? experienceYears) =>
      this(experienceYears: experienceYears);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkCardUpsertRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkCardUpsertRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkCardUpsertRequest call({
    Object? categoryId = const $CopyWithPlaceholder(),
    Object? customCategoryText = const $CopyWithPlaceholder(),
    Object? workNameId = const $CopyWithPlaceholder(),
    Object? customWorkName = const $CopyWithPlaceholder(),
    Object? productTypeIds = const $CopyWithPlaceholder(),
    Object? customProductTexts = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? experienceYears = const $CopyWithPlaceholder(),
  }) {
    return WorkCardUpsertRequest(
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
      experienceYears: experienceYears == const $CopyWithPlaceholder()
          ? _value.experienceYears
          // ignore: cast_nullable_to_non_nullable
          : experienceYears as int?,
    );
  }
}

extension $WorkCardUpsertRequestCopyWith on WorkCardUpsertRequest {
  /// Returns a callable class that can be used as follows: `instanceOfWorkCardUpsertRequest.copyWith(...)` or like so:`instanceOfWorkCardUpsertRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkCardUpsertRequestCWProxy get copyWith =>
      _$WorkCardUpsertRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkCardUpsertRequest _$WorkCardUpsertRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'WorkCardUpsertRequest',
  json,
  ($checkedConvert) {
    final val = WorkCardUpsertRequest(
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
      experienceYears: $checkedConvert(
        'experience_years',
        (v) => (v as num?)?.toInt(),
      ),
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
    'experienceYears': 'experience_years',
  },
);

Map<String, dynamic> _$WorkCardUpsertRequestToJson(
  WorkCardUpsertRequest instance,
) => <String, dynamic>{
  'category_id': ?instance.categoryId,
  'custom_category_text': ?instance.customCategoryText,
  'work_name_id': ?instance.workNameId,
  'custom_work_name': ?instance.customWorkName,
  'product_type_ids': ?instance.productTypeIds,
  'custom_product_texts': ?instance.customProductTexts,
  'description': ?instance.description,
  'experience_years': ?instance.experienceYears,
};
