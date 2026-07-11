//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/media_kind.dart';
import 'package:connect_api_client/src/model/media_visibility.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_intent_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UploadIntentRequest {
  /// Returns a new [UploadIntentRequest] instance.
  UploadIntentRequest({

    required  this.entityType,

    required  this.entityId,

    required  this.mediaKind,

    required  this.visibility,

     this.documentType,

    required  this.filename,

    required  this.mimeType,

    required  this.byteSize,
  });

  @JsonKey(
    
    name: r'entity_type',
    required: true,
    includeIfNull: false,
  )


  final UploadIntentRequestEntityTypeEnum entityType;



  @JsonKey(
    
    name: r'entity_id',
    required: true,
    includeIfNull: false,
  )


  final String entityId;



  @JsonKey(
    
    name: r'media_kind',
    required: true,
    includeIfNull: false,
  )


  final MediaKind mediaKind;



  @JsonKey(
    
    name: r'visibility',
    required: true,
    includeIfNull: false,
  )


  final MediaVisibility visibility;



  @JsonKey(
    
    name: r'document_type',
    required: false,
    includeIfNull: false,
  )


  final UploadIntentRequestDocumentTypeEnum? documentType;



  @JsonKey(
    
    name: r'filename',
    required: true,
    includeIfNull: false,
  )


  final String filename;



  @JsonKey(
    
    name: r'mime_type',
    required: true,
    includeIfNull: false,
  )


  final String mimeType;



  @JsonKey(
    
    name: r'byte_size',
    required: true,
    includeIfNull: false,
  )


  final int byteSize;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UploadIntentRequest &&
      other.entityType == entityType &&
      other.entityId == entityId &&
      other.mediaKind == mediaKind &&
      other.visibility == visibility &&
      other.documentType == documentType &&
      other.filename == filename &&
      other.mimeType == mimeType &&
      other.byteSize == byteSize;

    @override
    int get hashCode =>
        entityType.hashCode +
        entityId.hashCode +
        mediaKind.hashCode +
        visibility.hashCode +
        documentType.hashCode +
        filename.hashCode +
        mimeType.hashCode +
        byteSize.hashCode;

  factory UploadIntentRequest.fromJson(Map<String, dynamic> json) => _$UploadIntentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UploadIntentRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum UploadIntentRequestEntityTypeEnum {
@JsonValue(r'profile')
profile(r'profile'),
@JsonValue(r'work_card')
workCard(r'work_card'),
@JsonValue(r'work_needed_post')
workNeededPost(r'work_needed_post'),
@JsonValue(r'verification_case')
verificationCase(r'verification_case');

const UploadIntentRequestEntityTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum UploadIntentRequestDocumentTypeEnum {
@JsonValue(r'identity_proof')
identityProof(r'identity_proof'),
@JsonValue(r'masked_aadhaar')
maskedAadhaar(r'masked_aadhaar'),
@JsonValue(r'gst_proof')
gstProof(r'gst_proof'),
@JsonValue(r'shop_photo')
shopPhoto(r'shop_photo'),
@JsonValue(r'workplace_photo')
workplacePhoto(r'workplace_photo'),
@JsonValue(r'work_photo')
workPhoto(r'work_photo'),
@JsonValue(r'other')
other(r'other');

const UploadIntentRequestDocumentTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


