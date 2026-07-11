// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_my_work_cards200_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ListMyWorkCards200ResponseCWProxy {
  ListMyWorkCards200Response items(List<WorkCard> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ListMyWorkCards200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ListMyWorkCards200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  ListMyWorkCards200Response call({List<WorkCard> items});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfListMyWorkCards200Response.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfListMyWorkCards200Response.copyWith.fieldName(...)`
class _$ListMyWorkCards200ResponseCWProxyImpl
    implements _$ListMyWorkCards200ResponseCWProxy {
  const _$ListMyWorkCards200ResponseCWProxyImpl(this._value);

  final ListMyWorkCards200Response _value;

  @override
  ListMyWorkCards200Response items(List<WorkCard> items) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ListMyWorkCards200Response(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ListMyWorkCards200Response(...).copyWith(id: 12, name: "My name")
  /// ````
  ListMyWorkCards200Response call({
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return ListMyWorkCards200Response(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<WorkCard>,
    );
  }
}

extension $ListMyWorkCards200ResponseCopyWith on ListMyWorkCards200Response {
  /// Returns a callable class that can be used as follows: `instanceOfListMyWorkCards200Response.copyWith(...)` or like so:`instanceOfListMyWorkCards200Response.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ListMyWorkCards200ResponseCWProxy get copyWith =>
      _$ListMyWorkCards200ResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListMyWorkCards200Response _$ListMyWorkCards200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ListMyWorkCards200Response', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['items']);
  final val = ListMyWorkCards200Response(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => WorkCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ListMyWorkCards200ResponseToJson(
  ListMyWorkCards200Response instance,
) => <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
