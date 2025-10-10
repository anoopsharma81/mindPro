import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'env.dart';
import 'logger.dart';

/// HTTP client configured with Firebase Auth interceptor
class HttpClient {
  static Dio? _instance;
  
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }
  
  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Request interceptor - add auth token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
        } catch (e, stack) {
          Logger.error('Failed to get auth token', e, stack);
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.debug('API Response: ${response.requestOptions.path} - ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        Logger.error(
          'API Error: ${error.requestOptions.path} - ${error.response?.statusCode}',
          error,
          error.stackTrace,
        );
        return handler.next(error);
      },
    ));
    
    return dio;
  }
  
  /// Reset the instance (useful for testing or environment switches)
  static void reset() {
    _instance = null;
  }
}


