//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
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

     this.totalProfiles,

     this.verifiedProfiles,

     this.topSearchTerms,

     this.contactActions,
  });

  @JsonKey(
    
    name: r'total_profiles',
    required: false,
    includeIfNull: false,
  )


  final int? totalProfiles;



  @JsonKey(
    
    name: r'verified_profiles',
    required: false,
    includeIfNull: false,
  )


  final int? verifiedProfiles;



  @JsonKey(
    
    name: r'top_search_terms',
    required: false,
    includeIfNull: false,
  )


  final List<Map<String, Object>>? topSearchTerms;



  @JsonKey(
    
    name: r'contact_actions',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? contactActions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminAnalyticsSummary &&
      other.totalProfiles == totalProfiles &&
      other.verifiedProfiles == verifiedProfiles &&
      other.topSearchTerms == topSearchTerms &&
      other.contactActions == contactActions;

    @override
    int get hashCode =>
        totalProfiles.hashCode +
        verifiedProfiles.hashCode +
        topSearchTerms.hashCode +
        contactActions.hashCode;

  factory AdminAnalyticsSummary.fromJson(Map<String, dynamic> json) => _$AdminAnalyticsSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AdminAnalyticsSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

