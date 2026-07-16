//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/location_option.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location_option_list.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LocationOptionList {
  /// Returns a new [LocationOptionList] instance.
  LocationOptionList({

    required  this.items,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<LocationOption> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LocationOptionList &&
      other.items == items;

    @override
    int get hashCode =>
        items.hashCode;

  factory LocationOptionList.fromJson(Map<String, dynamic> json) => _$LocationOptionListFromJson(json);

  Map<String, dynamic> toJson() => _$LocationOptionListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

