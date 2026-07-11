//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_share_link_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateShareLinkRequest {
  /// Returns a new [CreateShareLinkRequest] instance.
  CreateShareLinkRequest({

    required  this.targetType,

    required  this.targetId,

     this.channel,
  });

  @JsonKey(
    
    name: r'target_type',
    required: true,
    includeIfNull: false,
  )


  final CreateShareLinkRequestTargetTypeEnum targetType;



  @JsonKey(
    
    name: r'target_id',
    required: true,
    includeIfNull: false,
  )


  final String targetId;



  @JsonKey(
    
    name: r'channel',
    required: false,
    includeIfNull: false,
  )


  final CreateShareLinkRequestChannelEnum? channel;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateShareLinkRequest &&
      other.targetType == targetType &&
      other.targetId == targetId &&
      other.channel == channel;

    @override
    int get hashCode =>
        targetType.hashCode +
        targetId.hashCode +
        channel.hashCode;

  factory CreateShareLinkRequest.fromJson(Map<String, dynamic> json) => _$CreateShareLinkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateShareLinkRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CreateShareLinkRequestTargetTypeEnum {
@JsonValue(r'profile')
profile(r'profile'),
@JsonValue(r'work_card')
workCard(r'work_card'),
@JsonValue(r'work_needed_post')
workNeededPost(r'work_needed_post');

const CreateShareLinkRequestTargetTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum CreateShareLinkRequestChannelEnum {
@JsonValue(r'copy_link')
copyLink(r'copy_link'),
@JsonValue(r'whatsapp')
whatsapp(r'whatsapp'),
@JsonValue(r'sms')
sms(r'sms'),
@JsonValue(r'x')
x(r'x'),
@JsonValue(r'email')
email(r'email'),
@JsonValue(r'linkedin')
linkedin(r'linkedin'),
@JsonValue(r'native_other')
nativeOther(r'native_other');

const CreateShareLinkRequestChannelEnum(this.value);

final String value;

@override
String toString() => value;
}


