// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicProfileDetailCWProxy {
  PublicProfileDetail profile(ProfileSummary profile);

  PublicProfileDetail contact(PublicContact contact);

  PublicProfileDetail address(PublicAddress? address);

  PublicProfileDetail media(List<MediaAsset> media);

  PublicProfileDetail workCards(List<WorkCard>? workCards);

  PublicProfileDetail workNeededPosts(List<WorkNeededPost>? workNeededPosts);

  PublicProfileDetail similarProfiles(List<SearchResult>? similarProfiles);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicProfileDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicProfileDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicProfileDetail call({
    ProfileSummary profile,
    PublicContact contact,
    PublicAddress? address,
    List<MediaAsset> media,
    List<WorkCard>? workCards,
    List<WorkNeededPost>? workNeededPosts,
    List<SearchResult>? similarProfiles,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicProfileDetail.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicProfileDetail.copyWith.fieldName(...)`
class _$PublicProfileDetailCWProxyImpl implements _$PublicProfileDetailCWProxy {
  const _$PublicProfileDetailCWProxyImpl(this._value);

  final PublicProfileDetail _value;

  @override
  PublicProfileDetail profile(ProfileSummary profile) => this(profile: profile);

  @override
  PublicProfileDetail contact(PublicContact contact) => this(contact: contact);

  @override
  PublicProfileDetail address(PublicAddress? address) => this(address: address);

  @override
  PublicProfileDetail media(List<MediaAsset> media) => this(media: media);

  @override
  PublicProfileDetail workCards(List<WorkCard>? workCards) =>
      this(workCards: workCards);

  @override
  PublicProfileDetail workNeededPosts(List<WorkNeededPost>? workNeededPosts) =>
      this(workNeededPosts: workNeededPosts);

  @override
  PublicProfileDetail similarProfiles(List<SearchResult>? similarProfiles) =>
      this(similarProfiles: similarProfiles);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicProfileDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicProfileDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicProfileDetail call({
    Object? profile = const $CopyWithPlaceholder(),
    Object? contact = const $CopyWithPlaceholder(),
    Object? address = const $CopyWithPlaceholder(),
    Object? media = const $CopyWithPlaceholder(),
    Object? workCards = const $CopyWithPlaceholder(),
    Object? workNeededPosts = const $CopyWithPlaceholder(),
    Object? similarProfiles = const $CopyWithPlaceholder(),
  }) {
    return PublicProfileDetail(
      profile: profile == const $CopyWithPlaceholder()
          ? _value.profile
          // ignore: cast_nullable_to_non_nullable
          : profile as ProfileSummary,
      contact: contact == const $CopyWithPlaceholder()
          ? _value.contact
          // ignore: cast_nullable_to_non_nullable
          : contact as PublicContact,
      address: address == const $CopyWithPlaceholder()
          ? _value.address
          // ignore: cast_nullable_to_non_nullable
          : address as PublicAddress?,
      media: media == const $CopyWithPlaceholder()
          ? _value.media
          // ignore: cast_nullable_to_non_nullable
          : media as List<MediaAsset>,
      workCards: workCards == const $CopyWithPlaceholder()
          ? _value.workCards
          // ignore: cast_nullable_to_non_nullable
          : workCards as List<WorkCard>?,
      workNeededPosts: workNeededPosts == const $CopyWithPlaceholder()
          ? _value.workNeededPosts
          // ignore: cast_nullable_to_non_nullable
          : workNeededPosts as List<WorkNeededPost>?,
      similarProfiles: similarProfiles == const $CopyWithPlaceholder()
          ? _value.similarProfiles
          // ignore: cast_nullable_to_non_nullable
          : similarProfiles as List<SearchResult>?,
    );
  }
}

extension $PublicProfileDetailCopyWith on PublicProfileDetail {
  /// Returns a callable class that can be used as follows: `instanceOfPublicProfileDetail.copyWith(...)` or like so:`instanceOfPublicProfileDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicProfileDetailCWProxy get copyWith =>
      _$PublicProfileDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicProfileDetail _$PublicProfileDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PublicProfileDetail',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['profile', 'contact', 'media']);
        final val = PublicProfileDetail(
          profile: $checkedConvert(
            'profile',
            (v) => ProfileSummary.fromJson(v as Map<String, dynamic>),
          ),
          contact: $checkedConvert(
            'contact',
            (v) => PublicContact.fromJson(v as Map<String, dynamic>),
          ),
          address: $checkedConvert(
            'address',
            (v) => v == null
                ? null
                : PublicAddress.fromJson(v as Map<String, dynamic>),
          ),
          media: $checkedConvert(
            'media',
            (v) => (v as List<dynamic>)
                .map((e) => MediaAsset.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          workCards: $checkedConvert(
            'work_cards',
            (v) => (v as List<dynamic>?)
                ?.map((e) => WorkCard.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          workNeededPosts: $checkedConvert(
            'work_needed_posts',
            (v) => (v as List<dynamic>?)
                ?.map((e) => WorkNeededPost.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          similarProfiles: $checkedConvert(
            'similar_profiles',
            (v) => (v as List<dynamic>?)
                ?.map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'workCards': 'work_cards',
        'workNeededPosts': 'work_needed_posts',
        'similarProfiles': 'similar_profiles',
      },
    );

Map<String, dynamic> _$PublicProfileDetailToJson(
  PublicProfileDetail instance,
) => <String, dynamic>{
  'profile': instance.profile.toJson(),
  'contact': instance.contact.toJson(),
  'address': ?instance.address?.toJson(),
  'media': instance.media.map((e) => e.toJson()).toList(),
  'work_cards': ?instance.workCards?.map((e) => e.toJson()).toList(),
  'work_needed_posts': ?instance.workNeededPosts
      ?.map((e) => e.toJson())
      .toList(),
  'similar_profiles': ?instance.similarProfiles
      ?.map((e) => e.toJson())
      .toList(),
};
