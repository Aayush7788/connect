//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/device_info.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'otp_verify_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OtpVerifyRequest {
  /// Returns a new [OtpVerifyRequest] instance.
  OtpVerifyRequest({

    required  this.mobile,

    required  this.otp,

    required  this.otpRequestId,

     this.device,
  });

  @JsonKey(
    
    name: r'mobile',
    required: true,
    includeIfNull: false,
  )


  final String mobile;



  @JsonKey(
    
    name: r'otp',
    required: true,
    includeIfNull: false,
  )


  final String otp;



  @JsonKey(
    
    name: r'otp_request_id',
    required: true,
    includeIfNull: false,
  )


  final String otpRequestId;



  @JsonKey(
    
    name: r'device',
    required: false,
    includeIfNull: false,
  )


  final DeviceInfo? device;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OtpVerifyRequest &&
      other.mobile == mobile &&
      other.otp == otp &&
      other.otpRequestId == otpRequestId &&
      other.device == device;

    @override
    int get hashCode =>
        mobile.hashCode +
        otp.hashCode +
        otpRequestId.hashCode +
        device.hashCode;

  factory OtpVerifyRequest.fromJson(Map<String, dynamic> json) => _$OtpVerifyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerifyRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

