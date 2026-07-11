//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum ProfileVisibilityStatus {
      @JsonValue(r'draft')
      draft(r'draft'),
      @JsonValue(r'public')
      public(r'public'),
      @JsonValue(r'hidden_by_user')
      hiddenByUser(r'hidden_by_user'),
      @JsonValue(r'suspended_by_admin')
      suspendedByAdmin(r'suspended_by_admin'),
      @JsonValue(r'deleted')
      deleted(r'deleted');

  const ProfileVisibilityStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
