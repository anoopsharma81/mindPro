import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger.dart';

/// Firestore service with helper methods for common operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Get current user ID
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
  
  /// Get reference to user's profile document
  DocumentReference<Map<String, dynamic>> get profileDoc {
    final uid = currentUserId;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('profiles').doc(uid);
  }
  
  /// Get reference to user's years collection
  CollectionReference<Map<String, dynamic>> get yearsCollection {
    return profileDoc.collection('years');
  }
  
  /// Get reference to specific year's reflections
  CollectionReference<Map<String, dynamic>> reflectionsFor(String year) {
    return yearsCollection.doc(year).collection('reflections');
  }
  
  /// Get reference to specific year's CPD entries
  CollectionReference<Map<String, dynamic>> cpdFor(String year) {
    return yearsCollection.doc(year).collection('cpd');
  }
  
  /// Create or update a document
  Future<void> setDocument(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      await ref.set(data, SetOptions(merge: merge));
    } catch (e, stack) {
      Logger.error('Failed to set document: ${ref.path}', e, stack);
      rethrow;
    }
  }
  
  /// Update specific fields in a document
  Future<void> updateDocument(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) async {
    try {
      await ref.update(data);
    } catch (e, stack) {
      Logger.error('Failed to update document: ${ref.path}', e, stack);
      rethrow;
    }
  }
  
  /// Delete a document
  Future<void> deleteDocument(DocumentReference<Map<String, dynamic>> ref) async {
    try {
      await ref.delete();
    } catch (e, stack) {
      Logger.error('Failed to delete document: ${ref.path}', e, stack);
      rethrow;
    }
  }
  
  /// Get a document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      return await ref.get();
    } catch (e, stack) {
      Logger.error('Failed to get document: ${ref.path}', e, stack);
      rethrow;
    }
  }
  
  /// Query a collection
  Future<QuerySnapshot<Map<String, dynamic>>> queryCollection(
    Query<Map<String, dynamic>> query,
  ) async {
    try {
      return await query.get();
    } catch (e, stack) {
      Logger.error('Failed to query collection', e, stack);
      rethrow;
    }
  }
  
  /// Enable offline persistence (call once during app initialization)
  Future<void> enableOfflinePersistence() async {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e, stack) {
      Logger.error('Failed to enable offline persistence', e, stack);
    }
  }
}


