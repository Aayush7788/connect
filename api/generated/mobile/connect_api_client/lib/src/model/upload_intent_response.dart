//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/upload_intent_response_upload.dart';
import 'package:connect_api_client/src/model/media_asset.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_intent_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UploadIntentResponse {
  /// Returns a new [UploadIntentResponse] instance.
  UploadIntentResponse({

    required  this.mediaAsset,

    required  this.upload,
  });

  @JsonKey(
    
    name: r'media_asset',
    required: true,
    includeIfNull: false,
  )


  final MediaAsset mediaAsset;



  @JsonKey(
    
    name: r'upload',
    required: true,
    includeIfNull: false,
  )


  final UploadIntentResponseUpload upload;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UploadIntentResponse &&
      other.mediaAsset == mediaAsset &&
      other.upload == upload;

    @override
    int get hashCode =>
        mediaAsset.hashCode +
        upload.hashCode;

  factory UploadIntentResponse.fromJson(Map<String, dynamic> json) => _$UploadIntentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadIntentResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

