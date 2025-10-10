import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/logger.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
