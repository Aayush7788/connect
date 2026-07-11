// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SearchResponseCWProxy {
  SearchResponse items(List<SearchResult> items);

  SearchResponse resultCount(int resultCount);

  SearchResponse nextCursor(String? nextCursor);

  SearchResponse searchLogId(String? searchLogId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchResponse call({
    List<SearchResult> items,
    int resultCount,
    String? nextCursor,
    String? searchLogId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSearchResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSearchResponse.copyWith.fieldName(...)`
class _$SearchResponseCWProxyImpl implements _$SearchResponseCWProxy {
  const _$SearchResponseCWProxyImpl(this._value);

  final SearchResponse _value;

  @override
  SearchResponse items(List<SearchResult> items) => this(items: items);

  @override
  SearchResponse resultCount(int resultCount) => this(resultCount: resultCount);

  @override
  SearchResponse nextCursor(String? nextCursor) => this(nextCursor: nextCursor);

  @override
  SearchResponse searchLogId(String? searchLogId) =>
      this(searchLogId: searchLogId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchResponse call({
    Object? items = const $CopyWithPlaceholder(),
    Object? resultCount = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
    Object? searchLogId = const $CopyWithPlaceholder(),
  }) {
    return SearchResponse(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<SearchResult>,
      resultCount: resultCount == const $CopyWithPlaceholder()
          ? _value.resultCount
          // ignore: cast_nullable_to_non_nullable
          : resultCount as int,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
      searchLogId: searchLogId == const $CopyWithPlaceholder()
          ? _value.searchLogId
          // ignore: cast_nullable_to_non_nullable
          : searchLogId as String?,
    );
  }
}

extension $SearchResponseCopyWith on SearchResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSearchResponse.copyWith(...)` or like so:`instanceOfSearchResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SearchResponseCWProxy get copyWith => _$SearchResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SearchResponse',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['items', 'result_count']);
        final val = SearchResponse(
          items: $checkedConvert(
            'items',
            (v) => (v as List<dynamic>)
                .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          resultCount: $checkedConvert(
            'result_count',
            (v) => (v as num).toInt(),
          ),
          nextCursor: $checkedConvert('next_cursor', (v) => v as String?),
          searchLogId: $checkedConvert('search_log_id', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'resultCount': 'result_count',
        'nextCursor': 'next_cursor',
        'searchLogId': 'search_log_id',
      },
    );

Map<String, dynamic> _$SearchResponseToJson(SearchResponse instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'result_count': instance.resultCount,
      'next_cursor': ?instance.nextCursor,
      'search_log_id': ?instance.searchLogId,
    };
