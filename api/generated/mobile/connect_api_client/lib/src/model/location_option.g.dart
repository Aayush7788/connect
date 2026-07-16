// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_option.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LocationOptionCWProxy {
  LocationOption id(int id);

  LocationOption name(String name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LocationOption(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LocationOption(...).copyWith(id: 12, name: "My name")
  /// ````
  LocationOption call({int id, String name});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLocationOption.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLocationOption.copyWith.fieldName(...)`
class _$LocationOptionCWProxyImpl implements _$LocationOptionCWProxy {
  const _$LocationOptionCWProxyImpl(this._value);

  final LocationOption _value;

  @override
  LocationOption id(int id) => this(id: id);

  @override
  LocationOption name(String name) => this(name: name);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LocationOption(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LocationOption(...).copyWith(id: 12, name: "My name")
  /// ````
  LocationOption call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return LocationOption(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $LocationOptionCopyWith on LocationOption {
  /// Returns a callable class that can be used as follows: `instanceOfLocationOption.copyWith(...)` or like so:`instanceOfLocationOption.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LocationOptionCWProxy get copyWith => _$LocationOptionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationOption _$LocationOptionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LocationOption', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name']);
      final val = LocationOption(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LocationOptionToJson(LocationOption instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
