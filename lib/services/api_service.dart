import '../constants/BackendUrl.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    validateStatus: (status) =>
        status! < 500, // Accepte les codes < 500 comme valides
  ));

  static Dio get instance {
    _dio.interceptors.clear(); // Nettoyer les intercepteurs existants
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('┌───────────────────────────────────────────────────────');
            print('│ [API REQUEST] ${options.method} ${options.uri}');
            print('│ Headers: ${options.headers}');
            if (options.queryParameters.isNotEmpty) {
              print('│ Query Parameters: ${options.queryParameters}');
            }
            if (options.data != null) {
              print('│ Body: ${options.data}');
            }
            print('└───────────────────────────────────────────────────────');
          }

          return handler.next(options);
        } catch (e) {
          if (kDebugMode) {
            print('│ [AUTH ERROR] $e');
            print('└───────────────────────────────────────────────────────');
          }
          return handler.reject(DioException(
            requestOptions: options,
            error: 'Authentication failed',
          ));
        }
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('┌───────────────────────────────────────────────────────');
          print(
              '│ [API RESPONSE] ${response.requestOptions.method} ${response.requestOptions.uri}');
          print('│ Status: ${response.statusCode}');
          print('│ Data: ${response.data}');
          print('└───────────────────────────────────────────────────────');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('┌───────────────────────────────────────────────────────');
          print(
              '│ [API ERROR] ${error.requestOptions.method} ${error.requestOptions.uri}');
          print('│ Error: ${error.message}');
          print('│ Response: ${error.response?.data}');
          print('│ Status: ${error.response?.statusCode}');
          print('└───────────────────────────────────────────────────────');
        }
        return handler.next(error);
      },
    ));
    return _dio;
  }

  static Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await instance.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? e.message);
      } else {
        throw Exception(e.message ?? 'Network error occurred');
      }
    }
  }

  static Future<Response> post(String path, dynamic data) async {
    try {
      return await instance.post(
        path,
        data: data,
        options: Options(
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? e.message);
      } else {
        throw Exception(e.message ?? 'Network error occurred');
      }
    }
  }

  static Future<void> download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final fullUrl = url.startsWith('http') ? url : '$baseUrl$url';

      await instance.download(
        fullUrl,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? e.message);
      } else {
        throw Exception(e.message ?? 'Download failed');
      }
    }
  }
static Future<Uint8List?> getProfileImage(String email) async {
  try {
    final response = await instance.get(
      '/api/user/$email/profile-image',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  } catch (e) {
    debugPrint('Error fetching profile image: $e');
    return null;
  }
}



 
}
