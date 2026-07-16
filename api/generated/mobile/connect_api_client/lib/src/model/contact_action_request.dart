//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_action_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ContactActionRequest {
  /// Returns a new [ContactActionRequest] instance.
  ContactActionRequest({

    required  this.profileId,

    required  this.actionType,

     this.sourceType,

     this.sourceId,
  });

  @JsonKey(
    
    name: r'profile_id',
    required: true,
    includeIfNull: false,
  )


  final String profileId;



  @JsonKey(
    
    name: r'action_type',
    required: true,
    includeIfNull: false,
  )


  final ContactActionRequestActionTypeEnum actionType;



  @JsonKey(
    
    name: r'source_type',
    required: false,
    includeIfNull: false,
  )


  final ContactActionRequestSourceTypeEnum? sourceType;



  @JsonKey(
    
    name: r'source_id',
    required: false,
    includeIfNull: false,
  )


  final String? sourceId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ContactActionRequest &&
      other.profileId == profileId &&
      other.actionType == actionType &&
      other.sourceType == sourceType &&
      other.sourceId == sourceId;

    @override
    int get hashCode =>
        profileId.hashCode +
        actionType.hashCode +
        sourceType.hashCode +
        sourceId.hashCode;

  factory ContactActionRequest.fromJson(Map<String, dynamic> json) => _$ContactActionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ContactActionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ContactActionRequestActionTypeEnum {
@JsonValue(r'call')
call(r'call'),
@JsonValue(r'whatsapp')
whatsapp(r'whatsapp'),
@JsonValue(r'address')
address(r'address');

const ContactActionRequestActionTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ContactActionRequestSourceTypeEnum {
@JsonValue(r'search')
search(r'search'),
@JsonValue(r'saved')
saved(r'saved'),
@JsonValue(r'profile')
profile(r'profile'),
@JsonValue(r'work_card')
workCard(r'work_card'),
@JsonValue(r'work_needed_post')
workNeededPost(r'work_needed_post');

const ContactActionRequestSourceTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


