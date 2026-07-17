// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_job.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExportJobCWProxy {
  ExportJob id(String id);

  ExportJob status(ExportJobStatusEnum status);

  ExportJob downloadUrl(String downloadUrl);

  ExportJob expiresAt(DateTime expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportJob(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportJob call({
    String id,
    ExportJobStatusEnum status,
    String downloadUrl,
    DateTime expiresAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExportJob.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExportJob.copyWith.fieldName(...)`
class _$ExportJobCWProxyImpl implements _$ExportJobCWProxy {
  const _$ExportJobCWProxyImpl(this._value);

  final ExportJob _value;

  @override
  ExportJob id(String id) => this(id: id);

  @override
  ExportJob status(ExportJobStatusEnum status) => this(status: status);

  @override
  ExportJob downloadUrl(String downloadUrl) => this(downloadUrl: downloadUrl);

  @override
  ExportJob expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportJob(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportJob call({
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? downloadUrl = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return ExportJob(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ExportJobStatusEnum,
      downloadUrl: downloadUrl == const $CopyWithPlaceholder()
          ? _value.downloadUrl
          // ignore: cast_nullable_to_non_nullable
          : downloadUrl as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $ExportJobCopyWith on ExportJob {
  /// Returns a callable class that can be used as follows: `instanceOfExportJob.copyWith(...)` or like so:`instanceOfExportJob.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExportJobCWProxy get copyWith => _$ExportJobCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportJob _$ExportJobFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ExportJob',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['id', 'status', 'download_url', 'expires_at'],
    );
    final val = ExportJob(
      id: $checkedConvert('id', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$ExportJobStatusEnumEnumMap, v),
      ),
      downloadUrl: $checkedConvert('download_url', (v) => v as String),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'downloadUrl': 'download_url', 'expiresAt': 'expires_at'},
);

Map<String, dynamic> _$ExportJobToJson(ExportJob instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$ExportJobStatusEnumEnumMap[instance.status]!,
  'download_url': instance.downloadUrl,
  'expires_at': instance.expiresAt.toIso8601String(),
};

const _$ExportJobStatusEnumEnumMap = {ExportJobStatusEnum.ready: 'ready'};
