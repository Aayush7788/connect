//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_user.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminUser {
  /// Returns a new [AdminUser] instance.
  AdminUser({
    required this.id,

    this.displayName,

    required this.mobile,

    required this.role,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'display_name', required: false, includeIfNull: false)
  final String? displayName;

  @JsonKey(name: r'mobile', required: true, includeIfNull: false)
  final String mobile;

  @JsonKey(name: r'role', required: true, includeIfNull: false)
  final AdminUserRoleEnum role;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUser &&
          other.id == id &&
          other.displayName == displayName &&
          other.mobile == mobile &&
          other.role == role;

  @override
  int get hashCode =>
      id.hashCode + displayName.hashCode + mobile.hashCode + role.hashCode;

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AdminUserRoleEnum {
  @JsonValue(r'super_admin')
  superAdmin(r'super_admin');

  const AdminUserRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
