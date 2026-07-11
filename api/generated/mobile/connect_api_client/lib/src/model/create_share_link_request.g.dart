// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_share_link_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateShareLinkRequestCWProxy {
  CreateShareLinkRequest targetType(
    CreateShareLinkRequestTargetTypeEnum targetType,
  );

  CreateShareLinkRequest targetId(String targetId);

  CreateShareLinkRequest channel(CreateShareLinkRequestChannelEnum? channel);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateShareLinkRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateShareLinkRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateShareLinkRequest call({
    CreateShareLinkRequestTargetTypeEnum targetType,
    String targetId,
    CreateShareLinkRequestChannelEnum? channel,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateShareLinkRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateShareLinkRequest.copyWith.fieldName(...)`
class _$CreateShareLinkRequestCWProxyImpl
    implements _$CreateShareLinkRequestCWProxy {
  const _$CreateShareLinkRequestCWProxyImpl(this._value);

  final CreateShareLinkRequest _value;

  @override
  CreateShareLinkRequest targetType(
    CreateShareLinkRequestTargetTypeEnum targetType,
  ) => this(targetType: targetType);

  @override
  CreateShareLinkRequest targetId(String targetId) => this(targetId: targetId);

  @override
  CreateShareLinkRequest channel(CreateShareLinkRequestChannelEnum? channel) =>
      this(channel: channel);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateShareLinkRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateShareLinkRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateShareLinkRequest call({
    Object? targetType = const $CopyWithPlaceholder(),
    Object? targetId = const $CopyWithPlaceholder(),
    Object? channel = const $CopyWithPlaceholder(),
  }) {
    return CreateShareLinkRequest(
      targetType: targetType == const $CopyWithPlaceholder()
          ? _value.targetType
          // ignore: cast_nullable_to_non_nullable
          : targetType as CreateShareLinkRequestTargetTypeEnum,
      targetId: targetId == const $CopyWithPlaceholder()
          ? _value.targetId
          // ignore: cast_nullable_to_non_nullable
          : targetId as String,
      channel: channel == const $CopyWithPlaceholder()
          ? _value.channel
          // ignore: cast_nullable_to_non_nullable
          : channel as CreateShareLinkRequestChannelEnum?,
    );
  }
}

extension $CreateShareLinkRequestCopyWith on CreateShareLinkRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateShareLinkRequest.copyWith(...)` or like so:`instanceOfCreateShareLinkRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateShareLinkRequestCWProxy get copyWith =>
      _$CreateShareLinkRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateShareLinkRequest _$CreateShareLinkRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateShareLinkRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['target_type', 'target_id']);
    final val = CreateShareLinkRequest(
      targetType: $checkedConvert(
        'target_type',
        (v) => $enumDecode(_$CreateShareLinkRequestTargetTypeEnumEnumMap, v),
      ),
      targetId: $checkedConvert('target_id', (v) => v as String),
      channel: $checkedConvert(
        'channel',
        (v) =>
            $enumDecodeNullable(_$CreateShareLinkRequestChannelEnumEnumMap, v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'targetType': 'target_type', 'targetId': 'target_id'},
);

Map<String, dynamic> _$CreateShareLinkRequestToJson(
  CreateShareLinkRequest instance,
) => <String, dynamic>{
  'target_type':
      _$CreateShareLinkRequestTargetTypeEnumEnumMap[instance.targetType]!,
  'target_id': instance.targetId,
  'channel': ?_$CreateShareLinkRequestChannelEnumEnumMap[instance.channel],
};

const _$CreateShareLinkRequestTargetTypeEnumEnumMap = {
  CreateShareLinkRequestTargetTypeEnum.profile: 'profile',
  CreateShareLinkRequestTargetTypeEnum.workCard: 'work_card',
  CreateShareLinkRequestTargetTypeEnum.workNeededPost: 'work_needed_post',
};

const _$CreateShareLinkRequestChannelEnumEnumMap = {
  CreateShareLinkRequestChannelEnum.copyLink: 'copy_link',
  CreateShareLinkRequestChannelEnum.whatsapp: 'whatsapp',
  CreateShareLinkRequestChannelEnum.sms: 'sms',
  CreateShareLinkRequestChannelEnum.x: 'x',
  CreateShareLinkRequestChannelEnum.email: 'email',
  CreateShareLinkRequestChannelEnum.linkedin: 'linkedin',
  CreateShareLinkRequestChannelEnum.nativeOther: 'native_other',
};
