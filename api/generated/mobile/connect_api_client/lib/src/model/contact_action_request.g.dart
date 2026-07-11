// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_action_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ContactActionRequestCWProxy {
  ContactActionRequest profileId(String profileId);

  ContactActionRequest actionType(
    ContactActionRequestActionTypeEnum actionType,
  );

  ContactActionRequest sourceType(
    ContactActionRequestSourceTypeEnum? sourceType,
  );

  ContactActionRequest sourceId(String? sourceId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ContactActionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ContactActionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ContactActionRequest call({
    String profileId,
    ContactActionRequestActionTypeEnum actionType,
    ContactActionRequestSourceTypeEnum? sourceType,
    String? sourceId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfContactActionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfContactActionRequest.copyWith.fieldName(...)`
class _$ContactActionRequestCWProxyImpl
    implements _$ContactActionRequestCWProxy {
  const _$ContactActionRequestCWProxyImpl(this._value);

  final ContactActionRequest _value;

  @override
  ContactActionRequest profileId(String profileId) =>
      this(profileId: profileId);

  @override
  ContactActionRequest actionType(
    ContactActionRequestActionTypeEnum actionType,
  ) => this(actionType: actionType);

  @override
  ContactActionRequest sourceType(
    ContactActionRequestSourceTypeEnum? sourceType,
  ) => this(sourceType: sourceType);

  @override
  ContactActionRequest sourceId(String? sourceId) => this(sourceId: sourceId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ContactActionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ContactActionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ContactActionRequest call({
    Object? profileId = const $CopyWithPlaceholder(),
    Object? actionType = const $CopyWithPlaceholder(),
    Object? sourceType = const $CopyWithPlaceholder(),
    Object? sourceId = const $CopyWithPlaceholder(),
  }) {
    return ContactActionRequest(
      profileId: profileId == const $CopyWithPlaceholder()
          ? _value.profileId
          // ignore: cast_nullable_to_non_nullable
          : profileId as String,
      actionType: actionType == const $CopyWithPlaceholder()
          ? _value.actionType
          // ignore: cast_nullable_to_non_nullable
          : actionType as ContactActionRequestActionTypeEnum,
      sourceType: sourceType == const $CopyWithPlaceholder()
          ? _value.sourceType
          // ignore: cast_nullable_to_non_nullable
          : sourceType as ContactActionRequestSourceTypeEnum?,
      sourceId: sourceId == const $CopyWithPlaceholder()
          ? _value.sourceId
          // ignore: cast_nullable_to_non_nullable
          : sourceId as String?,
    );
  }
}

extension $ContactActionRequestCopyWith on ContactActionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfContactActionRequest.copyWith(...)` or like so:`instanceOfContactActionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ContactActionRequestCWProxy get copyWith =>
      _$ContactActionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactActionRequest _$ContactActionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ContactActionRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['profile_id', 'action_type']);
    final val = ContactActionRequest(
      profileId: $checkedConvert('profile_id', (v) => v as String),
      actionType: $checkedConvert(
        'action_type',
        (v) => $enumDecode(_$ContactActionRequestActionTypeEnumEnumMap, v),
      ),
      sourceType: $checkedConvert(
        'source_type',
        (v) =>
            $enumDecodeNullable(_$ContactActionRequestSourceTypeEnumEnumMap, v),
      ),
      sourceId: $checkedConvert('source_id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'profileId': 'profile_id',
    'actionType': 'action_type',
    'sourceType': 'source_type',
    'sourceId': 'source_id',
  },
);

Map<String, dynamic> _$ContactActionRequestToJson(
  ContactActionRequest instance,
) => <String, dynamic>{
  'profile_id': instance.profileId,
  'action_type':
      _$ContactActionRequestActionTypeEnumEnumMap[instance.actionType]!,
  'source_type':
      ?_$ContactActionRequestSourceTypeEnumEnumMap[instance.sourceType],
  'source_id': ?instance.sourceId,
};

const _$ContactActionRequestActionTypeEnumEnumMap = {
  ContactActionRequestActionTypeEnum.call: 'call',
  ContactActionRequestActionTypeEnum.whatsapp: 'whatsapp',
  ContactActionRequestActionTypeEnum.address: 'address',
};

const _$ContactActionRequestSourceTypeEnumEnumMap = {
  ContactActionRequestSourceTypeEnum.profile: 'profile',
  ContactActionRequestSourceTypeEnum.workCard: 'work_card',
  ContactActionRequestSourceTypeEnum.workNeededPost: 'work_needed_post',
};
