//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'share_link_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ShareLinkResponse {
  /// Returns a new [ShareLinkResponse] instance.
  ShareLinkResponse({

    required  this.url,

     this.shareText,
  });

  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



  @JsonKey(
    
    name: r'share_text',
    required: false,
    includeIfNull: false,
  )


  final String? shareText;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShareLinkResponse &&
      other.url == url &&
      other.shareText == shareText;

    @override
    int get hashCode =>
        url.hashCode +
        shareText.hashCode;

  factory ShareLinkResponse.fromJson(Map<String, dynamic> json) => _$ShareLinkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ShareLinkResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

