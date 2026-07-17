// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_analytics_summary_top_search_terms_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminAnalyticsSummaryTopSearchTermsInnerCWProxy {
  AdminAnalyticsSummaryTopSearchTermsInner term(String term);

  AdminAnalyticsSummaryTopSearchTermsInner count(int count);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminAnalyticsSummaryTopSearchTermsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminAnalyticsSummaryTopSearchTermsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminAnalyticsSummaryTopSearchTermsInner call({String term, int count});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminAnalyticsSummaryTopSearchTermsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminAnalyticsSummaryTopSearchTermsInner.copyWith.fieldName(...)`
class _$AdminAnalyticsSummaryTopSearchTermsInnerCWProxyImpl
    implements _$AdminAnalyticsSummaryTopSearchTermsInnerCWProxy {
  const _$AdminAnalyticsSummaryTopSearchTermsInnerCWProxyImpl(this._value);

  final AdminAnalyticsSummaryTopSearchTermsInner _value;

  @override
  AdminAnalyticsSummaryTopSearchTermsInner term(String term) =>
      this(term: term);

  @override
  AdminAnalyticsSummaryTopSearchTermsInner count(int count) =>
      this(count: count);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminAnalyticsSummaryTopSearchTermsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminAnalyticsSummaryTopSearchTermsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminAnalyticsSummaryTopSearchTermsInner call({
    Object? term = const $CopyWithPlaceholder(),
    Object? count = const $CopyWithPlaceholder(),
  }) {
    return AdminAnalyticsSummaryTopSearchTermsInner(
      term: term == const $CopyWithPlaceholder()
          ? _value.term
          // ignore: cast_nullable_to_non_nullable
          : term as String,
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int,
    );
  }
}

extension $AdminAnalyticsSummaryTopSearchTermsInnerCopyWith
    on AdminAnalyticsSummaryTopSearchTermsInner {
  /// Returns a callable class that can be used as follows: `instanceOfAdminAnalyticsSummaryTopSearchTermsInner.copyWith(...)` or like so:`instanceOfAdminAnalyticsSummaryTopSearchTermsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminAnalyticsSummaryTopSearchTermsInnerCWProxy get copyWith =>
      _$AdminAnalyticsSummaryTopSearchTermsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminAnalyticsSummaryTopSearchTermsInner
_$AdminAnalyticsSummaryTopSearchTermsInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AdminAnalyticsSummaryTopSearchTermsInner', json, (
      $checkedConvert,
    ) {
      $checkKeys(json, requiredKeys: const ['term', 'count']);
      final val = AdminAnalyticsSummaryTopSearchTermsInner(
        term: $checkedConvert('term', (v) => v as String),
        count: $checkedConvert('count', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$AdminAnalyticsSummaryTopSearchTermsInnerToJson(
  AdminAnalyticsSummaryTopSearchTermsInner instance,
) => <String, dynamic>{'term': instance.term, 'count': instance.count};
