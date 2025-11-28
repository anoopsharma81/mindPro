import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/storage/storage.dart';
import '../../../services/firestore_service.dart';
import '../../../core/logger.dart';
import '../../../metanoia_reflection_schema.dart';

const _key = 'metanoia_reflections';
const _uuid = Uuid();

class MetanoiaReflectionRepository {
  final FirestoreService _firestore = FirestoreService();
  final String? year;
  
  MetanoiaReflectionRepository({this.year});
  
  String get _year => year ?? DateTime.now().year.toString();
  
  /// List all Metanoia reflections for the current year
  Future<List<MetanoiaReflection>> list() async {
    try {
      // Try Firestore first
      final snapshot = await _firestore.queryCollection(
        _firestore.yearsCollection.doc(_year).collection('metanoia_reflections').orderBy('createdAt', descending: true),
      );
      
      return snapshot.docs
        .map((doc) => MetanoiaReflection.fromJson(doc.data()))
        .toList();
    } catch (e, stack) {
      Logger.error('Failed to list Metanoia reflections from Firestore, falling back to Hive', e, stack);
      
      // Fallback to Hive for backward compatibility
      final map = await KV.getMap(_key);
      return map.values
        .map((v) => MetanoiaReflection.fromJson((v as Map).cast<String, dynamic>()))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  /// Get a single Metanoia reflection by ID
  Future<MetanoiaReflection?> get(String id) async {
    try {
      // Try Firestore first
      final doc = await _firestore.getDocument(
        _firestore.yearsCollection.doc(_year).collection('metanoia_reflections').doc(id),
      );
      
      if (!doc.exists) return null;
      return MetanoiaReflection.fromJson(doc.data()!);
    } catch (e, stack) {
      Logger.error('Failed to get Metanoia reflection from Firestore, falling back to Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_key);
      final j = map[id];
      return j == null ? null : MetanoiaReflection.fromJson((j as Map).cast<String, dynamic>());
    }
  }

  /// Create a new Metanoia reflection
  Future<MetanoiaReflection> create(MetanoiaReflection reflection) async {
    try {
      // Save to Firestore
      await _firestore.setDocument(
        _firestore.yearsCollection.doc(_year).collection('metanoia_reflections').doc(reflection.id),
        reflection.toJson(),
      );
      Logger.info('Metanoia reflection created in Firestore: ${reflection.id}');
    } catch (e, stack) {
      Logger.error('Failed to create Metanoia reflection in Firestore, saving to Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_key);
      map[reflection.id] = reflection.toJson();
      await KV.setMap(_key, map);
    }
    
    return reflection;
  }

  /// Update an existing Metanoia reflection
  Future<MetanoiaReflection> update(String id, MetanoiaReflection reflection) async {
    final updated = reflection.copyWith(updatedAt: DateTime.now());
    
    try {
      // Update in Firestore
      await _firestore.setDocument(
        _firestore.yearsCollection.doc(_year).collection('metanoia_reflections').doc(id),
        updated.toJson(),
      );
      Logger.info('Metanoia reflection updated in Firestore: $id');
    } catch (e, stack) {
      Logger.error('Failed to update Metanoia reflection in Firestore, updating in Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_key);
      map[id] = updated.toJson();
      await KV.setMap(_key, map);
    }
    
    return updated;
  }

  /// Delete a Metanoia reflection
  Future<void> remove(String id) async {
    try {
      // Delete from Firestore
      await _firestore.deleteDocument(
        _firestore.yearsCollection.doc(_year).collection('metanoia_reflections').doc(id),
      );
      Logger.info('Metanoia reflection deleted from Firestore: $id');
    } catch (e, stack) {
      Logger.error('Failed to delete Metanoia reflection from Firestore, deleting from Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_key);
      map.remove(id);
      await KV.setMap(_key, map);
    }
  }
}

/// Provider for Metanoia reflection repository
final metanoiaReflectionRepositoryProvider = Provider<MetanoiaReflectionRepository>((ref) {
  return MetanoiaReflectionRepository();
});

