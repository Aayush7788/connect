// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_validation_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AddressValidationResponseCWProxy {
  AddressValidationResponse status(AddressValidationResponseStatusEnum status);

  AddressValidationResponse pincode(String pincode);

  AddressValidationResponse stateMatches(bool stateMatches);

  AddressValidationResponse districtMatches(bool districtMatches);

  AddressValidationResponse areaMatches(bool? areaMatches);

  AddressValidationResponse canonicalState(LocationOption? canonicalState);

  AddressValidationResponse canonicalDistrict(
    LocationOption? canonicalDistrict,
  );

  AddressValidationResponse suggestedAreas(List<String>? suggestedAreas);

  AddressValidationResponse message(String message);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AddressValidationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AddressValidationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AddressValidationResponse call({
    AddressValidationResponseStatusEnum status,
    String pincode,
    bool stateMatches,
    bool districtMatches,
    bool? areaMatches,
    LocationOption? canonicalState,
    LocationOption? canonicalDistrict,
    List<String>? suggestedAreas,
    String message,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAddressValidationResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAddressValidationResponse.copyWith.fieldName(...)`
class _$AddressValidationResponseCWProxyImpl
    implements _$AddressValidationResponseCWProxy {
  const _$AddressValidationResponseCWProxyImpl(this._value);

  final AddressValidationResponse _value;

  @override
  AddressValidationResponse status(
    AddressValidationResponseStatusEnum status,
  ) => this(status: status);

  @override
  AddressValidationResponse pincode(String pincode) => this(pincode: pincode);

  @override
  AddressValidationResponse stateMatches(bool stateMatches) =>
      this(stateMatches: stateMatches);

  @override
  AddressValidationResponse districtMatches(bool districtMatches) =>
      this(districtMatches: districtMatches);

  @override
  AddressValidationResponse areaMatches(bool? areaMatches) =>
      this(areaMatches: areaMatches);

  @override
  AddressValidationResponse canonicalState(LocationOption? canonicalState) =>
      this(canonicalState: canonicalState);

  @override
  AddressValidationResponse canonicalDistrict(
    LocationOption? canonicalDistrict,
  ) => this(canonicalDistrict: canonicalDistrict);

  @override
  AddressValidationResponse suggestedAreas(List<String>? suggestedAreas) =>
      this(suggestedAreas: suggestedAreas);

  @override
  AddressValidationResponse message(String message) => this(message: message);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AddressValidationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AddressValidationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AddressValidationResponse call({
    Object? status = const $CopyWithPlaceholder(),
    Object? pincode = const $CopyWithPlaceholder(),
    Object? stateMatches = const $CopyWithPlaceholder(),
    Object? districtMatches = const $CopyWithPlaceholder(),
    Object? areaMatches = const $CopyWithPlaceholder(),
    Object? canonicalState = const $CopyWithPlaceholder(),
    Object? canonicalDistrict = const $CopyWithPlaceholder(),
    Object? suggestedAreas = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
  }) {
    return AddressValidationResponse(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AddressValidationResponseStatusEnum,
      pincode: pincode == const $CopyWithPlaceholder()
          ? _value.pincode
          // ignore: cast_nullable_to_non_nullable
          : pincode as String,
      stateMatches: stateMatches == const $CopyWithPlaceholder()
          ? _value.stateMatches
          // ignore: cast_nullable_to_non_nullable
          : stateMatches as bool,
      districtMatches: districtMatches == const $CopyWithPlaceholder()
          ? _value.districtMatches
          // ignore: cast_nullable_to_non_nullable
          : districtMatches as bool,
      areaMatches: areaMatches == const $CopyWithPlaceholder()
          ? _value.areaMatches
          // ignore: cast_nullable_to_non_nullable
          : areaMatches as bool?,
      canonicalState: canonicalState == const $CopyWithPlaceholder()
          ? _value.canonicalState
          // ignore: cast_nullable_to_non_nullable
          : canonicalState as LocationOption?,
      canonicalDistrict: canonicalDistrict == const $CopyWithPlaceholder()
          ? _value.canonicalDistrict
          // ignore: cast_nullable_to_non_nullable
          : canonicalDistrict as LocationOption?,
      suggestedAreas: suggestedAreas == const $CopyWithPlaceholder()
          ? _value.suggestedAreas
          // ignore: cast_nullable_to_non_nullable
          : suggestedAreas as List<String>?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
    );
  }
}

extension $AddressValidationResponseCopyWith on AddressValidationResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAddressValidationResponse.copyWith(...)` or like so:`instanceOfAddressValidationResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AddressValidationResponseCWProxy get copyWith =>
      _$AddressValidationResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressValidationResponse _$AddressValidationResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AddressValidationResponse',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'status',
        'pincode',
        'state_matches',
        'district_matches',
        'message',
      ],
    );
    final val = AddressValidationResponse(
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$AddressValidationResponseStatusEnumEnumMap, v),
      ),
      pincode: $checkedConvert('pincode', (v) => v as String),
      stateMatches: $checkedConvert('state_matches', (v) => v as bool),
      districtMatches: $checkedConvert('district_matches', (v) => v as bool),
      areaMatches: $checkedConvert('area_matches', (v) => v as bool?),
      canonicalState: $checkedConvert(
        'canonical_state',
        (v) => v == null
            ? null
            : LocationOption.fromJson(v as Map<String, dynamic>),
      ),
      canonicalDistrict: $checkedConvert(
        'canonical_district',
        (v) => v == null
            ? null
            : LocationOption.fromJson(v as Map<String, dynamic>),
      ),
      suggestedAreas: $checkedConvert(
        'suggested_areas',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      message: $checkedConvert('message', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'stateMatches': 'state_matches',
    'districtMatches': 'district_matches',
    'areaMatches': 'area_matches',
    'canonicalState': 'canonical_state',
    'canonicalDistrict': 'canonical_district',
    'suggestedAreas': 'suggested_areas',
  },
);

Map<String, dynamic> _$AddressValidationResponseToJson(
  AddressValidationResponse instance,
) => <String, dynamic>{
  'status': _$AddressValidationResponseStatusEnumEnumMap[instance.status]!,
  'pincode': instance.pincode,
  'state_matches': instance.stateMatches,
  'district_matches': instance.districtMatches,
  'area_matches': ?instance.areaMatches,
  'canonical_state': ?instance.canonicalState?.toJson(),
  'canonical_district': ?instance.canonicalDistrict?.toJson(),
  'suggested_areas': ?instance.suggestedAreas,
  'message': instance.message,
};

const _$AddressValidationResponseStatusEnumEnumMap = {
  AddressValidationResponseStatusEnum.valid: 'valid',
  AddressValidationResponseStatusEnum.warning: 'warning',
  AddressValidationResponseStatusEnum.invalid: 'invalid',
};
