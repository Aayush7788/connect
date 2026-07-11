// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_needed_post.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkNeededPostCWProxy {
  WorkNeededPost id(String id);

  WorkNeededPost status(WorkNeededPostStatus status);

  WorkNeededPost workName(String workName);

  WorkNeededPost categoryName(String categoryName);

  WorkNeededPost productTypes(List<String> productTypes);

  WorkNeededPost description(String? description);

  WorkNeededPost photoCount(int photoCount);

  WorkNeededPost photos(List<MediaAsset>? photos);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkNeededPost(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkNeededPost(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkNeededPost call({
    String id,
    WorkNeededPostStatus status,
    String workName,
    String categoryName,
    List<String> productTypes,
    String? description,
    int photoCount,
    List<MediaAsset>? photos,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkNeededPost.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkNeededPost.copyWith.fieldName(...)`
class _$WorkNeededPostCWProxyImpl implements _$WorkNeededPostCWProxy {
  const _$WorkNeededPostCWProxyImpl(this._value);

  final WorkNeededPost _value;

  @override
  WorkNeededPost id(String id) => this(id: id);

  @override
  WorkNeededPost status(WorkNeededPostStatus status) => this(status: status);

  @override
  WorkNeededPost workName(String workName) => this(workName: workName);

  @override
  WorkNeededPost categoryName(String categoryName) =>
      this(categoryName: categoryName);

  @override
  WorkNeededPost productTypes(List<String> productTypes) =>
      this(productTypes: productTypes);

  @override
  WorkNeededPost description(String? description) =>
      this(description: description);

  @override
  WorkNeededPost photoCount(int photoCount) => this(photoCount: photoCount);

  @override
  WorkNeededPost photos(List<MediaAsset>? photos) => this(photos: photos);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkNeededPost(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkNeededPost(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkNeededPost call({
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? workName = const $CopyWithPlaceholder(),
    Object? categoryName = const $CopyWithPlaceholder(),
    Object? productTypes = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? photoCount = const $CopyWithPlaceholder(),
    Object? photos = const $CopyWithPlaceholder(),
  }) {
    return WorkNeededPost(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as WorkNeededPostStatus,
      workName: workName == const $CopyWithPlaceholder()
          ? _value.workName
          // ignore: cast_nullable_to_non_nullable
          : workName as String,
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

extension $WorkNeededPostCopyWith on WorkNeededPost {
  /// Returns a callable class that can be used as follows: `instanceOfWorkNeededPost.copyWith(...)` or like so:`instanceOfWorkNeededPost.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkNeededPostCWProxy get copyWith => _$WorkNeededPostCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkNeededPost _$WorkNeededPostFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WorkNeededPost',
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
        final val = WorkNeededPost(
          id: $checkedConvert('id', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$WorkNeededPostStatusEnumMap, v),
          ),
          workName: $checkedConvert('work_name', (v) => v as String),
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
        'categoryName': 'category_name',
        'productTypes': 'product_types',
        'photoCount': 'photo_count',
      },
    );

Map<String, dynamic> _$WorkNeededPostToJson(WorkNeededPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$WorkNeededPostStatusEnumMap[instance.status]!,
      'work_name': instance.workName,
      'category_name': instance.categoryName,
      'product_types': instance.productTypes,
      'description': ?instance.description,
      'photo_count': instance.photoCount,
      'photos': ?instance.photos?.map((e) => e.toJson()).toList(),
    };

const _$WorkNeededPostStatusEnumMap = {
  WorkNeededPostStatus.draft: 'draft',
  WorkNeededPostStatus.active: 'active',
  WorkNeededPostStatus.paused: 'paused',
  WorkNeededPostStatus.closedByUser: 'closed_by_user',
  WorkNeededPostStatus.removedByAdmin: 'removed_by_admin',
  WorkNeededPostStatus.deleted: 'deleted',
};
