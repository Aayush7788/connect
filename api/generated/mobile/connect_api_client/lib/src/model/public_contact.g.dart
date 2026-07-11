// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_contact.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicContactCWProxy {
  PublicContact mobile(String? mobile);

  PublicContact whatsappNumber(String? whatsappNumber);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicContact(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicContact(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicContact call({String? mobile, String? whatsappNumber});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicContact.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicContact.copyWith.fieldName(...)`
class _$PublicContactCWProxyImpl implements _$PublicContactCWProxy {
  const _$PublicContactCWProxyImpl(this._value);

  final PublicContact _value;

  @override
  PublicContact mobile(String? mobile) => this(mobile: mobile);

  @override
  PublicContact whatsappNumber(String? whatsappNumber) =>
      this(whatsappNumber: whatsappNumber);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicContact(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicContact(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicContact call({
    Object? mobile = const $CopyWithPlaceholder(),
    Object? whatsappNumber = const $CopyWithPlaceholder(),
  }) {
    return PublicContact(
      mobile: mobile == const $CopyWithPlaceholder()
          ? _value.mobile
          // ignore: cast_nullable_to_non_nullable
          : mobile as String?,
      whatsappNumber: whatsappNumber == const $CopyWithPlaceholder()
          ? _value.whatsappNumber
          // ignore: cast_nullable_to_non_nullable
          : whatsappNumber as String?,
    );
  }
}

extension $PublicContactCopyWith on PublicContact {
  /// Returns a callable class that can be used as follows: `instanceOfPublicContact.copyWith(...)` or like so:`instanceOfPublicContact.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicContactCWProxy get copyWith => _$PublicContactCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicContact _$PublicContactFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PublicContact', json, ($checkedConvert) {
      final val = PublicContact(
        mobile: $checkedConvert('mobile', (v) => v as String?),
        whatsappNumber: $checkedConvert('whatsapp_number', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'whatsappNumber': 'whatsapp_number'});

Map<String, dynamic> _$PublicContactToJson(PublicContact instance) =>
    <String, dynamic>{
      'mobile': ?instance.mobile,
      'whatsapp_number': ?instance.whatsappNumber,
    };
