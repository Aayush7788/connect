// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_report_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateReportRequestCWProxy {
  CreateReportRequest reportedEntityType(
    CreateReportRequestReportedEntityTypeEnum reportedEntityType,
  );

  CreateReportRequest reportedEntityId(String reportedEntityId);

  CreateReportRequest reason(ReportReason reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateReportRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateReportRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateReportRequest call({
    CreateReportRequestReportedEntityTypeEnum reportedEntityType,
    String reportedEntityId,
    ReportReason reason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateReportRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateReportRequest.copyWith.fieldName(...)`
class _$CreateReportRequestCWProxyImpl implements _$CreateReportRequestCWProxy {
  const _$CreateReportRequestCWProxyImpl(this._value);

  final CreateReportRequest _value;

  @override
  CreateReportRequest reportedEntityType(
    CreateReportRequestReportedEntityTypeEnum reportedEntityType,
  ) => this(reportedEntityType: reportedEntityType);

  @override
  CreateReportRequest reportedEntityId(String reportedEntityId) =>
      this(reportedEntityId: reportedEntityId);

  @override
  CreateReportRequest reason(ReportReason reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateReportRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateReportRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateReportRequest call({
    Object? reportedEntityType = const $CopyWithPlaceholder(),
    Object? reportedEntityId = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return CreateReportRequest(
      reportedEntityType: reportedEntityType == const $CopyWithPlaceholder()
          ? _value.reportedEntityType
          // ignore: cast_nullable_to_non_nullable
          : reportedEntityType as CreateReportRequestReportedEntityTypeEnum,
      reportedEntityId: reportedEntityId == const $CopyWithPlaceholder()
          ? _value.reportedEntityId
          // ignore: cast_nullable_to_non_nullable
          : reportedEntityId as String,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as ReportReason,
    );
  }
}

extension $CreateReportRequestCopyWith on CreateReportRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateReportRequest.copyWith(...)` or like so:`instanceOfCreateReportRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateReportRequestCWProxy get copyWith =>
      _$CreateReportRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReportRequest _$CreateReportRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CreateReportRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'reported_entity_type',
            'reported_entity_id',
            'reason',
          ],
        );
        final val = CreateReportRequest(
          reportedEntityType: $checkedConvert(
            'reported_entity_type',
            (v) => $enumDecode(
              _$CreateReportRequestReportedEntityTypeEnumEnumMap,
              v,
            ),
          ),
          reportedEntityId: $checkedConvert(
            'reported_entity_id',
            (v) => v as String,
          ),
          reason: $checkedConvert(
            'reason',
            (v) => $enumDecode(_$ReportReasonEnumMap, v),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'reportedEntityType': 'reported_entity_type',
        'reportedEntityId': 'reported_entity_id',
      },
    );

Map<String, dynamic> _$CreateReportRequestToJson(
  CreateReportRequest instance,
) => <String, dynamic>{
  'reported_entity_type':
      _$CreateReportRequestReportedEntityTypeEnumEnumMap[instance
          .reportedEntityType]!,
  'reported_entity_id': instance.reportedEntityId,
  'reason': _$ReportReasonEnumMap[instance.reason]!,
};

const _$CreateReportRequestReportedEntityTypeEnumEnumMap = {
  CreateReportRequestReportedEntityTypeEnum.profile: 'profile',
  CreateReportRequestReportedEntityTypeEnum.workCard: 'work_card',
  CreateReportRequestReportedEntityTypeEnum.workNeededPost: 'work_needed_post',
};

const _$ReportReasonEnumMap = {
  ReportReason.wrongContact: 'wrong_contact',
  ReportReason.wrongCategory: 'wrong_category',
  ReportReason.inappropriatePhoto: 'inappropriate_photo',
  ReportReason.wrongDetails: 'wrong_details',
  ReportReason.fakeProfile: 'fake_profile',
  ReportReason.spam: 'spam',
  ReportReason.other: 'other',
};
