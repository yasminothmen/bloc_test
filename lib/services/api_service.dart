import 'package:bloc_test/constants/BackendUrl.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl, 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Dio get instance {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          print('Requête envoyée: ${options.uri}');
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('Erreur Dio: ${error.message}');
        }
        return handler.next(error);
      },
    ));
    return _dio;
  }
}