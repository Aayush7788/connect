//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'basic_account_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BasicAccountRequest {
  /// Returns a new [BasicAccountRequest] instance.
  BasicAccountRequest({

    required  this.displayName,

    required  this.acceptedTermsVersion,

    required  this.acceptedPrivacyVersion,
  });

  @JsonKey(
    
    name: r'display_name',
    required: true,
    includeIfNull: false,
  )


  final String displayName;



  @JsonKey(
    
    name: r'accepted_terms_version',
    required: true,
    includeIfNull: false,
  )


  final String acceptedTermsVersion;



  @JsonKey(
    
    name: r'accepted_privacy_version',
    required: true,
    includeIfNull: false,
  )


  final String acceptedPrivacyVersion;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BasicAccountRequest &&
      other.displayName == displayName &&
      other.acceptedTermsVersion == acceptedTermsVersion &&
      other.acceptedPrivacyVersion == acceptedPrivacyVersion;

    @override
    int get hashCode =>
        displayName.hashCode +
        acceptedTermsVersion.hashCode +
        acceptedPrivacyVersion.hashCode;

  factory BasicAccountRequest.fromJson(Map<String, dynamic> json) => _$BasicAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BasicAccountRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

