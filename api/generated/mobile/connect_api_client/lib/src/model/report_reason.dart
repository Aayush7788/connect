//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum ReportReason {
      @JsonValue(r'wrong_contact')
      wrongContact(r'wrong_contact'),
      @JsonValue(r'wrong_category')
      wrongCategory(r'wrong_category'),
      @JsonValue(r'inappropriate_photo')
      inappropriatePhoto(r'inappropriate_photo'),
      @JsonValue(r'wrong_details')
      wrongDetails(r'wrong_details'),
      @JsonValue(r'fake_profile')
      fakeProfile(r'fake_profile'),
      @JsonValue(r'spam')
      spam(r'spam'),
      @JsonValue(r'other')
      other(r'other');

  const ReportReason(this.value);

  final String value;

  @override
  String toString() => value;
}
