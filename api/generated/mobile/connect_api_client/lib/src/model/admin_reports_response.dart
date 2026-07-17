//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/admin_report.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_reports_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminReportsResponse {
  /// Returns a new [AdminReportsResponse] instance.
  AdminReportsResponse({required this.items, this.nextCursor});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<AdminReport> items;

  @JsonKey(name: r'next_cursor', required: false, includeIfNull: false)
  final String? nextCursor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminReportsResponse &&
          other.items == items &&
          other.nextCursor == nextCursor;

  @override
  int get hashCode => items.hashCode + nextCursor.hashCode;

  factory AdminReportsResponse.fromJson(Map<String, dynamic> json) =>
      _$AdminReportsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminReportsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
