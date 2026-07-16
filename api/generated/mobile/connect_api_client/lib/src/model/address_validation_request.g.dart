// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_validation_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AddressValidationRequestCWProxy {
  AddressValidationRequest stateId(int stateId);

  AddressValidationRequest districtId(int districtId);

  AddressValidationRequest pincode(String pincode);

  AddressValidationRequest area(String? area);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AddressValidationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AddressValidationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AddressValidationRequest call({
    int stateId,
    int districtId,
    String pincode,
    String? area,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAddressValidationRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAddressValidationRequest.copyWith.fieldName(...)`
class _$AddressValidationRequestCWProxyImpl
    implements _$AddressValidationRequestCWProxy {
  const _$AddressValidationRequestCWProxyImpl(this._value);

  final AddressValidationRequest _value;

  @override
  AddressValidationRequest stateId(int stateId) => this(stateId: stateId);

  @override
  AddressValidationRequest districtId(int districtId) =>
      this(districtId: districtId);

  @override
  AddressValidationRequest pincode(String pincode) => this(pincode: pincode);

  @override
  AddressValidationRequest area(String? area) => this(area: area);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AddressValidationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AddressValidationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AddressValidationRequest call({
    Object? stateId = const $CopyWithPlaceholder(),
    Object? districtId = const $CopyWithPlaceholder(),
    Object? pincode = const $CopyWithPlaceholder(),
    Object? area = const $CopyWithPlaceholder(),
  }) {
    return AddressValidationRequest(
      stateId: stateId == const $CopyWithPlaceholder()
          ? _value.stateId
          // ignore: cast_nullable_to_non_nullable
          : stateId as int,
      districtId: districtId == const $CopyWithPlaceholder()
          ? _value.districtId
          // ignore: cast_nullable_to_non_nullable
          : districtId as int,
      pincode: pincode == const $CopyWithPlaceholder()
          ? _value.pincode
          // ignore: cast_nullable_to_non_nullable
          : pincode as String,
      area: area == const $CopyWithPlaceholder()
          ? _value.area
          // ignore: cast_nullable_to_non_nullable
          : area as String?,
    );
  }
}

extension $AddressValidationRequestCopyWith on AddressValidationRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAddressValidationRequest.copyWith(...)` or like so:`instanceOfAddressValidationRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AddressValidationRequestCWProxy get copyWith =>
      _$AddressValidationRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressValidationRequest _$AddressValidationRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AddressValidationRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['state_id', 'district_id', 'pincode'],
    );
    final val = AddressValidationRequest(
      stateId: $checkedConvert('state_id', (v) => (v as num).toInt()),
      districtId: $checkedConvert('district_id', (v) => (v as num).toInt()),
      pincode: $checkedConvert('pincode', (v) => v as String),
      area: $checkedConvert('area', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'stateId': 'state_id', 'districtId': 'district_id'},
);

Map<String, dynamic> _$AddressValidationRequestToJson(
  AddressValidationRequest instance,
) => <String, dynamic>{
  'state_id': instance.stateId,
  'district_id': instance.districtId,
  'pincode': instance.pincode,
  'area': ?instance.area,
};
