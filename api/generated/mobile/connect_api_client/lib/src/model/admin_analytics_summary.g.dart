// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_analytics_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminAnalyticsSummaryCWProxy {
  AdminAnalyticsSummary totalProfiles(int? totalProfiles);

  AdminAnalyticsSummary verifiedProfiles(int? verifiedProfiles);

  AdminAnalyticsSummary topSearchTerms(
    List<Map<String, Object>>? topSearchTerms,
  );

  AdminAnalyticsSummary contactActions(Map<String, Object>? contactActions);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminAnalyticsSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminAnalyticsSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminAnalyticsSummary call({
    int? totalProfiles,
    int? verifiedProfiles,
    List<Map<String, Object>>? topSearchTerms,
    Map<String, Object>? contactActions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminAnalyticsSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminAnalyticsSummary.copyWith.fieldName(...)`
class _$AdminAnalyticsSummaryCWProxyImpl
    implements _$AdminAnalyticsSummaryCWProxy {
  const _$AdminAnalyticsSummaryCWProxyImpl(this._value);

  final AdminAnalyticsSummary _value;

  @override
  AdminAnalyticsSummary totalProfiles(int? totalProfiles) =>
      this(totalProfiles: totalProfiles);

  @override
  AdminAnalyticsSummary verifiedProfiles(int? verifiedProfiles) =>
      this(verifiedProfiles: verifiedProfiles);

  @override
  AdminAnalyticsSummary topSearchTerms(
    List<Map<String, Object>>? topSearchTerms,
  ) => this(topSearchTerms: topSearchTerms);

  @override
  AdminAnalyticsSummary contactActions(Map<String, Object>? contactActions) =>
      this(contactActions: contactActions);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminAnalyticsSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminAnalyticsSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminAnalyticsSummary call({
    Object? totalProfiles = const $CopyWithPlaceholder(),
    Object? verifiedProfiles = const $CopyWithPlaceholder(),
    Object? topSearchTerms = const $CopyWithPlaceholder(),
    Object? contactActions = const $CopyWithPlaceholder(),
  }) {
    return AdminAnalyticsSummary(
      totalProfiles: totalProfiles == const $CopyWithPlaceholder()
          ? _value.totalProfiles
          // ignore: cast_nullable_to_non_nullable
          : totalProfiles as int?,
      verifiedProfiles: verifiedProfiles == const $CopyWithPlaceholder()
          ? _value.verifiedProfiles
          // ignore: cast_nullable_to_non_nullable
          : verifiedProfiles as int?,
      topSearchTerms: topSearchTerms == const $CopyWithPlaceholder()
          ? _value.topSearchTerms
          // ignore: cast_nullable_to_non_nullable
          : topSearchTerms as List<Map<String, Object>>?,
      contactActions: contactActions == const $CopyWithPlaceholder()
          ? _value.contactActions
          // ignore: cast_nullable_to_non_nullable
          : contactActions as Map<String, Object>?,
    );
  }
}

extension $AdminAnalyticsSummaryCopyWith on AdminAnalyticsSummary {
  /// Returns a callable class that can be used as follows: `instanceOfAdminAnalyticsSummary.copyWith(...)` or like so:`instanceOfAdminAnalyticsSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminAnalyticsSummaryCWProxy get copyWith =>
      _$AdminAnalyticsSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminAnalyticsSummary _$AdminAnalyticsSummaryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdminAnalyticsSummary',
  json,
  ($checkedConvert) {
    final val = AdminAnalyticsSummary(
      totalProfiles: $checkedConvert(
        'total_profiles',
        (v) => (v as num?)?.toInt(),
      ),
      verifiedProfiles: $checkedConvert(
        'verified_profiles',
        (v) => (v as num?)?.toInt(),
      ),
      topSearchTerms: $checkedConvert(
        'top_search_terms',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) => (e as Map<String, dynamic>).map(
                (k, e) => MapEntry(k, e as Object),
              ),
            )
            .toList(),
      ),
      contactActions: $checkedConvert(
        'contact_actions',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'totalProfiles': 'total_profiles',
    'verifiedProfiles': 'verified_profiles',
    'topSearchTerms': 'top_search_terms',
    'contactActions': 'contact_actions',
  },
);

Map<String, dynamic> _$AdminAnalyticsSummaryToJson(
  AdminAnalyticsSummary instance,
) => <String, dynamic>{
  'total_profiles': ?instance.totalProfiles,
  'verified_profiles': ?instance.verifiedProfiles,
  'top_search_terms': ?instance.topSearchTerms,
  'contact_actions': ?instance.contactActions,
};
