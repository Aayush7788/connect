//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/admin_profile.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_profiles_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminProfilesResponse {
  /// Returns a new [AdminProfilesResponse] instance.
  AdminProfilesResponse({

    required  this.items,

     this.nextCursor,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<AdminProfile> items;



  @JsonKey(
    
    name: r'next_cursor',
    required: false,
    includeIfNull: false,
  )


  final String? nextCursor;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminProfilesResponse &&
      other.items == items &&
      other.nextCursor == nextCursor;

    @override
    int get hashCode =>
        items.hashCode +
        nextCursor.hashCode;

  factory AdminProfilesResponse.fromJson(Map<String, dynamic> json) => _$AdminProfilesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminProfilesResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

