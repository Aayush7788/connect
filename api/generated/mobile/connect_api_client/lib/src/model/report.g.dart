// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReportCWProxy {
  Report id(String id);

  Report status(ReportStatus status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Report(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Report(...).copyWith(id: 12, name: "My name")
  /// ````
  Report call({String id, ReportStatus status});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReport.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReport.copyWith.fieldName(...)`
class _$ReportCWProxyImpl implements _$ReportCWProxy {
  const _$ReportCWProxyImpl(this._value);

  final Report _value;

  @override
  Report id(String id) => this(id: id);

  @override
  Report status(ReportStatus status) => this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Report(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Report(...).copyWith(id: 12, name: "My name")
  /// ````
  Report call({
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return Report(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ReportStatus,
    );
  }
}

extension $ReportCopyWith on Report {
  /// Returns a callable class that can be used as follows: `instanceOfReport.copyWith(...)` or like so:`instanceOfReport.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReportCWProxy get copyWith => _$ReportCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Report', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'status']);
      final val = Report(
        id: $checkedConvert('id', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$ReportStatusEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$ReportStatusEnumMap[instance.status]!,
};

const _$ReportStatusEnumMap = {
  ReportStatus.submitted: 'submitted',
  ReportStatus.inReview: 'in_review',
  ReportStatus.resolvedNoAction: 'resolved_no_action',
  ReportStatus.actionTaken: 'action_taken',
  ReportStatus.dismissed: 'dismissed',
};
