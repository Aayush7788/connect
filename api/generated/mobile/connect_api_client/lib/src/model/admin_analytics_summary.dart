//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/admin_analytics_summary_top_search_terms_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_analytics_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminAnalyticsSummary {
  /// Returns a new [AdminAnalyticsSummary] instance.
  AdminAnalyticsSummary({
    required this.totalProfiles,

    required this.verifiedProfiles,

    required this.pendingVerifications,

    required this.submittedReports,

    required this.profileViews,

    required this.topSearchTerms,

    required this.contactActions,
  });

  @JsonKey(name: r'total_profiles', required: true, includeIfNull: false)
  final int totalProfiles;

  @JsonKey(name: r'verified_profiles', required: true, includeIfNull: false)
  final int verifiedProfiles;

  @JsonKey(name: r'pending_verifications', required: true, includeIfNull: false)
  final int pendingVerifications;

  @JsonKey(name: r'submitted_reports', required: true, includeIfNull: false)
  final int submittedReports;

  @JsonKey(name: r'profile_views', required: true, includeIfNull: false)
  final int profileViews;

  @JsonKey(name: r'top_search_terms', required: true, includeIfNull: false)
  final List<AdminAnalyticsSummaryTopSearchTermsInner> topSearchTerms;

  @JsonKey(name: r'contact_actions', required: true, includeIfNull: false)
  final Map<String, int> contactActions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAnalyticsSummary &&
          other.totalProfiles == totalProfiles &&
          other.verifiedProfiles == verifiedProfiles &&
          other.pendingVerifications == pendingVerifications &&
          other.submittedReports == submittedReports &&
          other.profileViews == profileViews &&
          other.topSearchTerms == topSearchTerms &&
          other.contactActions == contactActions;

  @override
  int get hashCode =>
      totalProfiles.hashCode +
      verifiedProfiles.hashCode +
      pendingVerifications.hashCode +
      submittedReports.hashCode +
      profileViews.hashCode +
      topSearchTerms.hashCode +
      contactActions.hashCode;

  factory AdminAnalyticsSummary.fromJson(Map<String, dynamic> json) =>
      _$AdminAnalyticsSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAnalyticsSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
