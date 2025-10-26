import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/storage/storage.dart';
import '../../../services/firestore_service.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../core/logger.dart';
import 'reflection.dart';

const _key = 'reflections';
const _uuid = Uuid();

class ReflectionRepository {
  final FirestoreService _firestore = FirestoreService();
  final String? year;
  
  ReflectionRepository({this.year});
  
  String get _year => year ?? DateTime.now().year.toString();
  
  /// List all reflections for the current year
  Future<List<Reflection>> list() async {
    try {
      // Try Firestore first
      final snapshot = await _firestore.queryCollection(
        _firestore.reflectionsFor(_year).orderBy('createdAt', descending: true),
      );
      
      return snapshot.docs
        .map((doc) => Reflection.fromJson(doc.data()))
        .toList();
    } catch (e, stack) {
      Logger.error('Failed to list reflections from Firestore, falling back to Hive', e, stack);
      
      // Fallback to Hive for backward compatibility
      final map = await KV.getMap(_key);
      return map.values
        .map((v) => Reflection.fromJson((v as Map).cast<String, dynamic>()))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  /// Get a single reflection by ID
  Future<Reflection?> get(String id) async {
    try {
      // Try Firestore first
      final doc = await _firestore.getDocument(
        _firestore.reflectionsFor(_year).doc(id),
      );
      
      if (!doc.exists) return null;
      return Reflection.fromJson(doc.data()!);
    } catch (e, stack) {
      Logger.error('Failed to get reflection from Firestore, falling back to Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_key);
      final j = map[id];
      return j == null ? null : Reflection.fromJson((j as Map).cast<String, dynamic>());
    }
  }

  /// Create a new reflection
  Future<Reflection> create({
    required String title,
    required String what,
    required String soWhat,
    required String nowWhat,
    List<String> tags = const [],
    List<int>? domains,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final r = Reflection(
      id: id,
      title: title,
      what: what,
      soWhat: soWhat,
      nowWhat: nowWhat,
      tags: tags,
      createdAt: now,
      updatedAt: now,
      linkedCpdIds: const [],
      domains: domains,
    );
    
    try {
      // Save to Firestore
      await _firestore.setDocument(
        _firestore.reflectionsFor(_year).doc(id),
        r.toJson(),
      );
      Logger.info('Reflection created in Firestore: $id');
    } catch (e, stack) {
      Logger.error('Failed to create reflection in Firestore, saving to Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_key);
      map[id] = r.toJson();
      await KV.setMap(_key, map);
    }
    
    return r;
  }

  /// Save a fully-constructed reflection (useful for AI-extracted reflections)
  Future<Reflection> save(Reflection reflection) async {
    try {
      // Save to Firestore
      await _firestore.setDocument(
        _firestore.reflectionsFor(_year).doc(reflection.id),
        reflection.toJson(),
      );
      Logger.info('Reflection saved in Firestore: ${reflection.id}');
    } catch (e, stack) {
      Logger.error('Failed to save reflection in Firestore, saving to Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_key);
      map[reflection.id] = reflection.toJson();
      await KV.setMap(_key, map);
    }
    
    return reflection;
  }

  /// Update an existing reflection
  Future<Reflection?> update(String id, Reflection patch) async {
    final updated = patch.copyWith(updatedAt: DateTime.now());
    
    try {
      // Update in Firestore
      await _firestore.setDocument(
        _firestore.reflectionsFor(_year).doc(id),
        updated.toJson(),
      );
      Logger.info('Reflection updated in Firestore: $id');
      return updated;
    } catch (e, stack) {
      Logger.error('Failed to update reflection in Firestore, updating Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_key);
      if (!map.containsKey(id)) return null;
      map[id] = updated.toJson();
      await KV.setMap(_key, map);
      return updated;
    }
  }

  /// Delete a reflection
  Future<void> remove(String id) async {
    try {
      // Delete from Firestore
      await _firestore.deleteDocument(
        _firestore.reflectionsFor(_year).doc(id),
      );
      Logger.info('Reflection deleted from Firestore: $id');
    } catch (e, stack) {
      Logger.error('Failed to delete reflection from Firestore, deleting from Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_key);
      map.remove(id);
      await KV.setMap(_key, map);
    }
  }

  /// Search reflections by query
  Future<List<Reflection>> search(String q) async {
    final s = q.trim().toLowerCase();
    final all = await list();
    if (s.isEmpty) return all;
    return all.where((r) =>
      r.title.toLowerCase().contains(s) ||
      r.what.toLowerCase().contains(s) ||
      r.soWhat.toLowerCase().contains(s) ||
      r.nowWhat.toLowerCase().contains(s) ||
      r.tags.any((t) => t.toLowerCase().contains(s))
    ).toList();
  }
}

/// Riverpod provider for reflection repository with year scoping
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final year = ref.watch(selectedYearProvider);
  return ReflectionRepository(year: year);
});
