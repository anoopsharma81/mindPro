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
      baseUrl: Env.getApiUrl(),
      connectTimeout: const Duration(seconds: 30), // 30 seconds for connection
      receiveTimeout: const Duration(seconds: 600), // 10 minutes for AI processing (Whisper can be slow)
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Connection': 'keep-alive', // Use keep-alive for better connection management
      },
      // Disable persistent connections which might cause issues
      persistentConnection: false,
    ));
    
    // Request interceptor - add auth token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              Logger.debug('Added auth token to request');
            } else {
              Logger.warning('User has no token, request may fail');
            }
          } else {
            Logger.warning('No current user, request may fail');
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






