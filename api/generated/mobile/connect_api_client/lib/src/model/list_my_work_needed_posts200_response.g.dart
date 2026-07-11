// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_my_work_needed_posts200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ListMyWorkNeededPosts200ResponseCWProxy {
  ListMyWorkNeededPosts200Response items(List<WorkNeededPost> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ListMyWorkNeededPosts200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ListMyWorkNeededPosts200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  ListMyWorkNeededPosts200Response call({List<WorkNeededPost> items});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfListMyWorkNeededPosts200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfListMyWorkNeededPosts200Response.copyWith.fieldName(...)`
class _$ListMyWorkNeededPosts200ResponseCWProxyImpl
    implements _$ListMyWorkNeededPosts200ResponseCWProxy {
  const _$ListMyWorkNeededPosts200ResponseCWProxyImpl(this._value);

  final ListMyWorkNeededPosts200Response _value;

  @override
  ListMyWorkNeededPosts200Response items(List<WorkNeededPost> items) =>
      this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ListMyWorkNeededPosts200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ListMyWorkNeededPosts200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  ListMyWorkNeededPosts200Response call({
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return ListMyWorkNeededPosts200Response(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<WorkNeededPost>,
    );
  }
}

extension $ListMyWorkNeededPosts200ResponseCopyWith
    on ListMyWorkNeededPosts200Response {
  /// Returns a callable class that can be used as follows: `instanceOfListMyWorkNeededPosts200Response.copyWith(...)` or like so:`instanceOfListMyWorkNeededPosts200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ListMyWorkNeededPosts200ResponseCWProxy get copyWith =>
      _$ListMyWorkNeededPosts200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListMyWorkNeededPosts200Response _$ListMyWorkNeededPosts200ResponseFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('ListMyWorkNeededPosts200Response', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items']);
      final val = ListMyWorkNeededPosts200Response(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => WorkNeededPost.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ListMyWorkNeededPosts200ResponseToJson(
  ListMyWorkNeededPosts200Response instance,
) => <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
