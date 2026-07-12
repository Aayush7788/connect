import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const termsVersion = '2026-07-12';
const privacyVersion = '2026-07-12';

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

final connectApiProvider = Provider<ConnectApi>((ref) {
  return DioConnectApi(tokenStore: ref.watch(tokenStoreProvider));
});

abstract class TokenStore {
  Future<String?> readAccessToken();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'connect.access_token';
  static const _refreshTokenKey = 'connect.refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}

abstract class ConnectApi {
  Future<OtpRequestResult> requestOtp({required String mobile});

  Future<AuthSessionResult> verifyOtp({
    required String mobile,
    required String otp,
    required String otpRequestId,
  });

  Future<MeResult> completeBasicAccount({required String displayName});

  Future<MeResult> confirmRole({required String role});

  Future<MeResult> me();

  Future<void> logout();
}

class DioConnectApi implements ConnectApi {
  DioConnectApi({required TokenStore tokenStore})
    : _tokenStore = tokenStore,
      _dio = Dio(
        BaseOptions(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://10.0.2.2:8000/v1',
          ),
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  final TokenStore _tokenStore;
  final Dio _dio;

  @override
  Future<OtpRequestResult> requestOtp({required String mobile}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/request',
      data: {'mobile': mobile},
    );
    return OtpRequestResult.fromJson(_body(response));
  }

  @override
  Future<AuthSessionResult> verifyOtp({
    required String mobile,
    required String otp,
    required String otpRequestId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      data: {
        'mobile': mobile,
        'otp': otp,
        'otp_request_id': otpRequestId,
        'device': {'platform': 'android', 'app_version': '1.0.0'},
      },
    );
    return AuthSessionResult.fromJson(_body(response));
  }

  @override
  Future<MeResult> completeBasicAccount({required String displayName}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/account',
      data: {
        'display_name': displayName,
        'accepted_terms_version': termsVersion,
        'accepted_privacy_version': privacyVersion,
      },
      options: await _authOptions(),
    );
    return MeResult.fromJson(_body(response));
  }

  @override
  Future<MeResult> confirmRole({required String role}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/role/confirm',
      data: {'role': role},
      options: await _authOptions(),
    );
    return MeResult.fromJson(_body(response));
  }

  @override
  Future<MeResult> me() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/me',
      options: await _authOptions(),
    );
    return MeResult.fromJson(_body(response));
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<void>('/auth/logout', options: await _authOptions());
    } on DioException {
      // Local logout should still clear the device session if the network fails.
    }
  }

  Future<Options> _authOptions() async {
    final token = await _tokenStore.readAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Map<String, dynamic> _body(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data == null) {
      throw StateError('Empty server response');
    }
    return data;
  }
}

class OtpRequestResult {
  const OtpRequestResult({required this.otpRequestId, required this.message});

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) {
    return OtpRequestResult(
      otpRequestId: json['otp_request_id'] as String,
      message: json['message'] as String? ?? 'OTP sent',
    );
  }

  final String otpRequestId;
  final String message;
}

class AuthSessionResult {
  const AuthSessionResult({
    required this.accessToken,
    required this.refreshToken,
    required this.nextState,
    required this.user,
  });

  factory AuthSessionResult.fromJson(Map<String, dynamic> json) {
    return AuthSessionResult(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      nextState: json['next_state'] as String,
      user: UserSummary.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final String refreshToken;
  final String nextState;
  final UserSummary user;
}

class MeResult {
  const MeResult({
    required this.user,
    required this.nextState,
    required this.allowedActions,
    required this.unreadNotificationCount,
    this.profile,
  });

  factory MeResult.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    return MeResult(
      user: UserSummary.fromJson(json['user'] as Map<String, dynamic>),
      nextState: json['next_state'] as String,
      profile: profileJson == null
          ? null
          : ProfileSummary.fromJson(profileJson as Map<String, dynamic>),
      unreadNotificationCount: json['unread_notification_count'] as int? ?? 0,
      allowedActions: (json['allowed_actions'] as List<dynamic>? ?? [])
          .map((value) => value as String)
          .toList(growable: false),
    );
  }

  final UserSummary user;
  final String nextState;
  final ProfileSummary? profile;
  final int unreadNotificationCount;
  final List<String> allowedActions;
}

class UserSummary {
  const UserSummary({
    required this.id,
    required this.displayName,
    required this.primaryMobile,
    required this.accountStatus,
    this.role,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? '',
      primaryMobile: json['primary_mobile'] as String? ?? '',
      accountStatus: json['account_status'] as String? ?? 'active',
      role: json['role'] as String?,
    );
  }

  final String id;
  final String displayName;
  final String primaryMobile;
  final String accountStatus;
  final String? role;
}

class ProfileSummary {
  const ProfileSummary({
    required this.id,
    required this.role,
    required this.visibilityStatus,
    required this.completionScore,
    required this.verificationStatus,
    required this.isVerified,
    this.displayName,
  });

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      id: json['id'] as String,
      role: json['role'] as String,
      displayName: json['display_name'] as String?,
      visibilityStatus: json['visibility_status'] as String? ?? 'draft',
      completionScore: json['completion_score'] as int? ?? 0,
      verificationStatus:
          json['verification_status'] as String? ?? 'unverified',
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  final String id;
  final String role;
  final String? displayName;
  final String visibilityStatus;
  final int completionScore;
  final String verificationStatus;
  final bool isVerified;
}
