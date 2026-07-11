// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_card.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkCardCWProxy {
  WorkCard id(String id);

  WorkCard status(WorkCardStatus status);

  WorkCard workName(String workName);

  WorkCard customWorkName(String? customWorkName);

  WorkCard categoryId(String? categoryId);

  WorkCard categoryName(String categoryName);

  WorkCard productTypes(List<String> productTypes);

  WorkCard description(String? description);

  WorkCard photoCount(int photoCount);

  WorkCard photos(List<MediaAsset>? photos);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkCard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkCard(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkCard call({
    String id,
    WorkCardStatus status,
    String workName,
    String? customWorkName,
    String? categoryId,
    String categoryName,
    List<String> productTypes,
    String? description,
    int photoCount,
    List<MediaAsset>? photos,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkCard.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkCard.copyWith.fieldName(...)`
class _$WorkCardCWProxyImpl implements _$WorkCardCWProxy {
  const _$WorkCardCWProxyImpl(this._value);

  final WorkCard _value;

  @override
  WorkCard id(String id) => this(id: id);

  @override
  WorkCard status(WorkCardStatus status) => this(status: status);

  @override
  WorkCard workName(String workName) => this(workName: workName);

  @override
  WorkCard customWorkName(String? customWorkName) =>
      this(customWorkName: customWorkName);

  @override
  WorkCard categoryId(String? categoryId) => this(categoryId: categoryId);

  @override
  WorkCard categoryName(String categoryName) =>
      this(categoryName: categoryName);

  @override
  WorkCard productTypes(List<String> productTypes) =>
      this(productTypes: productTypes);

  @override
  WorkCard description(String? description) => this(description: description);

  @override
  WorkCard photoCount(int photoCount) => this(photoCount: photoCount);

  @override
  WorkCard photos(List<MediaAsset>? photos) => this(photos: photos);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkCard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkCard(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkCard call({
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? workName = const $CopyWithPlaceholder(),
    Object? customWorkName = const $CopyWithPlaceholder(),
    Object? categoryId = const $CopyWithPlaceholder(),
    Object? categoryName = const $CopyWithPlaceholder(),
    Object? productTypes = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? photoCount = const $CopyWithPlaceholder(),
    Object? photos = const $CopyWithPlaceholder(),
  }) {
    return WorkCard(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as WorkCardStatus,
      workName: workName == const $CopyWithPlaceholder()
          ? _value.workName
          // ignore: cast_nullable_to_non_nullable
          : workName as String,
      customWorkName: customWorkName == const $CopyWithPlaceholder()
          ? _value.customWorkName
          // ignore: cast_nullable_to_non_nullable
          : customWorkName as String?,
      categoryId: categoryId == const $CopyWithPlaceholder()
          ? _value.categoryId
          // ignore: cast_nullable_to_non_nullable
          : categoryId as String?,
      categoryName: categoryName == const $CopyWithPlaceholder()
          ? _value.categoryName
          // ignore: cast_nullable_to_non_nullable
          : categoryName as String,
      productTypes: productTypes == const $CopyWithPlaceholder()
          ? _value.productTypes
          // ignore: cast_nullable_to_non_nullable
          : productTypes as List<String>,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      photoCount: photoCount == const $CopyWithPlaceholder()
          ? _value.photoCount
          // ignore: cast_nullable_to_non_nullable
          : photoCount as int,
      photos: photos == const $CopyWithPlaceholder()
          ? _value.photos
          // ignore: cast_nullable_to_non_nullable
          : photos as List<MediaAsset>?,
    );
  }
}

extension $WorkCardCopyWith on WorkCard {
  /// Returns a callable class that can be used as follows: `instanceOfWorkCard.copyWith(...)` or like so:`instanceOfWorkCard.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkCardCWProxy get copyWith => _$WorkCardCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkCard _$WorkCardFromJson(Map<String, dynamic> json) => $checkedCreate(
  'WorkCard',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'status',
        'work_name',
        'category_name',
        'product_types',
        'photo_count',
      ],
    );
    final val = WorkCard(
      id: $checkedConvert('id', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$WorkCardStatusEnumMap, v),
      ),
      workName: $checkedConvert('work_name', (v) => v as String),
      customWorkName: $checkedConvert('custom_work_name', (v) => v as String?),
      categoryId: $checkedConvert('category_id', (v) => v as String?),
      categoryName: $checkedConvert('category_name', (v) => v as String),
      productTypes: $checkedConvert(
        'product_types',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      description: $checkedConvert('description', (v) => v as String?),
      photoCount: $checkedConvert('photo_count', (v) => (v as num).toInt()),
      photos: $checkedConvert(
        'photos',
        (v) => (v as List<dynamic>?)
            ?.map((e) => MediaAsset.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'workName': 'work_name',
    'customWorkName': 'custom_work_name',
    'categoryId': 'category_id',
    'categoryName': 'category_name',
    'productTypes': 'product_types',
    'photoCount': 'photo_count',
  },
);

Map<String, dynamic> _$WorkCardToJson(WorkCard instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$WorkCardStatusEnumMap[instance.status]!,
  'work_name': instance.workName,
  'custom_work_name': ?instance.customWorkName,
  'category_id': ?instance.categoryId,
  'category_name': instance.categoryName,
  'product_types': instance.productTypes,
  'description': ?instance.description,
  'photo_count': instance.photoCount,
  'photos': ?instance.photos?.map((e) => e.toJson()).toList(),
};

const _$WorkCardStatusEnumMap = {
  WorkCardStatus.draft: 'draft',
  WorkCardStatus.published: 'published',
  WorkCardStatus.hiddenByUser: 'hidden_by_user',
  WorkCardStatus.removedByAdmin: 'removed_by_admin',
  WorkCardStatus.deleted: 'deleted',
};
