import '../../services/firestore_service.dart';
import '../../core/logger.dart';
import 'profile_model.dart';

/// Repository for user profile and year configuration
class ProfileRepository {
  final FirestoreService _firestore = FirestoreService();
  
  /// Get user profile
  Future<Profile?> getProfile() async {
    try {
      final uid = _firestore.currentUserId;
      if (uid == null) return null;
      
      final doc = await _firestore.getDocument(_firestore.profileDoc);
      
      if (!doc.exists) return null;
      
      return Profile.fromJson(uid, doc.data()!);
    } catch (e, stack) {
      Logger.error('Failed to get profile', e, stack);
      return null;
    }
  }
  
  /// Create or update profile
  Future<void> saveProfile(Profile profile) async {
    try {
      await _firestore.setDocument(
        _firestore.profileDoc,
        profile.toJson(),
        merge: true,
      );
    } catch (e, stack) {
      Logger.error('Failed to save profile', e, stack);
      rethrow;
    }
  }
  
  /// Get year configuration
  Future<YearConfig?> getYearConfig(String year) async {
    try {
      final doc = await _firestore.getDocument(
        _firestore.yearsCollection.doc(year),
      );
      
      if (!doc.exists) return null;
      
      return YearConfig.fromJson(year, doc.data()!);
    } catch (e, stack) {
      Logger.error('Failed to get year config for $year', e, stack);
      return null;
    }
  }
  
  /// Save year configuration
  Future<void> saveYearConfig(YearConfig yearConfig) async {
    try {
      await _firestore.setDocument(
        _firestore.yearsCollection.doc(yearConfig.year),
        yearConfig.toJson(),
        merge: true,
      );
    } catch (e, stack) {
      Logger.error('Failed to save year config', e, stack);
      rethrow;
    }
  }
  
  /// List all configured years
  Future<List<String>> listYears() async {
    try {
      final snapshot = await _firestore.queryCollection(
        _firestore.yearsCollection.orderBy('specialty'),
      );
      
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e, stack) {
      Logger.error('Failed to list years', e, stack);
      return [];
    }
  }
  
  /// Delete year configuration and all associated data
  Future<void> deleteYear(String year) async {
    try {
      // Delete year document
      await _firestore.deleteDocument(
        _firestore.yearsCollection.doc(year),
      );
      
      // Delete all reflections for this year
      final reflections = await _firestore.queryCollection(
        _firestore.reflectionsFor(year),
      );
      for (final doc in reflections.docs) {
        await _firestore.deleteDocument(doc.reference);
      }
      
      // Delete all CPD entries for this year
      final cpdEntries = await _firestore.queryCollection(
        _firestore.cpdFor(year),
      );
      for (final doc in cpdEntries.docs) {
        await _firestore.deleteDocument(doc.reference);
      }
    } catch (e, stack) {
      Logger.error('Failed to delete year $year', e, stack);
      rethrow;
    }
  }
}






