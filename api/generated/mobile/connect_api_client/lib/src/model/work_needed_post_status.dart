//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum WorkNeededPostStatus {
      @JsonValue(r'draft')
      draft(r'draft'),
      @JsonValue(r'active')
      active(r'active'),
      @JsonValue(r'paused')
      paused(r'paused'),
      @JsonValue(r'closed_by_user')
      closedByUser(r'closed_by_user'),
      @JsonValue(r'removed_by_admin')
      removedByAdmin(r'removed_by_admin'),
      @JsonValue(r'deleted')
      deleted(r'deleted');

  const WorkNeededPostStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
