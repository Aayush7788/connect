// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AuthSessionResponseCWProxy {
  AuthSessionResponse accessToken(String accessToken);

  AuthSessionResponse refreshToken(String refreshToken);

  AuthSessionResponse nextState(AuthSessionResponseNextStateEnum nextState);

  AuthSessionResponse user(User? user);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuthSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuthSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AuthSessionResponse call({
    String accessToken,
    String refreshToken,
    AuthSessionResponseNextStateEnum nextState,
    User? user,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAuthSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAuthSessionResponse.copyWith.fieldName(...)`
class _$AuthSessionResponseCWProxyImpl implements _$AuthSessionResponseCWProxy {
  const _$AuthSessionResponseCWProxyImpl(this._value);

  final AuthSessionResponse _value;

  @override
  AuthSessionResponse accessToken(String accessToken) =>
      this(accessToken: accessToken);

  @override
  AuthSessionResponse refreshToken(String refreshToken) =>
      this(refreshToken: refreshToken);

  @override
  AuthSessionResponse nextState(AuthSessionResponseNextStateEnum nextState) =>
      this(nextState: nextState);

  @override
  AuthSessionResponse user(User? user) => this(user: user);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuthSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuthSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AuthSessionResponse call({
    Object? accessToken = const $CopyWithPlaceholder(),
    Object? refreshToken = const $CopyWithPlaceholder(),
    Object? nextState = const $CopyWithPlaceholder(),
    Object? user = const $CopyWithPlaceholder(),
  }) {
    return AuthSessionResponse(
      accessToken: accessToken == const $CopyWithPlaceholder()
          ? _value.accessToken
          // ignore: cast_nullable_to_non_nullable
          : accessToken as String,
      refreshToken: refreshToken == const $CopyWithPlaceholder()
          ? _value.refreshToken
          // ignore: cast_nullable_to_non_nullable
          : refreshToken as String,
      nextState: nextState == const $CopyWithPlaceholder()
          ? _value.nextState
          // ignore: cast_nullable_to_non_nullable
          : nextState as AuthSessionResponseNextStateEnum,
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as User?,
    );
  }
}

extension $AuthSessionResponseCopyWith on AuthSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAuthSessionResponse.copyWith(...)` or like so:`instanceOfAuthSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AuthSessionResponseCWProxy get copyWith =>
      _$AuthSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthSessionResponse _$AuthSessionResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AuthSessionResponse',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['access_token', 'refresh_token', 'next_state'],
        );
        final val = AuthSessionResponse(
          accessToken: $checkedConvert('access_token', (v) => v as String),
          refreshToken: $checkedConvert('refresh_token', (v) => v as String),
          nextState: $checkedConvert(
            'next_state',
            (v) => $enumDecode(_$AuthSessionResponseNextStateEnumEnumMap, v),
          ),
          user: $checkedConvert(
            'user',
            (v) => v == null ? null : User.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'accessToken': 'access_token',
        'refreshToken': 'refresh_token',
        'nextState': 'next_state',
      },
    );

Map<String, dynamic> _$AuthSessionResponseToJson(
  AuthSessionResponse instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'next_state': _$AuthSessionResponseNextStateEnumEnumMap[instance.nextState]!,
  'user': ?instance.user?.toJson(),
};

const _$AuthSessionResponseNextStateEnumEnumMap = {
  AuthSessionResponseNextStateEnum.completeBasicAccount:
      'complete_basic_account',
  AuthSessionResponseNextStateEnum.roleSelectionRequired:
      'role_selection_required',
  AuthSessionResponseNextStateEnum.home: 'home',
  AuthSessionResponseNextStateEnum.accountBlocked: 'account_blocked',
};
