// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_summary_safe_documents_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VerificationSummarySafeDocumentsInnerCWProxy {
  VerificationSummarySafeDocumentsInner documentType(String? documentType);

  VerificationSummarySafeDocumentsInner status(String? status);

  VerificationSummarySafeDocumentsInner safeDisplayName(
    String? safeDisplayName,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationSummarySafeDocumentsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationSummarySafeDocumentsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationSummarySafeDocumentsInner call({
    String? documentType,
    String? status,
    String? safeDisplayName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVerificationSummarySafeDocumentsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVerificationSummarySafeDocumentsInner.copyWith.fieldName(...)`
class _$VerificationSummarySafeDocumentsInnerCWProxyImpl
    implements _$VerificationSummarySafeDocumentsInnerCWProxy {
  const _$VerificationSummarySafeDocumentsInnerCWProxyImpl(this._value);

  final VerificationSummarySafeDocumentsInner _value;

  @override
  VerificationSummarySafeDocumentsInner documentType(String? documentType) =>
      this(documentType: documentType);

  @override
  VerificationSummarySafeDocumentsInner status(String? status) =>
      this(status: status);

  @override
  VerificationSummarySafeDocumentsInner safeDisplayName(
    String? safeDisplayName,
  ) => this(safeDisplayName: safeDisplayName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VerificationSummarySafeDocumentsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VerificationSummarySafeDocumentsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  VerificationSummarySafeDocumentsInner call({
    Object? documentType = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? safeDisplayName = const $CopyWithPlaceholder(),
  }) {
    return VerificationSummarySafeDocumentsInner(
      documentType: documentType == const $CopyWithPlaceholder()
          ? _value.documentType
          // ignore: cast_nullable_to_non_nullable
          : documentType as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      safeDisplayName: safeDisplayName == const $CopyWithPlaceholder()
          ? _value.safeDisplayName
          // ignore: cast_nullable_to_non_nullable
          : safeDisplayName as String?,
    );
  }
}

extension $VerificationSummarySafeDocumentsInnerCopyWith
    on VerificationSummarySafeDocumentsInner {
  /// Returns a callable class that can be used as follows: `instanceOfVerificationSummarySafeDocumentsInner.copyWith(...)` or like so:`instanceOfVerificationSummarySafeDocumentsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VerificationSummarySafeDocumentsInnerCWProxy get copyWith =>
      _$VerificationSummarySafeDocumentsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationSummarySafeDocumentsInner
_$VerificationSummarySafeDocumentsInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'VerificationSummarySafeDocumentsInner',
      json,
      ($checkedConvert) {
        final val = VerificationSummarySafeDocumentsInner(
          documentType: $checkedConvert('document_type', (v) => v as String?),
          status: $checkedConvert('status', (v) => v as String?),
          safeDisplayName: $checkedConvert(
            'safe_display_name',
            (v) => v as String?,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'documentType': 'document_type',
        'safeDisplayName': 'safe_display_name',
      },
    );

Map<String, dynamic> _$VerificationSummarySafeDocumentsInnerToJson(
  VerificationSummarySafeDocumentsInner instance,
) => <String, dynamic>{
  'document_type': ?instance.documentType,
  'status': ?instance.status,
  'safe_display_name': ?instance.safeDisplayName,
};
