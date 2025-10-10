import 'package:flutter/foundation.dart';
import 'env.dart';

/// Simple logger utility for the Metanoia app
/// Logs are printed in debug mode and can be sent to Sentry in production
class Logger {
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode || Env.isDev) {
      debugPrint('[DEBUG] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
  
  static void info(String message) {
    if (kDebugMode || Env.isDev) {
      debugPrint('[INFO] $message');
    }
  }
  
  static void warning(String message, [Object? error]) {
    debugPrint('[WARNING] $message');
    if (error != null) debugPrint('Error: $error');
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    
    // TODO: Send to Sentry in production
    // if (Env.isProd && Env.sentryDsn.isNotEmpty) {
    //   Sentry.captureException(error, stackTrace: stackTrace);
    // }
  }
}


