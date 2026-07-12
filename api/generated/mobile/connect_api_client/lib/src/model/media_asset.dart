//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/media_kind.dart';
import 'package:connect_api_client/src/model/upload_status.dart';
import 'package:connect_api_client/src/model/media_visibility.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_asset.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaAsset {
  /// Returns a new [MediaAsset] instance.
  MediaAsset({

    required  this.id,

    required  this.mediaKind,

    required  this.visibility,

    required  this.uploadStatus,

     this.url,

     this.thumbnailUrl,

    required  this.sortOrder,

     this.documentType,

     this.safeDisplayName,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



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
    
    name: r'upload_status',
    required: true,
    includeIfNull: false,
  )


  final UploadStatus uploadStatus;



      /// Public-ready media URL only. Private proof media does not expose URL to owners/public.
  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



  @JsonKey(
    
    name: r'thumbnail_url',
    required: false,
    includeIfNull: false,
  )


  final String? thumbnailUrl;



  @JsonKey(
    
    name: r'sort_order',
    required: true,
    includeIfNull: false,
  )


  final int sortOrder;



  @JsonKey(
    
    name: r'document_type',
    required: false,
    includeIfNull: false,
  )


  final String? documentType;



  @JsonKey(
    
    name: r'safe_display_name',
    required: false,
    includeIfNull: false,
  )


  final String? safeDisplayName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaAsset &&
      other.id == id &&
      other.mediaKind == mediaKind &&
      other.visibility == visibility &&
      other.uploadStatus == uploadStatus &&
      other.url == url &&
      other.thumbnailUrl == thumbnailUrl &&
      other.sortOrder == sortOrder &&
      other.documentType == documentType &&
      other.safeDisplayName == safeDisplayName;

    @override
    int get hashCode =>
        id.hashCode +
        mediaKind.hashCode +
        visibility.hashCode +
        uploadStatus.hashCode +
        url.hashCode +
        thumbnailUrl.hashCode +
        sortOrder.hashCode +
        documentType.hashCode +
        safeDisplayName.hashCode;

  factory MediaAsset.fromJson(Map<String, dynamic> json) => _$MediaAssetFromJson(json);

  Map<String, dynamic> toJson() => _$MediaAssetToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

