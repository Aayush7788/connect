//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_analytics_summary_top_search_terms_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminAnalyticsSummaryTopSearchTermsInner {
  /// Returns a new [AdminAnalyticsSummaryTopSearchTermsInner] instance.
  AdminAnalyticsSummaryTopSearchTermsInner({
    required this.term,

    required this.count,
  });

  @JsonKey(name: r'term', required: true, includeIfNull: false)
  final String term;

  @JsonKey(name: r'count', required: true, includeIfNull: false)
  final int count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAnalyticsSummaryTopSearchTermsInner &&
          other.term == term &&
          other.count == count;

  @override
  int get hashCode => term.hashCode + count.hashCode;

  factory AdminAnalyticsSummaryTopSearchTermsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$AdminAnalyticsSummaryTopSearchTermsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AdminAnalyticsSummaryTopSearchTermsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
