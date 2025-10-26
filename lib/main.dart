import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/logger.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add error handler to suppress known harmless errors (e.g., Google Sign-In on web during hot reload)
  FlutterError.onError = (FlutterErrorDetails details) {
    // Filter out known harmless errors
    final error = details.exception.toString();
    if (error.contains('Future already completed') && 
        (error.contains('google_identity_services_web') || error.contains('js_loader'))) {
      // This is a known issue with Google Sign-In on web during hot reload - safe to ignore
      if (kDebugMode) {
        debugPrint('Suppressed harmless error: ${details.exception}');
      }
      return;
    }
    
    // For all other errors, log them
    FlutterError.presentError(details);
    Logger.error('Flutter error', details.exception, details.stack);
  };
  
  // Handle errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    // Filter out known harmless errors
    final errorStr = error.toString();
    if (errorStr.contains('Future already completed') && 
        (errorStr.contains('google_identity_services_web') || errorStr.contains('js_loader'))) {
      // This is a known issue with Google Sign-In on web during hot reload - safe to ignore
      if (kDebugMode) {
        debugPrint('Suppressed harmless platform error: $error');
      }
      return true; // Mark as handled
    }
    
    Logger.error('Platform error', error, stack);
    return true;
  };
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Logger.info('Firebase initialized');
    
    // Enable Firestore offline persistence
    final firestoreService = FirestoreService();
    await firestoreService.enableOfflinePersistence();
    Logger.info('Firestore offline persistence enabled');
    
    // Initialize Hive (for backward compatibility during migration)
    await Hive.initFlutter();
    Logger.info('Hive initialized');
  } catch (e, stack) {
    Logger.error('Initialization failed', e, stack);
  }
  
  runApp(const ProviderScope(child: MetanoiaApp()));
}
