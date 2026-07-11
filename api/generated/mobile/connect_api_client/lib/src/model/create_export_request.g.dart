// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_export_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateExportRequestCWProxy {
  CreateExportRequest dataset(CreateExportRequestDatasetEnum dataset);

  CreateExportRequest filters(Map<String, Object>? filters);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateExportRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateExportRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateExportRequest call({
    CreateExportRequestDatasetEnum dataset,
    Map<String, Object>? filters,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateExportRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateExportRequest.copyWith.fieldName(...)`
class _$CreateExportRequestCWProxyImpl implements _$CreateExportRequestCWProxy {
  const _$CreateExportRequestCWProxyImpl(this._value);

  final CreateExportRequest _value;

  @override
  CreateExportRequest dataset(CreateExportRequestDatasetEnum dataset) =>
      this(dataset: dataset);

  @override
  CreateExportRequest filters(Map<String, Object>? filters) =>
      this(filters: filters);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateExportRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateExportRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateExportRequest call({
    Object? dataset = const $CopyWithPlaceholder(),
    Object? filters = const $CopyWithPlaceholder(),
  }) {
    return CreateExportRequest(
      dataset: dataset == const $CopyWithPlaceholder()
          ? _value.dataset
          // ignore: cast_nullable_to_non_nullable
          : dataset as CreateExportRequestDatasetEnum,
      filters: filters == const $CopyWithPlaceholder()
          ? _value.filters
          // ignore: cast_nullable_to_non_nullable
          : filters as Map<String, Object>?,
    );
  }
}

extension $CreateExportRequestCopyWith on CreateExportRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateExportRequest.copyWith(...)` or like so:`instanceOfCreateExportRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateExportRequestCWProxy get copyWith =>
      _$CreateExportRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateExportRequest _$CreateExportRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateExportRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['dataset']);
      final val = CreateExportRequest(
        dataset: $checkedConvert(
          'dataset',
          (v) => $enumDecode(_$CreateExportRequestDatasetEnumEnumMap, v),
        ),
        filters: $checkedConvert(
          'filters',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CreateExportRequestToJson(
  CreateExportRequest instance,
) => <String, dynamic>{
  'dataset': _$CreateExportRequestDatasetEnumEnumMap[instance.dataset]!,
  'filters': ?instance.filters,
};

const _$CreateExportRequestDatasetEnumEnumMap = {
  CreateExportRequestDatasetEnum.profiles: 'profiles',
  CreateExportRequestDatasetEnum.verificationCases: 'verification_cases',
  CreateExportRequestDatasetEnum.reports: 'reports',
  CreateExportRequestDatasetEnum.searchSummary: 'search_summary',
  CreateExportRequestDatasetEnum.contactSummary: 'contact_summary',
};
