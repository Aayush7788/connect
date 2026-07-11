//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/user_role.dart';
import 'package:connect_api_client/src/model/account_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class User {
  /// Returns a new [User] instance.
  User({

    required  this.id,

    required  this.displayName,

    required  this.primaryMobile,

    required  this.accountStatus,

     this.role,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'display_name',
    required: true,
    includeIfNull: false,
  )


  final String displayName;



  @JsonKey(
    
    name: r'primary_mobile',
    required: true,
    includeIfNull: false,
  )


  final String primaryMobile;



  @JsonKey(
    
    name: r'account_status',
    required: true,
    includeIfNull: false,
  )


  final AccountStatus accountStatus;



  @JsonKey(
    
    name: r'role',
    required: false,
    includeIfNull: false,
  )


  final UserRole? role;





    @override
    bool operator ==(Object other) => identical(this, other) || other is User &&
      other.id == id &&
      other.displayName == displayName &&
      other.primaryMobile == primaryMobile &&
      other.accountStatus == accountStatus &&
      other.role == role;

    @override
    int get hashCode =>
        id.hashCode +
        displayName.hashCode +
        primaryMobile.hashCode +
        accountStatus.hashCode +
        role.hashCode;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

