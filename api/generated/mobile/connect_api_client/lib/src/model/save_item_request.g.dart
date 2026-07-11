// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_item_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaveItemRequestCWProxy {
  SaveItemRequest targetType(SavedTargetType targetType);

  SaveItemRequest targetId(String targetId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveItemRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveItemRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveItemRequest call({SavedTargetType targetType, String targetId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSaveItemRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSaveItemRequest.copyWith.fieldName(...)`
class _$SaveItemRequestCWProxyImpl implements _$SaveItemRequestCWProxy {
  const _$SaveItemRequestCWProxyImpl(this._value);

  final SaveItemRequest _value;

  @override
  SaveItemRequest targetType(SavedTargetType targetType) =>
      this(targetType: targetType);

  @override
  SaveItemRequest targetId(String targetId) => this(targetId: targetId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveItemRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveItemRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveItemRequest call({
    Object? targetType = const $CopyWithPlaceholder(),
    Object? targetId = const $CopyWithPlaceholder(),
  }) {
    return SaveItemRequest(
      targetType: targetType == const $CopyWithPlaceholder()
          ? _value.targetType
          // ignore: cast_nullable_to_non_nullable
          : targetType as SavedTargetType,
      targetId: targetId == const $CopyWithPlaceholder()
          ? _value.targetId
          // ignore: cast_nullable_to_non_nullable
          : targetId as String,
    );
  }
}

extension $SaveItemRequestCopyWith on SaveItemRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSaveItemRequest.copyWith(...)` or like so:`instanceOfSaveItemRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaveItemRequestCWProxy get copyWith => _$SaveItemRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveItemRequest _$SaveItemRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SaveItemRequest',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['target_type', 'target_id']);
        final val = SaveItemRequest(
          targetType: $checkedConvert(
            'target_type',
            (v) => $enumDecode(_$SavedTargetTypeEnumMap, v),
          ),
          targetId: $checkedConvert('target_id', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'targetType': 'target_type', 'targetId': 'target_id'},
    );

Map<String, dynamic> _$SaveItemRequestToJson(SaveItemRequest instance) =>
    <String, dynamic>{
      'target_type': _$SavedTargetTypeEnumMap[instance.targetType]!,
      'target_id': instance.targetId,
    };

const _$SavedTargetTypeEnumMap = {
  SavedTargetType.profile: 'profile',
  SavedTargetType.workCard: 'work_card',
  SavedTargetType.workNeededPost: 'work_needed_post',
};
