//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum SavedTargetType {
      @JsonValue(r'profile')
      profile(r'profile'),
      @JsonValue(r'work_card')
      workCard(r'work_card'),
      @JsonValue(r'work_needed_post')
      workNeededPost(r'work_needed_post');

  const SavedTargetType(this.value);

  final String value;

  @override
  String toString() => value;
}
