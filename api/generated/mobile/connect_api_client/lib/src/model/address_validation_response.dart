//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/location_option.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address_validation_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AddressValidationResponse {
  /// Returns a new [AddressValidationResponse] instance.
  AddressValidationResponse({

    required  this.status,

    required  this.pincode,

    required  this.stateMatches,

    required  this.districtMatches,

     this.areaMatches,

     this.canonicalState,

     this.canonicalDistrict,

     this.suggestedAreas,

    required  this.message,
  });

  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final AddressValidationResponseStatusEnum status;



  @JsonKey(
    
    name: r'pincode',
    required: true,
    includeIfNull: false,
  )


  final String pincode;



  @JsonKey(
    
    name: r'state_matches',
    required: true,
    includeIfNull: false,
  )


  final bool stateMatches;



  @JsonKey(
    
    name: r'district_matches',
    required: true,
    includeIfNull: false,
  )


  final bool districtMatches;



  @JsonKey(
    
    name: r'area_matches',
    required: false,
    includeIfNull: false,
  )


  final bool? areaMatches;



  @JsonKey(
    
    name: r'canonical_state',
    required: false,
    includeIfNull: false,
  )


  final LocationOption? canonicalState;



  @JsonKey(
    
    name: r'canonical_district',
    required: false,
    includeIfNull: false,
  )


  final LocationOption? canonicalDistrict;



  @JsonKey(
    
    name: r'suggested_areas',
    required: false,
    includeIfNull: false,
  )


  final List<String>? suggestedAreas;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AddressValidationResponse &&
      other.status == status &&
      other.pincode == pincode &&
      other.stateMatches == stateMatches &&
      other.districtMatches == districtMatches &&
      other.areaMatches == areaMatches &&
      other.canonicalState == canonicalState &&
      other.canonicalDistrict == canonicalDistrict &&
      other.suggestedAreas == suggestedAreas &&
      other.message == message;

    @override
    int get hashCode =>
        status.hashCode +
        pincode.hashCode +
        stateMatches.hashCode +
        districtMatches.hashCode +
        areaMatches.hashCode +
        canonicalState.hashCode +
        canonicalDistrict.hashCode +
        suggestedAreas.hashCode +
        message.hashCode;

  factory AddressValidationResponse.fromJson(Map<String, dynamic> json) => _$AddressValidationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddressValidationResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AddressValidationResponseStatusEnum {
@JsonValue(r'valid')
valid(r'valid'),
@JsonValue(r'warning')
warning(r'warning'),
@JsonValue(r'invalid')
invalid(r'invalid');

const AddressValidationResponseStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


