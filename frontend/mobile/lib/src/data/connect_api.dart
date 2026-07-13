import 'dart:typed_data';

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

  Future<OwnerProfileResult> ownerProfile();

  Future<OwnerProfileResult> updateOwnerProfile(Map<String, dynamic> fields);

  Future<OwnerProfileResult> completeOwnerProfile();

  Future<OwnerProfileResult> hideOwnerProfile();

  Future<OwnerProfileResult> showOwnerProfile();

  Future<List<CategoryOption>> categories({required String categoryType});

  Future<UploadIntentResult> createMediaUploadIntent(
    MediaUploadIntentRequest request,
  );

  Future<UploadIntentResult> retryMediaUpload(String mediaAssetId);

  Future<MediaAssetResult> completeMediaUpload(String mediaAssetId);

  Future<void> cancelMediaUpload(String mediaAssetId);

  Future<void> deleteMedia(String mediaAssetId);

  Future<void> uploadMediaBytes({
    required UploadDetailsResult upload,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required ProgressCallback onProgress,
    required CancelToken cancelToken,
  });

  Future<void> logout();
}

class DioConnectApi implements ConnectApi {
  DioConnectApi({required TokenStore tokenStore, Dio? storageDio})
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
      ),
      _storageDio =
          storageDio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 60),
            ),
          );

  final TokenStore _tokenStore;
  final Dio _dio;
  final Dio _storageDio;

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
  Future<OwnerProfileResult> ownerProfile() {
    return _profileRequest(() async {
      return _dio.get<Map<String, dynamic>>(
        '/me/profile',
        options: await _authOptions(),
      );
    });
  }

  @override
  Future<OwnerProfileResult> updateOwnerProfile(Map<String, dynamic> fields) {
    return _profileRequest(() async {
      return _dio.patch<Map<String, dynamic>>(
        '/me/profile',
        data: fields,
        options: await _authOptions(),
      );
    });
  }

  @override
  Future<OwnerProfileResult> completeOwnerProfile() {
    return _profileRequest(() async {
      return _dio.post<Map<String, dynamic>>(
        '/me/profile/complete',
        options: await _authOptions(),
      );
    });
  }

  @override
  Future<OwnerProfileResult> hideOwnerProfile() {
    return _profileRequest(() async {
      return _dio.post<Map<String, dynamic>>(
        '/me/profile/hide',
        options: await _authOptions(),
      );
    });
  }

  @override
  Future<OwnerProfileResult> showOwnerProfile() {
    return _profileRequest(() async {
      return _dio.post<Map<String, dynamic>>(
        '/me/profile/show',
        options: await _authOptions(),
      );
    });
  }

  @override
  Future<List<CategoryOption>> categories({
    required String categoryType,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/taxonomy/categories',
        queryParameters: {'category_type': categoryType},
        options: await _authOptions(),
      );
      final items = _body(response)['items'] as List<dynamic>? ?? [];
      return items
          .map((item) => CategoryOption.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<UploadIntentResult> createMediaUploadIntent(
    MediaUploadIntentRequest request,
  ) {
    return _mediaRequest(() async {
      return _dio.post<Map<String, dynamic>>(
        '/media/upload-intent',
        data: request.toJson(),
        options: await _authOptions(),
      );
    }).then(UploadIntentResult.fromJson);
  }

  @override
  Future<UploadIntentResult> retryMediaUpload(String mediaAssetId) {
    return _mediaRequest(() async {
      return _dio.post<Map<String, dynamic>>(
        '/media/$mediaAssetId/retry',
        options: await _authOptions(),
      );
    }).then(UploadIntentResult.fromJson);
  }

  @override
  Future<MediaAssetResult> completeMediaUpload(String mediaAssetId) {
    return _mediaRequest(() async {
      return _dio.post<Map<String, dynamic>>(
        '/media/$mediaAssetId/complete',
        options: await _authOptions(),
      );
    }).then(MediaAssetResult.fromJson);
  }

  @override
  Future<void> cancelMediaUpload(String mediaAssetId) async {
    try {
      await _dio.post<void>(
        '/media/$mediaAssetId/cancel',
        options: await _authOptions(),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> deleteMedia(String mediaAssetId) async {
    try {
      await _dio.delete<void>(
        '/media/$mediaAssetId',
        options: await _authOptions(),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> uploadMediaBytes({
    required UploadDetailsResult upload,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required ProgressCallback onProgress,
    required CancelToken cancelToken,
  }) async {
    try {
      final form = FormData.fromMap({
        upload.formField: MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: DioMediaType.parse(mimeType),
        ),
      });
      await _storageDio.put<void>(
        upload.url,
        data: form,
        options: Options(
          headers: upload.headers,
          contentType: Headers.multipartFormDataContentType,
        ),
        onSendProgress: onProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        rethrow;
      }
      throw const ApiFailure(
        code: 'upload_failed',
        message: 'Unable to upload, please retry',
      );
    }
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

  Future<OwnerProfileResult> _profileRequest(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      return OwnerProfileResult.fromJson(_body(response));
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> _mediaRequest(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      return _body(await request());
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

class ApiFailure implements Exception {
  const ApiFailure({
    required this.code,
    required this.message,
    this.fieldErrors = const {},
    this.missingFields = const [],
  });

  factory ApiFailure.fromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final errorBody = data['error'];
      if (errorBody is Map<String, dynamic>) {
        final details = errorBody['details'];
        final fieldErrors = errorBody['field_errors'];
        return ApiFailure(
          code: errorBody['code'] as String? ?? 'request_failed',
          message: errorBody['message'] as String? ?? 'Something went wrong.',
          fieldErrors: fieldErrors is Map<String, dynamic>
              ? fieldErrors.map((key, value) => MapEntry(key, value.toString()))
              : const {},
          missingFields: details is Map<String, dynamic>
              ? (details['missing_fields'] as List<dynamic>? ?? [])
                    .map((value) => value.toString())
                    .toList(growable: false)
              : const [],
        );
      }
    }
    return const ApiFailure(
      code: 'network_error',
      message: "Can't access internet",
    );
  }

  final String code;
  final String message;
  final Map<String, String> fieldErrors;
  final List<String> missingFields;
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

  MeResult withProfile(ProfileSummary updatedProfile) {
    return MeResult(
      user: user,
      nextState: nextState,
      profile: updatedProfile,
      unreadNotificationCount: unreadNotificationCount,
      allowedActions: allowedActions,
    );
  }
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
    this.completionFlags = const {},
    this.reverificationRequired = false,
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
      completionFlags: (json['completion_flags'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, value == true)),
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
  final Map<String, bool> completionFlags;
  final bool reverificationRequired;
}

class OwnerProfileResult {
  const OwnerProfileResult({
    required this.profile,
    required this.editableFields,
    required this.lockedFields,
    required this.roleSpecific,
    this.media = const [],
  });

  factory OwnerProfileResult.fromJson(Map<String, dynamic> json) {
    return OwnerProfileResult(
      profile: ProfileSummary.fromJson(json['profile'] as Map<String, dynamic>),
      editableFields: (json['editable_fields'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(growable: false),
      lockedFields: (json['locked_fields'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(growable: false),
      roleSpecific: Map<String, dynamic>.from(
        json['role_specific'] as Map<String, dynamic>? ?? {},
      ),
      media: (json['media'] as List<dynamic>? ?? [])
          .map(
            (value) => MediaAssetResult.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  final ProfileSummary profile;
  final List<String> editableFields;
  final List<String> lockedFields;
  final Map<String, dynamic> roleSpecific;
  final List<MediaAssetResult> media;
}

class MediaUploadIntentRequest {
  const MediaUploadIntentRequest({
    required this.entityType,
    required this.entityId,
    required this.mediaKind,
    required this.visibility,
    required this.documentType,
    required this.filename,
    required this.mimeType,
    required this.byteSize,
  });

  final String entityType;
  final String entityId;
  final String mediaKind;
  final String visibility;
  final String documentType;
  final String filename;
  final String mimeType;
  final int byteSize;

  Map<String, dynamic> toJson() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'media_kind': mediaKind,
      'visibility': visibility,
      'document_type': documentType,
      'filename': filename,
      'mime_type': mimeType,
      'byte_size': byteSize,
    };
  }
}

class UploadIntentResult {
  const UploadIntentResult({required this.mediaAsset, required this.upload});

  factory UploadIntentResult.fromJson(Map<String, dynamic> json) {
    return UploadIntentResult(
      mediaAsset: MediaAssetResult.fromJson(
        json['media_asset'] as Map<String, dynamic>,
      ),
      upload: UploadDetailsResult.fromJson(
        json['upload'] as Map<String, dynamic>,
      ),
    );
  }

  final MediaAssetResult mediaAsset;
  final UploadDetailsResult upload;
}

class UploadDetailsResult {
  const UploadDetailsResult({
    required this.url,
    required this.formField,
    required this.headers,
    required this.expiresAt,
  });

  factory UploadDetailsResult.fromJson(Map<String, dynamic> json) {
    return UploadDetailsResult(
      url: json['url'] as String,
      formField: json['form_field'] as String? ?? 'file',
      headers: (json['headers'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  final String url;
  final String formField;
  final Map<String, String> headers;
  final DateTime expiresAt;
}

class MediaAssetResult {
  const MediaAssetResult({
    required this.id,
    required this.mediaKind,
    required this.visibility,
    required this.uploadStatus,
    required this.sortOrder,
    this.url,
    this.thumbnailUrl,
    this.documentType,
    this.safeDisplayName,
  });

  factory MediaAssetResult.fromJson(Map<String, dynamic> json) {
    return MediaAssetResult(
      id: json['id'] as String,
      mediaKind: json['media_kind'] as String,
      visibility: json['visibility'] as String,
      uploadStatus: json['upload_status'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      documentType: json['document_type'] as String?,
      safeDisplayName: json['safe_display_name'] as String?,
    );
  }

  final String id;
  final String mediaKind;
  final String visibility;
  final String uploadStatus;
  final int sortOrder;
  final String? url;
  final String? thumbnailUrl;
  final String? documentType;
  final String? safeDisplayName;
}

class CategoryOption {
  const CategoryOption({
    required this.id,
    required this.categoryType,
    required this.name,
    this.parentId,
  });

  factory CategoryOption.fromJson(Map<String, dynamic> json) {
    return CategoryOption(
      id: json['id'] as String,
      parentId: json['parent_id'] as String?,
      categoryType: json['category_type'] as String,
      name: json['name'] as String,
    );
  }

  final String id;
  final String? parentId;
  final String categoryType;
  final String name;
}
