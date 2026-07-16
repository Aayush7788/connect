//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/user_role.dart';
import 'package:connect_api_client/src/model/saved_target_type.dart';
import 'package:connect_api_client/src/model/search_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'saved_item.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SavedItem {
  /// Returns a new [SavedItem] instance.
  SavedItem({

    required  this.id,

    required  this.targetType,

    required  this.targetId,

    required  this.profileRole,

     this.card,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



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



  @JsonKey(
    
    name: r'profile_role',
    required: true,
    includeIfNull: false,
  )


  final UserRole profileRole;



  @JsonKey(
    
    name: r'card',
    required: false,
    includeIfNull: false,
  )


  final SearchResult? card;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SavedItem &&
      other.id == id &&
      other.targetType == targetType &&
      other.targetId == targetId &&
      other.profileRole == profileRole &&
      other.card == card;

    @override
    int get hashCode =>
        id.hashCode +
        targetType.hashCode +
        targetId.hashCode +
        profileRole.hashCode +
        card.hashCode;

  factory SavedItem.fromJson(Map<String, dynamic> json) => _$SavedItemFromJson(json);

  Map<String, dynamic> toJson() => _$SavedItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

