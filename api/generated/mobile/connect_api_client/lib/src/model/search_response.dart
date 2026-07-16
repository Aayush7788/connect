//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/search_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SearchResponse {
  /// Returns a new [SearchResponse] instance.
  SearchResponse({

    required  this.items,

    required  this.resultCount,

     this.nextCursor,

    required  this.searchLogId,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<SearchResult> items;



  @JsonKey(
    
    name: r'result_count',
    required: true,
    includeIfNull: false,
  )


  final int resultCount;



  @JsonKey(
    
    name: r'next_cursor',
    required: false,
    includeIfNull: false,
  )


  final String? nextCursor;



  @JsonKey(
    
    name: r'search_log_id',
    required: true,
    includeIfNull: false,
  )


  final String searchLogId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SearchResponse &&
      other.items == items &&
      other.resultCount == resultCount &&
      other.nextCursor == nextCursor &&
      other.searchLogId == searchLogId;

    @override
    int get hashCode =>
        items.hashCode +
        resultCount.hashCode +
        nextCursor.hashCode +
        searchLogId.hashCode;

  factory SearchResponse.fromJson(Map<String, dynamic> json) => _$SearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

