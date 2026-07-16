// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_option_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LocationOptionListCWProxy {
  LocationOptionList items(List<LocationOption> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LocationOptionList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LocationOptionList(...).copyWith(id: 12, name: "My name")
  /// ````
  LocationOptionList call({List<LocationOption> items});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLocationOptionList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLocationOptionList.copyWith.fieldName(...)`
class _$LocationOptionListCWProxyImpl implements _$LocationOptionListCWProxy {
  const _$LocationOptionListCWProxyImpl(this._value);

  final LocationOptionList _value;

  @override
  LocationOptionList items(List<LocationOption> items) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LocationOptionList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LocationOptionList(...).copyWith(id: 12, name: "My name")
  /// ````
  LocationOptionList call({Object? items = const $CopyWithPlaceholder()}) {
    return LocationOptionList(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<LocationOption>,
    );
  }
}

extension $LocationOptionListCopyWith on LocationOptionList {
  /// Returns a callable class that can be used as follows: `instanceOfLocationOptionList.copyWith(...)` or like so:`instanceOfLocationOptionList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LocationOptionListCWProxy get copyWith =>
      _$LocationOptionListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationOptionList _$LocationOptionListFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LocationOptionList', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items']);
      final val = LocationOptionList(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => LocationOption.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LocationOptionListToJson(LocationOptionList instance) =>
    <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
