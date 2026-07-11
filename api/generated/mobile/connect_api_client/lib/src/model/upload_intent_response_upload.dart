//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_intent_response_upload.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UploadIntentResponseUpload {
  /// Returns a new [UploadIntentResponseUpload] instance.
  UploadIntentResponseUpload({

    required  this.method,

     this.url,

     this.headers,

     this.expiresAt,
  });

  @JsonKey(
    
    name: r'method',
    required: true,
    includeIfNull: false,
  )


  final UploadIntentResponseUploadMethodEnum method;



  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



  @JsonKey(
    
    name: r'headers',
    required: false,
    includeIfNull: false,
  )


  final Map<String, String>? headers;



  @JsonKey(
    
    name: r'expires_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UploadIntentResponseUpload &&
      other.method == method &&
      other.url == url &&
      other.headers == headers &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        method.hashCode +
        url.hashCode +
        headers.hashCode +
        expiresAt.hashCode;

  factory UploadIntentResponseUpload.fromJson(Map<String, dynamic> json) => _$UploadIntentResponseUploadFromJson(json);

  Map<String, dynamic> toJson() => _$UploadIntentResponseUploadToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum UploadIntentResponseUploadMethodEnum {
@JsonValue(r'signed_url')
signedUrl(r'signed_url'),
@JsonValue(r'backend_proxy')
backendProxy(r'backend_proxy');

const UploadIntentResponseUploadMethodEnum(this.value);

final String value;

@override
String toString() => value;
}


