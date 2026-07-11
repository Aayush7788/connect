// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_items_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SavedItemsResponseCWProxy {
  SavedItemsResponse items(List<SavedItem> items);

  SavedItemsResponse nextCursor(String? nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SavedItemsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SavedItemsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SavedItemsResponse call({List<SavedItem> items, String? nextCursor});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSavedItemsResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSavedItemsResponse.copyWith.fieldName(...)`
class _$SavedItemsResponseCWProxyImpl implements _$SavedItemsResponseCWProxy {
  const _$SavedItemsResponseCWProxyImpl(this._value);

  final SavedItemsResponse _value;

  @override
  SavedItemsResponse items(List<SavedItem> items) => this(items: items);

  @override
  SavedItemsResponse nextCursor(String? nextCursor) =>
      this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SavedItemsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SavedItemsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SavedItemsResponse call({
    Object? items = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return SavedItemsResponse(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<SavedItem>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
    );
  }
}

extension $SavedItemsResponseCopyWith on SavedItemsResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSavedItemsResponse.copyWith(...)` or like so:`instanceOfSavedItemsResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SavedItemsResponseCWProxy get copyWith =>
      _$SavedItemsResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedItemsResponse _$SavedItemsResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SavedItemsResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items']);
      final val = SavedItemsResponse(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => SavedItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        nextCursor: $checkedConvert('next_cursor', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'nextCursor': 'next_cursor'});

Map<String, dynamic> _$SavedItemsResponseToJson(SavedItemsResponse instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'next_cursor': ?instance.nextCursor,
    };
