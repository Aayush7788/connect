//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum WorkCardStatus {
      @JsonValue(r'draft')
      draft(r'draft'),
      @JsonValue(r'published')
      published(r'published'),
      @JsonValue(r'hidden_by_user')
      hiddenByUser(r'hidden_by_user'),
      @JsonValue(r'removed_by_admin')
      removedByAdmin(r'removed_by_admin'),
      @JsonValue(r'deleted')
      deleted(r'deleted');

  const WorkCardStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
