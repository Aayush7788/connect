// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SavedItemCWProxy {
  SavedItem id(String id);

  SavedItem targetType(SavedTargetType targetType);

  SavedItem targetId(String targetId);

  SavedItem card(SearchResult? card);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SavedItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SavedItem(...).copyWith(id: 12, name: "My name")
  /// ````
  SavedItem call({
    String id,
    SavedTargetType targetType,
    String targetId,
    SearchResult? card,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSavedItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSavedItem.copyWith.fieldName(...)`
class _$SavedItemCWProxyImpl implements _$SavedItemCWProxy {
  const _$SavedItemCWProxyImpl(this._value);

  final SavedItem _value;

  @override
  SavedItem id(String id) => this(id: id);

  @override
  SavedItem targetType(SavedTargetType targetType) =>
      this(targetType: targetType);

  @override
  SavedItem targetId(String targetId) => this(targetId: targetId);

  @override
  SavedItem card(SearchResult? card) => this(card: card);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SavedItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SavedItem(...).copyWith(id: 12, name: "My name")
  /// ````
  SavedItem call({
    Object? id = const $CopyWithPlaceholder(),
    Object? targetType = const $CopyWithPlaceholder(),
    Object? targetId = const $CopyWithPlaceholder(),
    Object? card = const $CopyWithPlaceholder(),
  }) {
    return SavedItem(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      targetType: targetType == const $CopyWithPlaceholder()
          ? _value.targetType
          // ignore: cast_nullable_to_non_nullable
          : targetType as SavedTargetType,
      targetId: targetId == const $CopyWithPlaceholder()
          ? _value.targetId
          // ignore: cast_nullable_to_non_nullable
          : targetId as String,
      card: card == const $CopyWithPlaceholder()
          ? _value.card
          // ignore: cast_nullable_to_non_nullable
          : card as SearchResult?,
    );
  }
}

extension $SavedItemCopyWith on SavedItem {
  /// Returns a callable class that can be used as follows: `instanceOfSavedItem.copyWith(...)` or like so:`instanceOfSavedItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SavedItemCWProxy get copyWith => _$SavedItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedItem _$SavedItemFromJson(Map<String, dynamic> json) => $checkedCreate(
  'SavedItem',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['id', 'target_type', 'target_id']);
    final val = SavedItem(
      id: $checkedConvert('id', (v) => v as String),
      targetType: $checkedConvert(
        'target_type',
        (v) => $enumDecode(_$SavedTargetTypeEnumMap, v),
      ),
      targetId: $checkedConvert('target_id', (v) => v as String),
      card: $checkedConvert(
        'card',
        (v) =>
            v == null ? null : SearchResult.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'targetType': 'target_type', 'targetId': 'target_id'},
);

Map<String, dynamic> _$SavedItemToJson(SavedItem instance) => <String, dynamic>{
  'id': instance.id,
  'target_type': _$SavedTargetTypeEnumMap[instance.targetType]!,
  'target_id': instance.targetId,
  'card': ?instance.card?.toJson(),
};

const _$SavedTargetTypeEnumMap = {
  SavedTargetType.profile: 'profile',
  SavedTargetType.workCard: 'work_card',
  SavedTargetType.workNeededPost: 'work_needed_post',
};
