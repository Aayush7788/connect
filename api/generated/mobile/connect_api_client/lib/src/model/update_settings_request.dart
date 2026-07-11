//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_settings_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateSettingsRequest {
  /// Returns a new [UpdateSettingsRequest] instance.
  UpdateSettingsRequest({

     this.pushNotificationsEnabled,

     this.hiddenFromSearch,
  });

  @JsonKey(
    
    name: r'push_notifications_enabled',
    required: false,
    includeIfNull: false,
  )


  final bool? pushNotificationsEnabled;



  @JsonKey(
    
    name: r'hidden_from_search',
    required: false,
    includeIfNull: false,
  )


  final bool? hiddenFromSearch;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateSettingsRequest &&
      other.pushNotificationsEnabled == pushNotificationsEnabled &&
      other.hiddenFromSearch == hiddenFromSearch;

    @override
    int get hashCode =>
        pushNotificationsEnabled.hashCode +
        hiddenFromSearch.hashCode;

  factory UpdateSettingsRequest.fromJson(Map<String, dynamic> json) => _$UpdateSettingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateSettingsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

