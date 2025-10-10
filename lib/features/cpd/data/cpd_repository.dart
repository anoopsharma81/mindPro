import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/storage/storage.dart';
import '../../../services/firestore_service.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../core/logger.dart';
import 'cpd_entry.dart';

const _keyCpd = 'cpd';
const _uuid = Uuid();

class CpdRepository {
  final FirestoreService _firestore = FirestoreService();
  final String? year;
  
  CpdRepository({this.year});
  
  String get _year => year ?? DateTime.now().year.toString();
  
  /// List all CPD entries for the current year
  Future<List<CpdEntry>> list() async {
    try {
      // Try Firestore first
      final snapshot = await _firestore.queryCollection(
        _firestore.cpdFor(_year).orderBy('date', descending: true),
      );
      
      return snapshot.docs
        .map((doc) => CpdEntry.fromJson(doc.data()))
        .toList();
    } catch (e, stack) {
      Logger.error('Failed to list CPD from Firestore, falling back to Hive', e, stack);
      
      // Fallback to Hive for backward compatibility
      final map = await KV.getMap(_keyCpd);
      return map.values
        .map((v) => CpdEntry.fromJson((v as Map).cast<String, dynamic>()))
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  /// Get a single CPD entry by ID
  Future<CpdEntry?> get(String id) async {
    try {
      // Try Firestore first
      final doc = await _firestore.getDocument(
        _firestore.cpdFor(_year).doc(id),
      );
      
      if (!doc.exists) return null;
      return CpdEntry.fromJson(doc.data()!);
    } catch (e, stack) {
      Logger.error('Failed to get CPD from Firestore, falling back to Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_keyCpd);
      final j = map[id];
      return j == null ? null : CpdEntry.fromJson((j as Map).cast<String, dynamic>());
    }
  }

  /// Create a new CPD entry
  Future<CpdEntry> create({
    required CpdType type,
    required String title,
    required double hours,
    required DateTime date,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final c = CpdEntry(
      id: id,
      type: type,
      title: title,
      hours: hours,
      date: date,
      notes: notes,
      linkedReflectionIds: const [],
    );
    
    try {
      // Save to Firestore
      await _firestore.setDocument(
        _firestore.cpdFor(_year).doc(id),
        c.toJson(),
      );
      Logger.info('CPD entry created in Firestore: $id');
    } catch (e, stack) {
      Logger.error('Failed to create CPD in Firestore, saving to Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_keyCpd);
      map[id] = c.toJson();
      await KV.setMap(_keyCpd, map);
    }
    
    return c;
  }

  /// Update an existing CPD entry
  Future<CpdEntry?> update(String id, CpdEntry patch) async {
    try {
      // Update in Firestore
      await _firestore.setDocument(
        _firestore.cpdFor(_year).doc(id),
        patch.toJson(),
      );
      Logger.info('CPD entry updated in Firestore: $id');
      return patch;
    } catch (e, stack) {
      Logger.error('Failed to update CPD in Firestore, updating Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_keyCpd);
      if (!map.containsKey(id)) return null;
      map[id] = patch.toJson();
      await KV.setMap(_keyCpd, map);
      return patch;
    }
  }

  /// Delete a CPD entry
  Future<void> remove(String id) async {
    try {
      // Delete from Firestore
      await _firestore.deleteDocument(
        _firestore.cpdFor(_year).doc(id),
      );
      Logger.info('CPD entry deleted from Firestore: $id');
    } catch (e, stack) {
      Logger.error('Failed to delete CPD from Firestore, deleting from Hive', e, stack);
      
      // Fallback to Hive
      final map = await KV.getMap(_keyCpd);
      map.remove(id);
      await KV.setMap(_keyCpd, map);
    }
  }
}

/// Riverpod provider for CPD repository with year scoping
final cpdRepositoryProvider = Provider<CpdRepository>((ref) {
  final year = ref.watch(selectedYearProvider);
  return CpdRepository(year: year);
});
