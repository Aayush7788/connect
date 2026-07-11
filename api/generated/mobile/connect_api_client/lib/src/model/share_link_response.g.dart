// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_link_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ShareLinkResponseCWProxy {
  ShareLinkResponse url(String url);

  ShareLinkResponse shareText(String? shareText);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShareLinkResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShareLinkResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ShareLinkResponse call({String url, String? shareText});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfShareLinkResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfShareLinkResponse.copyWith.fieldName(...)`
class _$ShareLinkResponseCWProxyImpl implements _$ShareLinkResponseCWProxy {
  const _$ShareLinkResponseCWProxyImpl(this._value);

  final ShareLinkResponse _value;

  @override
  ShareLinkResponse url(String url) => this(url: url);

  @override
  ShareLinkResponse shareText(String? shareText) => this(shareText: shareText);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShareLinkResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShareLinkResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ShareLinkResponse call({
    Object? url = const $CopyWithPlaceholder(),
    Object? shareText = const $CopyWithPlaceholder(),
  }) {
    return ShareLinkResponse(
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      shareText: shareText == const $CopyWithPlaceholder()
          ? _value.shareText
          // ignore: cast_nullable_to_non_nullable
          : shareText as String?,
    );
  }
}

extension $ShareLinkResponseCopyWith on ShareLinkResponse {
  /// Returns a callable class that can be used as follows: `instanceOfShareLinkResponse.copyWith(...)` or like so:`instanceOfShareLinkResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ShareLinkResponseCWProxy get copyWith =>
      _$ShareLinkResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareLinkResponse _$ShareLinkResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ShareLinkResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['url']);
      final val = ShareLinkResponse(
        url: $checkedConvert('url', (v) => v as String),
        shareText: $checkedConvert('share_text', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'shareText': 'share_text'});

Map<String, dynamic> _$ShareLinkResponseToJson(ShareLinkResponse instance) =>
    <String, dynamic>{'url': instance.url, 'share_text': ?instance.shareText};
