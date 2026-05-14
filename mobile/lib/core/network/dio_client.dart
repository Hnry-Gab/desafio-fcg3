import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env_config.dart';
import 'api_interceptor.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;
  late final Dio _refreshDio;

  DioClient({required FlutterSecureStorage storage}) {
    _refreshDio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConfig.requestTimeoutMs),
    ));

    dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConfig.requestTimeoutMs),
      // Do NOT set a default Content-Type header here.
      // Dio auto-sets 'application/json' for Map/List data and
      // 'multipart/form-data' for FormData. A hardcoded default
      // can interfere with multipart file uploads.
      contentType: Headers.jsonContentType,
    ));

    dio.interceptors.addAll([
      AuthInterceptor(storage: storage, refreshDio: _refreshDio),
      ApiInterceptor(),
    ]);
  }
}
