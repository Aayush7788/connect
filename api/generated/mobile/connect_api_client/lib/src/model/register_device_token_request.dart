//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_device_token_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterDeviceTokenRequest {
  /// Returns a new [RegisterDeviceTokenRequest] instance.
  RegisterDeviceTokenRequest({

    required  this.fcmToken,

    required  this.platform,

     this.deviceId,

     this.appVersion,
  });

  @JsonKey(
    
    name: r'fcm_token',
    required: true,
    includeIfNull: false,
  )


  final String fcmToken;



  @JsonKey(
    
    name: r'platform',
    required: true,
    includeIfNull: false,
  )


  final RegisterDeviceTokenRequestPlatformEnum platform;



  @JsonKey(
    
    name: r'device_id',
    required: false,
    includeIfNull: false,
  )


  final String? deviceId;



  @JsonKey(
    
    name: r'app_version',
    required: false,
    includeIfNull: false,
  )


  final String? appVersion;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RegisterDeviceTokenRequest &&
      other.fcmToken == fcmToken &&
      other.platform == platform &&
      other.deviceId == deviceId &&
      other.appVersion == appVersion;

    @override
    int get hashCode =>
        fcmToken.hashCode +
        platform.hashCode +
        deviceId.hashCode +
        appVersion.hashCode;

  factory RegisterDeviceTokenRequest.fromJson(Map<String, dynamic> json) => _$RegisterDeviceTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDeviceTokenRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum RegisterDeviceTokenRequestPlatformEnum {
@JsonValue(r'android')
android(r'android');

const RegisterDeviceTokenRequestPlatformEnum(this.value);

final String value;

@override
String toString() => value;
}


