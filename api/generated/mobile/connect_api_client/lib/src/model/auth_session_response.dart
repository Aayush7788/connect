//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/user.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_session_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AuthSessionResponse {
  /// Returns a new [AuthSessionResponse] instance.
  AuthSessionResponse({

    required  this.accessToken,

    required  this.refreshToken,

    required  this.nextState,

     this.user,
  });

  @JsonKey(
    
    name: r'access_token',
    required: true,
    includeIfNull: false,
  )


  final String accessToken;



  @JsonKey(
    
    name: r'refresh_token',
    required: true,
    includeIfNull: false,
  )


  final String refreshToken;



  @JsonKey(
    
    name: r'next_state',
    required: true,
    includeIfNull: false,
  )


  final AuthSessionResponseNextStateEnum nextState;



  @JsonKey(
    
    name: r'user',
    required: false,
    includeIfNull: false,
  )


  final User? user;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AuthSessionResponse &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken &&
      other.nextState == nextState &&
      other.user == user;

    @override
    int get hashCode =>
        accessToken.hashCode +
        refreshToken.hashCode +
        nextState.hashCode +
        user.hashCode;

  factory AuthSessionResponse.fromJson(Map<String, dynamic> json) => _$AuthSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthSessionResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AuthSessionResponseNextStateEnum {
@JsonValue(r'complete_basic_account')
completeBasicAccount(r'complete_basic_account'),
@JsonValue(r'role_selection_required')
roleSelectionRequired(r'role_selection_required'),
@JsonValue(r'home')
home(r'home'),
@JsonValue(r'account_blocked')
accountBlocked(r'account_blocked');

const AuthSessionResponseNextStateEnum(this.value);

final String value;

@override
String toString() => value;
}


