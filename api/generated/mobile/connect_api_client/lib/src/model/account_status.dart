//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum AccountStatus {
      @JsonValue(r'active')
      active(r'active'),
      @JsonValue(r'suspended')
      suspended(r'suspended'),
      @JsonValue(r'terminated')
      terminated(r'terminated');

  const AccountStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
