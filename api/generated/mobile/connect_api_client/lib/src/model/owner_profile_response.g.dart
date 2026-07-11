// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_profile_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OwnerProfileResponseCWProxy {
  OwnerProfileResponse profile(ProfileSummary profile);

  OwnerProfileResponse editableFields(List<String>? editableFields);

  OwnerProfileResponse lockedFields(List<String>? lockedFields);

  OwnerProfileResponse roleSpecific(Map<String, Object>? roleSpecific);

  OwnerProfileResponse media(List<MediaAsset>? media);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OwnerProfileResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OwnerProfileResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OwnerProfileResponse call({
    ProfileSummary profile,
    List<String>? editableFields,
    List<String>? lockedFields,
    Map<String, Object>? roleSpecific,
    List<MediaAsset>? media,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOwnerProfileResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOwnerProfileResponse.copyWith.fieldName(...)`
class _$OwnerProfileResponseCWProxyImpl
    implements _$OwnerProfileResponseCWProxy {
  const _$OwnerProfileResponseCWProxyImpl(this._value);

  final OwnerProfileResponse _value;

  @override
  OwnerProfileResponse profile(ProfileSummary profile) =>
      this(profile: profile);

  @override
  OwnerProfileResponse editableFields(List<String>? editableFields) =>
      this(editableFields: editableFields);

  @override
  OwnerProfileResponse lockedFields(List<String>? lockedFields) =>
      this(lockedFields: lockedFields);

  @override
  OwnerProfileResponse roleSpecific(Map<String, Object>? roleSpecific) =>
      this(roleSpecific: roleSpecific);

  @override
  OwnerProfileResponse media(List<MediaAsset>? media) => this(media: media);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OwnerProfileResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OwnerProfileResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OwnerProfileResponse call({
    Object? profile = const $CopyWithPlaceholder(),
    Object? editableFields = const $CopyWithPlaceholder(),
    Object? lockedFields = const $CopyWithPlaceholder(),
    Object? roleSpecific = const $CopyWithPlaceholder(),
    Object? media = const $CopyWithPlaceholder(),
  }) {
    return OwnerProfileResponse(
      profile: profile == const $CopyWithPlaceholder()
          ? _value.profile
          // ignore: cast_nullable_to_non_nullable
          : profile as ProfileSummary,
      editableFields: editableFields == const $CopyWithPlaceholder()
          ? _value.editableFields
          // ignore: cast_nullable_to_non_nullable
          : editableFields as List<String>?,
      lockedFields: lockedFields == const $CopyWithPlaceholder()
          ? _value.lockedFields
          // ignore: cast_nullable_to_non_nullable
          : lockedFields as List<String>?,
      roleSpecific: roleSpecific == const $CopyWithPlaceholder()
          ? _value.roleSpecific
          // ignore: cast_nullable_to_non_nullable
          : roleSpecific as Map<String, Object>?,
      media: media == const $CopyWithPlaceholder()
          ? _value.media
          // ignore: cast_nullable_to_non_nullable
          : media as List<MediaAsset>?,
    );
  }
}

extension $OwnerProfileResponseCopyWith on OwnerProfileResponse {
  /// Returns a callable class that can be used as follows: `instanceOfOwnerProfileResponse.copyWith(...)` or like so:`instanceOfOwnerProfileResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OwnerProfileResponseCWProxy get copyWith =>
      _$OwnerProfileResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnerProfileResponse _$OwnerProfileResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'OwnerProfileResponse',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['profile']);
    final val = OwnerProfileResponse(
      profile: $checkedConvert(
        'profile',
        (v) => ProfileSummary.fromJson(v as Map<String, dynamic>),
      ),
      editableFields: $checkedConvert(
        'editable_fields',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      lockedFields: $checkedConvert(
        'locked_fields',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      roleSpecific: $checkedConvert(
        'role_specific',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
      media: $checkedConvert(
        'media',
        (v) => (v as List<dynamic>?)
            ?.map((e) => MediaAsset.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'editableFields': 'editable_fields',
    'lockedFields': 'locked_fields',
    'roleSpecific': 'role_specific',
  },
);

Map<String, dynamic> _$OwnerProfileResponseToJson(
  OwnerProfileResponse instance,
) => <String, dynamic>{
  'profile': instance.profile.toJson(),
  'editable_fields': ?instance.editableFields,
  'locked_fields': ?instance.lockedFields,
  'role_specific': ?instance.roleSpecific,
  'media': ?instance.media?.map((e) => e.toJson()).toList(),
};
