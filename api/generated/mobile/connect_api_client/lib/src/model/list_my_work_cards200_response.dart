//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/work_card.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'list_my_work_cards200_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ListMyWorkCards200Response {
  /// Returns a new [ListMyWorkCards200Response] instance.
  ListMyWorkCards200Response({

    required  this.items,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<WorkCard> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ListMyWorkCards200Response &&
      other.items == items;

    @override
    int get hashCode =>
        items.hashCode;

  factory ListMyWorkCards200Response.fromJson(Map<String, dynamic> json) => _$ListMyWorkCards200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListMyWorkCards200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

