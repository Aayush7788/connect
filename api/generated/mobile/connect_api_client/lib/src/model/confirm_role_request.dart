//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/user_role.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'confirm_role_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfirmRoleRequest {
  /// Returns a new [ConfirmRoleRequest] instance.
  ConfirmRoleRequest({

    required  this.role,
  });

  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final UserRole role;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConfirmRoleRequest &&
      other.role == role;

    @override
    int get hashCode =>
        role.hashCode;

  factory ConfirmRoleRequest.fromJson(Map<String, dynamic> json) => _$ConfirmRoleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmRoleRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

