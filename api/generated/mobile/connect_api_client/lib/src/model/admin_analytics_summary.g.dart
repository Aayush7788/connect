// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_analytics_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminAnalyticsSummaryCWProxy {
  AdminAnalyticsSummary totalProfiles(int totalProfiles);

  AdminAnalyticsSummary verifiedProfiles(int verifiedProfiles);

  AdminAnalyticsSummary pendingVerifications(int pendingVerifications);

  AdminAnalyticsSummary submittedReports(int submittedReports);

  AdminAnalyticsSummary profileViews(int profileViews);

  AdminAnalyticsSummary topSearchTerms(
    List<AdminAnalyticsSummaryTopSearchTermsInner> topSearchTerms,
  );

  AdminAnalyticsSummary contactActions(Map<String, int> contactActions);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminAnalyticsSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminAnalyticsSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminAnalyticsSummary call({
    int totalProfiles,
    int verifiedProfiles,
    int pendingVerifications,
    int submittedReports,
    int profileViews,
    List<AdminAnalyticsSummaryTopSearchTermsInner> topSearchTerms,
    Map<String, int> contactActions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminAnalyticsSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminAnalyticsSummary.copyWith.fieldName(...)`
class _$AdminAnalyticsSummaryCWProxyImpl
    implements _$AdminAnalyticsSummaryCWProxy {
  const _$AdminAnalyticsSummaryCWProxyImpl(this._value);

  final AdminAnalyticsSummary _value;

  @override
  AdminAnalyticsSummary totalProfiles(int totalProfiles) =>
      this(totalProfiles: totalProfiles);

  @override
  AdminAnalyticsSummary verifiedProfiles(int verifiedProfiles) =>
      this(verifiedProfiles: verifiedProfiles);

  @override
  AdminAnalyticsSummary pendingVerifications(int pendingVerifications) =>
      this(pendingVerifications: pendingVerifications);

  @override
  AdminAnalyticsSummary submittedReports(int submittedReports) =>
      this(submittedReports: submittedReports);

  @override
  AdminAnalyticsSummary profileViews(int profileViews) =>
      this(profileViews: profileViews);

  @override
  AdminAnalyticsSummary topSearchTerms(
    List<AdminAnalyticsSummaryTopSearchTermsInner> topSearchTerms,
  ) => this(topSearchTerms: topSearchTerms);

  @override
  AdminAnalyticsSummary contactActions(Map<String, int> contactActions) =>
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
    Object? pendingVerifications = const $CopyWithPlaceholder(),
    Object? submittedReports = const $CopyWithPlaceholder(),
    Object? profileViews = const $CopyWithPlaceholder(),
    Object? topSearchTerms = const $CopyWithPlaceholder(),
    Object? contactActions = const $CopyWithPlaceholder(),
  }) {
    return AdminAnalyticsSummary(
      totalProfiles: totalProfiles == const $CopyWithPlaceholder()
          ? _value.totalProfiles
          // ignore: cast_nullable_to_non_nullable
          : totalProfiles as int,
      verifiedProfiles: verifiedProfiles == const $CopyWithPlaceholder()
          ? _value.verifiedProfiles
          // ignore: cast_nullable_to_non_nullable
          : verifiedProfiles as int,
      pendingVerifications: pendingVerifications == const $CopyWithPlaceholder()
          ? _value.pendingVerifications
          // ignore: cast_nullable_to_non_nullable
          : pendingVerifications as int,
      submittedReports: submittedReports == const $CopyWithPlaceholder()
          ? _value.submittedReports
          // ignore: cast_nullable_to_non_nullable
          : submittedReports as int,
      profileViews: profileViews == const $CopyWithPlaceholder()
          ? _value.profileViews
          // ignore: cast_nullable_to_non_nullable
          : profileViews as int,
      topSearchTerms: topSearchTerms == const $CopyWithPlaceholder()
          ? _value.topSearchTerms
          // ignore: cast_nullable_to_non_nullable
          : topSearchTerms as List<AdminAnalyticsSummaryTopSearchTermsInner>,
      contactActions: contactActions == const $CopyWithPlaceholder()
          ? _value.contactActions
          // ignore: cast_nullable_to_non_nullable
          : contactActions as Map<String, int>,
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
    $checkKeys(
      json,
      requiredKeys: const [
        'total_profiles',
        'verified_profiles',
        'pending_verifications',
        'submitted_reports',
        'profile_views',
        'top_search_terms',
        'contact_actions',
      ],
    );
    final val = AdminAnalyticsSummary(
      totalProfiles: $checkedConvert(
        'total_profiles',
        (v) => (v as num).toInt(),
      ),
      verifiedProfiles: $checkedConvert(
        'verified_profiles',
        (v) => (v as num).toInt(),
      ),
      pendingVerifications: $checkedConvert(
        'pending_verifications',
        (v) => (v as num).toInt(),
      ),
      submittedReports: $checkedConvert(
        'submitted_reports',
        (v) => (v as num).toInt(),
      ),
      profileViews: $checkedConvert('profile_views', (v) => (v as num).toInt()),
      topSearchTerms: $checkedConvert(
        'top_search_terms',
        (v) => (v as List<dynamic>)
            .map(
              (e) => AdminAnalyticsSummaryTopSearchTermsInner.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
      contactActions: $checkedConvert(
        'contact_actions',
        (v) => Map<String, int>.from(v as Map),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'totalProfiles': 'total_profiles',
    'verifiedProfiles': 'verified_profiles',
    'pendingVerifications': 'pending_verifications',
    'submittedReports': 'submitted_reports',
    'profileViews': 'profile_views',
    'topSearchTerms': 'top_search_terms',
    'contactActions': 'contact_actions',
  },
);

Map<String, dynamic> _$AdminAnalyticsSummaryToJson(
  AdminAnalyticsSummary instance,
) => <String, dynamic>{
  'total_profiles': instance.totalProfiles,
  'verified_profiles': instance.verifiedProfiles,
  'pending_verifications': instance.pendingVerifications,
  'submitted_reports': instance.submittedReports,
  'profile_views': instance.profileViews,
  'top_search_terms': instance.topSearchTerms.map((e) => e.toJson()).toList(),
  'contact_actions': instance.contactActions,
};
