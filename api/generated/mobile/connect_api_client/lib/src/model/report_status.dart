//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum ReportStatus {
      @JsonValue(r'submitted')
      submitted(r'submitted'),
      @JsonValue(r'in_review')
      inReview(r'in_review'),
      @JsonValue(r'resolved_no_action')
      resolvedNoAction(r'resolved_no_action'),
      @JsonValue(r'action_taken')
      actionTaken(r'action_taken'),
      @JsonValue(r'dismissed')
      dismissed(r'dismissed');

  const ReportStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
