//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_address.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicAddress {
  /// Returns a new [PublicAddress] instance.
  PublicAddress({

     this.locality,

     this.city,

     this.state,

     this.pincode,

     this.fullAddress,
  });

  @JsonKey(
    
    name: r'locality',
    required: false,
    includeIfNull: false,
  )


  final String? locality;



  @JsonKey(
    
    name: r'city',
    required: false,
    includeIfNull: false,
  )


  final String? city;



  @JsonKey(
    
    name: r'state',
    required: false,
    includeIfNull: false,
  )


  final String? state;



  @JsonKey(
    
    name: r'pincode',
    required: false,
    includeIfNull: false,
  )


  final String? pincode;



  @JsonKey(
    
    name: r'full_address',
    required: false,
    includeIfNull: false,
  )


  final String? fullAddress;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicAddress &&
      other.locality == locality &&
      other.city == city &&
      other.state == state &&
      other.pincode == pincode &&
      other.fullAddress == fullAddress;

    @override
    int get hashCode =>
        locality.hashCode +
        city.hashCode +
        state.hashCode +
        pincode.hashCode +
        fullAddress.hashCode;

  factory PublicAddress.fromJson(Map<String, dynamic> json) => _$PublicAddressFromJson(json);

  Map<String, dynamic> toJson() => _$PublicAddressToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

