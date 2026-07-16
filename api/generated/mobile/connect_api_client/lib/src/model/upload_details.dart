//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_details.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UploadDetails {
  /// Returns a new [UploadDetails] instance.
  UploadDetails({

    required  this.method,

    required  this.httpMethod,

    required  this.formField,

    required  this.url,

    required  this.headers,

    required  this.expiresAt,
  });

  @JsonKey(
    
    name: r'method',
    required: true,
    includeIfNull: false,
  )


  final UploadDetailsMethodEnum method;



  @JsonKey(
    
    name: r'http_method',
    required: true,
    includeIfNull: false,
  )


  final UploadDetailsHttpMethodEnum httpMethod;



  @JsonKey(
    
    name: r'form_field',
    required: true,
    includeIfNull: false,
  )


  final UploadDetailsFormFieldEnum formField;



  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'headers',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> headers;



  @JsonKey(
    
    name: r'expires_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UploadDetails &&
      other.method == method &&
      other.httpMethod == httpMethod &&
      other.formField == formField &&
      other.url == url &&
      other.headers == headers &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        method.hashCode +
        httpMethod.hashCode +
        formField.hashCode +
        url.hashCode +
        headers.hashCode +
        expiresAt.hashCode;

  factory UploadDetails.fromJson(Map<String, dynamic> json) => _$UploadDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UploadDetailsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum UploadDetailsMethodEnum {
@JsonValue(r'signed_url')
signedUrl(r'signed_url');

const UploadDetailsMethodEnum(this.value);

final String value;

@override
String toString() => value;
}



enum UploadDetailsHttpMethodEnum {
@JsonValue(r'PUT')
PUT(r'PUT');

const UploadDetailsHttpMethodEnum(this.value);

final String value;

@override
String toString() => value;
}



enum UploadDetailsFormFieldEnum {
@JsonValue(r'file')
file(r'file');

const UploadDetailsFormFieldEnum(this.value);

final String value;

@override
String toString() => value;
}


