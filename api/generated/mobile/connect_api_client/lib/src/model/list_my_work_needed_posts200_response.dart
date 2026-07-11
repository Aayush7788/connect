//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/work_needed_post.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'list_my_work_needed_posts200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ListMyWorkNeededPosts200Response {
  /// Returns a new [ListMyWorkNeededPosts200Response] instance.
  ListMyWorkNeededPosts200Response({

    required  this.items,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<WorkNeededPost> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ListMyWorkNeededPosts200Response &&
      other.items == items;

    @override
    int get hashCode =>
        items.hashCode;

  factory ListMyWorkNeededPosts200Response.fromJson(Map<String, dynamic> json) => _$ListMyWorkNeededPosts200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListMyWorkNeededPosts200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

