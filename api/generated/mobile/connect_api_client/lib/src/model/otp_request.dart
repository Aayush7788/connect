//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'otp_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OtpRequest {
  /// Returns a new [OtpRequest] instance.
  OtpRequest({

    required  this.mobile,
  });

  @JsonKey(
    
    name: r'mobile',
    required: true,
    includeIfNull: false,
  )


  final String mobile;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OtpRequest &&
      other.mobile == mobile;

    @override
    int get hashCode =>
        mobile.hashCode;

  factory OtpRequest.fromJson(Map<String, dynamic> json) => _$OtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OtpRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

