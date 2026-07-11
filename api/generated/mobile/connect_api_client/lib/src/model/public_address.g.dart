// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_address.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicAddressCWProxy {
  PublicAddress locality(String? locality);

  PublicAddress city(String? city);

  PublicAddress state(String? state);

  PublicAddress pincode(String? pincode);

  PublicAddress fullAddress(String? fullAddress);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicAddress(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicAddress(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicAddress call({
    String? locality,
    String? city,
    String? state,
    String? pincode,
    String? fullAddress,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicAddress.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicAddress.copyWith.fieldName(...)`
class _$PublicAddressCWProxyImpl implements _$PublicAddressCWProxy {
  const _$PublicAddressCWProxyImpl(this._value);

  final PublicAddress _value;

  @override
  PublicAddress locality(String? locality) => this(locality: locality);

  @override
  PublicAddress city(String? city) => this(city: city);

  @override
  PublicAddress state(String? state) => this(state: state);

  @override
  PublicAddress pincode(String? pincode) => this(pincode: pincode);

  @override
  PublicAddress fullAddress(String? fullAddress) =>
      this(fullAddress: fullAddress);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicAddress(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicAddress(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicAddress call({
    Object? locality = const $CopyWithPlaceholder(),
    Object? city = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? pincode = const $CopyWithPlaceholder(),
    Object? fullAddress = const $CopyWithPlaceholder(),
  }) {
    return PublicAddress(
      locality: locality == const $CopyWithPlaceholder()
          ? _value.locality
          // ignore: cast_nullable_to_non_nullable
          : locality as String?,
      city: city == const $CopyWithPlaceholder()
          ? _value.city
          // ignore: cast_nullable_to_non_nullable
          : city as String?,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as String?,
      pincode: pincode == const $CopyWithPlaceholder()
          ? _value.pincode
          // ignore: cast_nullable_to_non_nullable
          : pincode as String?,
      fullAddress: fullAddress == const $CopyWithPlaceholder()
          ? _value.fullAddress
          // ignore: cast_nullable_to_non_nullable
          : fullAddress as String?,
    );
  }
}

extension $PublicAddressCopyWith on PublicAddress {
  /// Returns a callable class that can be used as follows: `instanceOfPublicAddress.copyWith(...)` or like so:`instanceOfPublicAddress.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicAddressCWProxy get copyWith => _$PublicAddressCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicAddress _$PublicAddressFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PublicAddress', json, ($checkedConvert) {
      final val = PublicAddress(
        locality: $checkedConvert('locality', (v) => v as String?),
        city: $checkedConvert('city', (v) => v as String?),
        state: $checkedConvert('state', (v) => v as String?),
        pincode: $checkedConvert('pincode', (v) => v as String?),
        fullAddress: $checkedConvert('full_address', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'fullAddress': 'full_address'});

Map<String, dynamic> _$PublicAddressToJson(PublicAddress instance) =>
    <String, dynamic>{
      'locality': ?instance.locality,
      'city': ?instance.city,
      'state': ?instance.state,
      'pincode': ?instance.pincode,
      'full_address': ?instance.fullAddress,
    };
