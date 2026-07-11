//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

// ignore: unused_import
import 'dart:convert';
import 'package:connect_api_client/src/deserialize.dart';
import 'package:dio/dio.dart';

import 'package:connect_api_client/src/model/error_response.dart';
import 'package:connect_api_client/src/model/search_response.dart';
import 'package:connect_api_client/src/model/search_target.dart';

class SearchApi {

  final Dio _dio;

  const SearchApi(this._dio);

  /// Search marketplace objects
  /// 
  ///
  /// Parameters:
  /// * [target] 
  /// * [q] 
  /// * [businessMode] 
  /// * [categoryId] 
  /// * [productTypeId] 
  /// * [locality] 
  /// * [verifiedOnly] 
  /// * [sort] 
  /// * [cursor] 
  /// * [limit] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SearchResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SearchResponse>> searchMarketplace({ 
    required SearchTarget target,
    String? q,
    String? businessMode,
    String? categoryId,
    String? productTypeId,
    String? locality,
    bool? verifiedOnly,
    String? sort,
    String? cursor,
    int? limit = 20,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/search';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      r'target': target,
      if (q != null) r'q': q,
      if (businessMode != null) r'business_mode': businessMode,
      if (categoryId != null) r'category_id': categoryId,
      if (productTypeId != null) r'product_type_id': productTypeId,
      if (locality != null) r'locality': locality,
      if (verifiedOnly != null) r'verified_only': verifiedOnly,
      if (sort != null) r'sort': sort,
      if (cursor != null) r'cursor': cursor,
      if (limit != null) r'limit': limit,
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SearchResponse? _responseData;

    try {
final rawData = _response.data;
_responseData = rawData == null ? null : deserialize<SearchResponse, SearchResponse>(rawData, 'SearchResponse', growable: true);

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SearchResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}
