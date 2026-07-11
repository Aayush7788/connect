//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/saved_item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'saved_items_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SavedItemsResponse {
  /// Returns a new [SavedItemsResponse] instance.
  SavedItemsResponse({

    required  this.items,

     this.nextCursor,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<SavedItem> items;



  @JsonKey(
    
    name: r'next_cursor',
    required: false,
    includeIfNull: false,
  )


  final String? nextCursor;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SavedItemsResponse &&
      other.items == items &&
      other.nextCursor == nextCursor;

    @override
    int get hashCode =>
        items.hashCode +
        nextCursor.hashCode;

  factory SavedItemsResponse.fromJson(Map<String, dynamic> json) => _$SavedItemsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SavedItemsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

