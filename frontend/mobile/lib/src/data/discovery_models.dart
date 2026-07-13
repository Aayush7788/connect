import 'package:connect_app/src/data/media_models.dart';
import 'package:connect_app/src/data/work_card_models.dart';
import 'package:connect_app/src/data/work_needed_post_models.dart';

class MarketplaceSearchRequest {
  const MarketplaceSearchRequest({
    required this.target,
    this.query,
    this.businessMode,
    this.categoryId,
    this.productTypeId,
    this.locality,
    this.minExperienceYears,
    this.maxExperienceYears,
    this.verifiedOnly = false,
    this.sort = 'best',
  });

  final String target;
  final String? query;
  final String? businessMode;
  final String? categoryId;
  final String? productTypeId;
  final String? locality;
  final int? minExperienceYears;
  final int? maxExperienceYears;
  final bool verifiedOnly;
  final String sort;

  Map<String, dynamic> toQueryParameters() {
    return {
      'target': target,
      if (query != null && query!.trim().isNotEmpty) 'q': query!.trim(),
      if (target == 'business')
        'business_mode': businessMode ?? 'work_needed_posts',
      if (categoryId != null) 'category_id': categoryId,
      if (productTypeId != null) 'product_type_id': productTypeId,
      if (locality != null && locality!.trim().isNotEmpty)
        'locality': locality!.trim(),
      if (minExperienceYears != null)
        'min_experience_years': minExperienceYears,
      if (maxExperienceYears != null)
        'max_experience_years': maxExperienceYears,
      if (verifiedOnly) 'verified_only': true,
      if (sort != 'best') 'sort': sort,
    };
  }
}

class MarketplaceSearchResponse {
  const MarketplaceSearchResponse({
    required this.items,
    required this.resultCount,
    required this.searchLogId,
    this.nextCursor,
  });

  factory MarketplaceSearchResponse.fromJson(Map<String, dynamic> json) {
    return MarketplaceSearchResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                MarketplaceSearchResult.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      resultCount: json['result_count'] as int? ?? 0,
      nextCursor: json['next_cursor'] as String?,
      searchLogId: json['search_log_id'] as String? ?? '',
    );
  }

  final List<MarketplaceSearchResult> items;
  final int resultCount;
  final String? nextCursor;
  final String searchLogId;
}

class MarketplaceSearchResult {
  const MarketplaceSearchResult({
    required this.resultType,
    required this.id,
    required this.profileId,
    required this.title,
    required this.isVerified,
    required this.photoCount,
    this.subtitle,
    this.category,
    this.productTypes = const [],
    this.description,
    this.locality,
    this.experienceYears,
    this.photos = const [],
  });

  factory MarketplaceSearchResult.fromJson(Map<String, dynamic> json) {
    return MarketplaceSearchResult(
      resultType: json['result_type'] as String,
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      category: json['category'] as String?,
      productTypes: (json['product_types'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(growable: false),
      description: json['description'] as String?,
      locality: json['locality'] as String?,
      experienceYears: json['experience_years'] as int?,
      isVerified: json['is_verified'] as bool? ?? false,
      photoCount: json['photo_count'] as int? ?? 0,
      photos: (json['photos'] as List<dynamic>? ?? [])
          .map(
            (value) => MediaAssetResult.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  final String resultType;
  final String id;
  final String profileId;
  final String title;
  final String? subtitle;
  final String? category;
  final List<String> productTypes;
  final String? description;
  final String? locality;
  final int? experienceYears;
  final bool isVerified;
  final int photoCount;
  final List<MediaAssetResult> photos;
}

class PublicProfileDetailResult {
  const PublicProfileDetailResult({
    required this.profile,
    required this.roleSpecific,
    required this.contact,
    required this.address,
    required this.media,
    required this.workCards,
    required this.workNeededPosts,
    required this.similarProfiles,
  });

  factory PublicProfileDetailResult.fromJson(Map<String, dynamic> json) {
    return PublicProfileDetailResult(
      profile: PublicProfileSummary.fromJson(
        json['profile'] as Map<String, dynamic>,
      ),
      roleSpecific: Map<String, dynamic>.from(
        json['role_specific'] as Map<String, dynamic>? ?? {},
      ),
      contact: PublicContactResult.fromJson(
        json['contact'] as Map<String, dynamic>? ?? {},
      ),
      address: PublicAddressResult.fromJson(
        json['address'] as Map<String, dynamic>? ?? {},
      ),
      media: (json['media'] as List<dynamic>? ?? [])
          .map(
            (value) => MediaAssetResult.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
      workCards: (json['work_cards'] as List<dynamic>? ?? [])
          .map(
            (value) => WorkCardResult.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
      workNeededPosts: (json['work_needed_posts'] as List<dynamic>? ?? [])
          .map(
            (value) =>
                WorkNeededPostResult.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
      similarProfiles: (json['similar_profiles'] as List<dynamic>? ?? [])
          .map(
            (value) =>
                MarketplaceSearchResult.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  final PublicProfileSummary profile;
  final Map<String, dynamic> roleSpecific;
  final PublicContactResult contact;
  final PublicAddressResult address;
  final List<MediaAssetResult> media;
  final List<WorkCardResult> workCards;
  final List<WorkNeededPostResult> workNeededPosts;
  final List<MarketplaceSearchResult> similarProfiles;
}

class PublicProfileSummary {
  const PublicProfileSummary({
    required this.id,
    required this.role,
    required this.visibilityStatus,
    required this.completionScore,
    required this.verificationStatus,
    required this.isVerified,
    this.displayName,
    this.reverificationRequired = false,
  });

  factory PublicProfileSummary.fromJson(Map<String, dynamic> json) {
    return PublicProfileSummary(
      id: json['id'] as String,
      role: json['role'] as String,
      displayName: json['display_name'] as String?,
      visibilityStatus: json['visibility_status'] as String? ?? 'public',
      completionScore: json['completion_score'] as int? ?? 0,
      verificationStatus:
          json['verification_status'] as String? ?? 'unverified',
      isVerified: json['is_verified'] as bool? ?? false,
      reverificationRequired: json['reverification_required'] as bool? ?? false,
    );
  }

  final String id;
  final String role;
  final String? displayName;
  final String visibilityStatus;
  final int completionScore;
  final String verificationStatus;
  final bool isVerified;
  final bool reverificationRequired;
}

class PublicContactResult {
  const PublicContactResult({this.mobile, this.whatsappNumber});

  factory PublicContactResult.fromJson(Map<String, dynamic> json) {
    return PublicContactResult(
      mobile: json['mobile'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
    );
  }

  final String? mobile;
  final String? whatsappNumber;
}

class PublicAddressResult {
  const PublicAddressResult({
    this.locality,
    this.city,
    this.state,
    this.pincode,
    this.fullAddress,
  });

  factory PublicAddressResult.fromJson(Map<String, dynamic> json) {
    return PublicAddressResult(
      locality: json['locality'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      fullAddress: json['full_address'] as String?,
    );
  }

  final String? locality;
  final String? city;
  final String? state;
  final String? pincode;
  final String? fullAddress;
}
