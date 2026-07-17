//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_report.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminReport {
  /// Returns a new [AdminReport] instance.
  AdminReport({
    this.id,

    required this.reportedEntityType,

    required this.reportedEntityId,

    required this.reason,

    this.status,

    this.message,

    required this.reportCount,

    required this.latestReportedAt,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'reported_entity_type', required: true, includeIfNull: false)
  final String reportedEntityType;

  @JsonKey(name: r'reported_entity_id', required: true, includeIfNull: false)
  final String reportedEntityId;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'message', required: false, includeIfNull: false)
  final String? message;

  // minimum: 1
  @JsonKey(name: r'report_count', required: true, includeIfNull: false)
  final int reportCount;

  @JsonKey(name: r'latest_reported_at', required: true, includeIfNull: false)
  final DateTime latestReportedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminReport &&
          other.id == id &&
          other.reportedEntityType == reportedEntityType &&
          other.reportedEntityId == reportedEntityId &&
          other.reason == reason &&
          other.status == status &&
          other.message == message &&
          other.reportCount == reportCount &&
          other.latestReportedAt == latestReportedAt;

  @override
  int get hashCode =>
      id.hashCode +
      reportedEntityType.hashCode +
      reportedEntityId.hashCode +
      reason.hashCode +
      status.hashCode +
      message.hashCode +
      reportCount.hashCode +
      latestReportedAt.hashCode;

  factory AdminReport.fromJson(Map<String, dynamic> json) =>
      _$AdminReportFromJson(json);

  Map<String, dynamic> toJson() => _$AdminReportToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
