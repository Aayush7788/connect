//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_info.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceInfo {
  /// Returns a new [DeviceInfo] instance.
  DeviceInfo({

     this.deviceId,

     this.platform,

     this.appVersion,

     this.fcmToken,
  });

  @JsonKey(

    name: r'device_id',
    required: false,
    includeIfNull: false,
  )


  final String? deviceId;



  @JsonKey(

    name: r'platform',
    required: false,
    includeIfNull: false,
  )


  final DeviceInfoPlatformEnum? platform;



  @JsonKey(

    name: r'app_version',
    required: false,
    includeIfNull: false,
  )


  final String? appVersion;



  @JsonKey(

    name: r'fcm_token',
    required: false,
    includeIfNull: false,
  )


  final String? fcmToken;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeviceInfo &&
      other.deviceId == deviceId &&
      other.platform == platform &&
      other.appVersion == appVersion &&
      other.fcmToken == fcmToken;

    @override
    int get hashCode =>
        deviceId.hashCode +
        platform.hashCode +
        appVersion.hashCode +
        fcmToken.hashCode;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => _$DeviceInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum DeviceInfoPlatformEnum {
@JsonValue(r'android')
android(r'android');

const DeviceInfoPlatformEnum(this.value);

final String value;

@override
String toString() => value;
}
