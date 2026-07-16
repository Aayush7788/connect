//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address_validation_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AddressValidationRequest {
  /// Returns a new [AddressValidationRequest] instance.
  AddressValidationRequest({

    required  this.stateId,

    required  this.districtId,

    required  this.pincode,

     this.area,
  });

          // minimum: 1
  @JsonKey(
    
    name: r'state_id',
    required: true,
    includeIfNull: false,
  )


  final int stateId;



          // minimum: 1
  @JsonKey(
    
    name: r'district_id',
    required: true,
    includeIfNull: false,
  )


  final int districtId;



  @JsonKey(
    
    name: r'pincode',
    required: true,
    includeIfNull: false,
  )


  final String pincode;



  @JsonKey(
    
    name: r'area',
    required: false,
    includeIfNull: false,
  )


  final String? area;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AddressValidationRequest &&
      other.stateId == stateId &&
      other.districtId == districtId &&
      other.pincode == pincode &&
      other.area == area;

    @override
    int get hashCode =>
        stateId.hashCode +
        districtId.hashCode +
        pincode.hashCode +
        area.hashCode;

  factory AddressValidationRequest.fromJson(Map<String, dynamic> json) => _$AddressValidationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddressValidationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

