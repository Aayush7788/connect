//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/profile_summary.dart';
import 'package:connect_api_client/src/model/user.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'me_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeResponse {
  /// Returns a new [MeResponse] instance.
  MeResponse({

    required  this.user,

    required  this.nextState,

     this.profile,

     this.unreadNotificationCount,

     this.allowedActions,
  });

  @JsonKey(
    
    name: r'user',
    required: true,
    includeIfNull: false,
  )


  final User user;



  @JsonKey(
    
    name: r'next_state',
    required: true,
    includeIfNull: false,
  )


  final MeResponseNextStateEnum nextState;



  @JsonKey(

    name: r'profile',
    required: false,
    includeIfNull: false,
  )


  final ProfileSummary? profile;



  @JsonKey(
    
    name: r'unread_notification_count',
    required: false,
    includeIfNull: false,
  )


  final int? unreadNotificationCount;



  @JsonKey(
    
    name: r'allowed_actions',
    required: false,
    includeIfNull: false,
  )


  final List<String>? allowedActions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeResponse &&
      other.user == user &&
      other.nextState == nextState &&
      other.profile == profile &&
      other.unreadNotificationCount == unreadNotificationCount &&
      other.allowedActions == allowedActions;

    @override
    int get hashCode =>
        user.hashCode +
        nextState.hashCode +
        profile.hashCode +
        unreadNotificationCount.hashCode +
        allowedActions.hashCode;

  factory MeResponse.fromJson(Map<String, dynamic> json) => _$MeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MeResponseNextStateEnum {
@JsonValue(r'complete_basic_account')
completeBasicAccount(r'complete_basic_account'),
@JsonValue(r'role_selection_required')
roleSelectionRequired(r'role_selection_required'),
@JsonValue(r'home')
home(r'home'),
@JsonValue(r'account_blocked')
accountBlocked(r'account_blocked');

const MeResponseNextStateEnum(this.value);

final String value;

@override
String toString() => value;
}
