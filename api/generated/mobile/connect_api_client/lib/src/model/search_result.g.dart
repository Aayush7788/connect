// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SearchResultCWProxy {
  SearchResult resultType(SearchResultResultTypeEnum resultType);

  SearchResult id(String id);

  SearchResult profileId(String? profileId);

  SearchResult title(String title);

  SearchResult subtitle(String? subtitle);

  SearchResult category(String? category);

  SearchResult productTypes(List<String>? productTypes);

  SearchResult isVerified(bool? isVerified);

  SearchResult photos(List<MediaAsset>? photos);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchResult(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchResult call({
    SearchResultResultTypeEnum resultType,
    String id,
    String? profileId,
    String title,
    String? subtitle,
    String? category,
    List<String>? productTypes,
    bool? isVerified,
    List<MediaAsset>? photos,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSearchResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSearchResult.copyWith.fieldName(...)`
class _$SearchResultCWProxyImpl implements _$SearchResultCWProxy {
  const _$SearchResultCWProxyImpl(this._value);

  final SearchResult _value;

  @override
  SearchResult resultType(SearchResultResultTypeEnum resultType) =>
      this(resultType: resultType);

  @override
  SearchResult id(String id) => this(id: id);

  @override
  SearchResult profileId(String? profileId) => this(profileId: profileId);

  @override
  SearchResult title(String title) => this(title: title);

  @override
  SearchResult subtitle(String? subtitle) => this(subtitle: subtitle);

  @override
  SearchResult category(String? category) => this(category: category);

  @override
  SearchResult productTypes(List<String>? productTypes) =>
      this(productTypes: productTypes);

  @override
  SearchResult isVerified(bool? isVerified) => this(isVerified: isVerified);

  @override
  SearchResult photos(List<MediaAsset>? photos) => this(photos: photos);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchResult(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchResult call({
    Object? resultType = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? profileId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? subtitle = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? productTypes = const $CopyWithPlaceholder(),
    Object? isVerified = const $CopyWithPlaceholder(),
    Object? photos = const $CopyWithPlaceholder(),
  }) {
    return SearchResult(
      resultType: resultType == const $CopyWithPlaceholder()
          ? _value.resultType
          // ignore: cast_nullable_to_non_nullable
          : resultType as SearchResultResultTypeEnum,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      profileId: profileId == const $CopyWithPlaceholder()
          ? _value.profileId
          // ignore: cast_nullable_to_non_nullable
          : profileId as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      subtitle: subtitle == const $CopyWithPlaceholder()
          ? _value.subtitle
          // ignore: cast_nullable_to_non_nullable
          : subtitle as String?,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String?,
      productTypes: productTypes == const $CopyWithPlaceholder()
          ? _value.productTypes
          // ignore: cast_nullable_to_non_nullable
          : productTypes as List<String>?,
      isVerified: isVerified == const $CopyWithPlaceholder()
          ? _value.isVerified
          // ignore: cast_nullable_to_non_nullable
          : isVerified as bool?,
      photos: photos == const $CopyWithPlaceholder()
          ? _value.photos
          // ignore: cast_nullable_to_non_nullable
          : photos as List<MediaAsset>?,
    );
  }
}

extension $SearchResultCopyWith on SearchResult {
  /// Returns a callable class that can be used as follows: `instanceOfSearchResult.copyWith(...)` or like so:`instanceOfSearchResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SearchResultCWProxy get copyWith => _$SearchResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SearchResult',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['result_type', 'id', 'title']);
        final val = SearchResult(
          resultType: $checkedConvert(
            'result_type',
            (v) => $enumDecode(_$SearchResultResultTypeEnumEnumMap, v),
          ),
          id: $checkedConvert('id', (v) => v as String),
          profileId: $checkedConvert('profile_id', (v) => v as String?),
          title: $checkedConvert('title', (v) => v as String),
          subtitle: $checkedConvert('subtitle', (v) => v as String?),
          category: $checkedConvert('category', (v) => v as String?),
          productTypes: $checkedConvert(
            'product_types',
            (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
          ),
          isVerified: $checkedConvert('is_verified', (v) => v as bool?),
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
        'resultType': 'result_type',
        'profileId': 'profile_id',
        'productTypes': 'product_types',
        'isVerified': 'is_verified',
      },
    );

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'result_type': _$SearchResultResultTypeEnumEnumMap[instance.resultType]!,
      'id': instance.id,
      'profile_id': ?instance.profileId,
      'title': instance.title,
      'subtitle': ?instance.subtitle,
      'category': ?instance.category,
      'product_types': ?instance.productTypes,
      'is_verified': ?instance.isVerified,
      'photos': ?instance.photos?.map((e) => e.toJson()).toList(),
    };

const _$SearchResultResultTypeEnumEnumMap = {
  SearchResultResultTypeEnum.profile: 'profile',
  SearchResultResultTypeEnum.workCard: 'work_card',
  SearchResultResultTypeEnum.workNeededPost: 'work_needed_post',
};
