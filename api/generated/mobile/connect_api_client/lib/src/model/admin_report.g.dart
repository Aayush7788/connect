// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_report.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminReportCWProxy {
  AdminReport id(String? id);

  AdminReport reportedEntityType(String reportedEntityType);

  AdminReport reportedEntityId(String reportedEntityId);

  AdminReport reason(String reason);

  AdminReport status(String? status);

  AdminReport message(String? message);

  AdminReport reportCount(int reportCount);

  AdminReport latestReportedAt(DateTime latestReportedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminReport(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminReport call({
    String? id,
    String reportedEntityType,
    String reportedEntityId,
    String reason,
    String? status,
    String? message,
    int reportCount,
    DateTime latestReportedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminReport.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminReport.copyWith.fieldName(...)`
class _$AdminReportCWProxyImpl implements _$AdminReportCWProxy {
  const _$AdminReportCWProxyImpl(this._value);

  final AdminReport _value;

  @override
  AdminReport id(String? id) => this(id: id);

  @override
  AdminReport reportedEntityType(String reportedEntityType) =>
      this(reportedEntityType: reportedEntityType);

  @override
  AdminReport reportedEntityId(String reportedEntityId) =>
      this(reportedEntityId: reportedEntityId);

  @override
  AdminReport reason(String reason) => this(reason: reason);

  @override
  AdminReport status(String? status) => this(status: status);

  @override
  AdminReport message(String? message) => this(message: message);

  @override
  AdminReport reportCount(int reportCount) => this(reportCount: reportCount);

  @override
  AdminReport latestReportedAt(DateTime latestReportedAt) =>
      this(latestReportedAt: latestReportedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminReport(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminReport call({
    Object? id = const $CopyWithPlaceholder(),
    Object? reportedEntityType = const $CopyWithPlaceholder(),
    Object? reportedEntityId = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? reportCount = const $CopyWithPlaceholder(),
    Object? latestReportedAt = const $CopyWithPlaceholder(),
  }) {
    return AdminReport(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      reportedEntityType: reportedEntityType == const $CopyWithPlaceholder()
          ? _value.reportedEntityType
          // ignore: cast_nullable_to_non_nullable
          : reportedEntityType as String,
      reportedEntityId: reportedEntityId == const $CopyWithPlaceholder()
          ? _value.reportedEntityId
          // ignore: cast_nullable_to_non_nullable
          : reportedEntityId as String,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      reportCount: reportCount == const $CopyWithPlaceholder()
          ? _value.reportCount
          // ignore: cast_nullable_to_non_nullable
          : reportCount as int,
      latestReportedAt: latestReportedAt == const $CopyWithPlaceholder()
          ? _value.latestReportedAt
          // ignore: cast_nullable_to_non_nullable
          : latestReportedAt as DateTime,
    );
  }
}

extension $AdminReportCopyWith on AdminReport {
  /// Returns a callable class that can be used as follows: `instanceOfAdminReport.copyWith(...)` or like so:`instanceOfAdminReport.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminReportCWProxy get copyWith => _$AdminReportCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminReport _$AdminReportFromJson(Map<String, dynamic> json) => $checkedCreate(
  'AdminReport',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'reported_entity_type',
        'reported_entity_id',
        'reason',
        'report_count',
        'latest_reported_at',
      ],
    );
    final val = AdminReport(
      id: $checkedConvert('id', (v) => v as String?),
      reportedEntityType: $checkedConvert(
        'reported_entity_type',
        (v) => v as String,
      ),
      reportedEntityId: $checkedConvert(
        'reported_entity_id',
        (v) => v as String,
      ),
      reason: $checkedConvert('reason', (v) => v as String),
      status: $checkedConvert('status', (v) => v as String?),
      message: $checkedConvert('message', (v) => v as String?),
      reportCount: $checkedConvert('report_count', (v) => (v as num).toInt()),
      latestReportedAt: $checkedConvert(
        'latest_reported_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'reportedEntityType': 'reported_entity_type',
    'reportedEntityId': 'reported_entity_id',
    'reportCount': 'report_count',
    'latestReportedAt': 'latest_reported_at',
  },
);

Map<String, dynamic> _$AdminReportToJson(AdminReport instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'reported_entity_type': instance.reportedEntityType,
      'reported_entity_id': instance.reportedEntityId,
      'reason': instance.reason,
      'status': ?instance.status,
      'message': ?instance.message,
      'report_count': instance.reportCount,
      'latest_reported_at': instance.latestReportedAt.toIso8601String(),
    };
