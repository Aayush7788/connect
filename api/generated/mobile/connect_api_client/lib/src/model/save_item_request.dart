//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/saved_target_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_item_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaveItemRequest {
  /// Returns a new [SaveItemRequest] instance.
  SaveItemRequest({

    required  this.targetType,

    required  this.targetId,
  });

  @JsonKey(
    
    name: r'target_type',
    required: true,
    includeIfNull: false,
  )


  final SavedTargetType targetType;



  @JsonKey(
    
    name: r'target_id',
    required: true,
    includeIfNull: false,
  )


  final String targetId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SaveItemRequest &&
      other.targetType == targetType &&
      other.targetId == targetId;

    @override
    int get hashCode =>
        targetType.hashCode +
        targetId.hashCode;

  factory SaveItemRequest.fromJson(Map<String, dynamic> json) => _$SaveItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveItemRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

