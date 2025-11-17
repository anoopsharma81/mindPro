import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../core/logger.dart';
import 'learning_loop.dart';

const _uuid = Uuid();

class LearningLoopRepository {
  final FirestoreService _firestore = FirestoreService();
  final String? year;
  
  LearningLoopRepository({this.year});
  
  String get _year => year ?? DateTime.now().year.toString();
  
  /// Get collection reference for learning loops
  CollectionReference<Map<String, dynamic>> get _collection {
    // Learning loops are stored at the root level, scoped by year
    // Path: learning_loops/{year}/items/{loopId}
    return FirebaseFirestore.instance
      .collection('learning_loops')
      .doc(_year)
      .collection('items');
  }
  
  /// Get learning loop by reflection ID
  Future<LearningLoop?> getByReflectionId(String reflectionId) async {
    try {
      final snapshot = await _firestore.queryCollection(
        _collection.where('reflectionId', isEqualTo: reflectionId).limit(1),
      );
      
      if (snapshot.docs.isEmpty) return null;
      return LearningLoop.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e, stack) {
      Logger.error('Failed to get learning loop by reflection ID', e, stack);
      return null;
    }
  }
  
  /// Get a single learning loop by ID
  Future<LearningLoop?> get(String id) async {
    try {
      final doc = await _firestore.getDocument(_collection.doc(id));
      
      if (!doc.exists) return null;
      return LearningLoop.fromJson(doc.data()! as Map<String, dynamic>);
    } catch (e, stack) {
      Logger.error('Failed to get learning loop', e, stack);
      return null;
    }
  }
  
  /// List all learning loops for the current year
  Future<List<LearningLoop>> list() async {
    try {
      final snapshot = await _firestore.queryCollection(
        _collection.orderBy('createdAt', descending: true),
      );
      
      return snapshot.docs
        .map((doc) => LearningLoop.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    } catch (e, stack) {
      Logger.error('Failed to list learning loops', e, stack);
      return [];
    }
  }
  
  /// Save a learning loop (create or update)
  Future<LearningLoop> save(LearningLoop loop) async {
    try {
      await _firestore.setDocument(
        _collection.doc(loop.id),
        loop.toJson(),
      );
      Logger.info('Learning loop saved: ${loop.id}');
      return loop;
    } catch (e, stack) {
      Logger.error('Failed to save learning loop', e, stack);
      rethrow;
    }
  }
  
  /// Create a new learning loop
  Future<LearningLoop> create({
    required String reflectionId,
    required String userId,
    required int attentionLevel,
    required int emotionValence,
    required int emotionArousal,
    String? contextNote,
    required List<String> observations,
    String? action,
    required String patternName,
    List<String> priorKnowledgeLinks = const [],
    List<String> chunkTags = const [],
    required String hypothesis,
    required int probabilityPercent,
    List<String> discriminators = const [],
    required int confidenceBucket,
    required String outcome,
    String? errorSignal,
    List<String> biases = const [],
    List<String> counterMoves = const [],
    required String ifThenRule,
    String? microRep48h,
    List<int> spacedPlanDays = const [],
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    
    final loop = LearningLoop(
      id: id,
      reflectionId: reflectionId,
      createdAt: now,
      updatedAt: now,
      userId: userId,
      attentionLevel: attentionLevel,
      emotionValence: emotionValence,
      emotionArousal: emotionArousal,
      contextNote: contextNote,
      observations: observations,
      action: action,
      patternName: patternName,
      priorKnowledgeLinks: priorKnowledgeLinks,
      chunkTags: chunkTags,
      hypothesis: hypothesis,
      probabilityPercent: probabilityPercent,
      discriminators: discriminators,
      confidenceBucket: confidenceBucket,
      outcome: outcome,
      errorSignal: errorSignal,
      biases: biases,
      counterMoves: counterMoves,
      ifThenRule: ifThenRule,
      microRep48h: microRep48h,
      spacedPlanDays: spacedPlanDays,
    );
    
    return save(loop);
  }
  
  /// Update an existing learning loop
  Future<LearningLoop> update(LearningLoop loop) async {
    final updated = loop.copyWith(updatedAt: DateTime.now());
    return save(updated);
  }
  
  /// Delete a learning loop
  Future<void> delete(String id) async {
    try {
      await _firestore.deleteDocument(_collection.doc(id));
      Logger.info('Learning loop deleted: $id');
    } catch (e, stack) {
      Logger.error('Failed to delete learning loop', e, stack);
      rethrow;
    }
  }
  
  /// Record prediction outcome (hit or miss)
  Future<void> recordPredictionOutcome(String id, bool wasCorrect) async {
    try {
      final loop = await get(id);
      if (loop == null) {
        throw Exception('Learning loop not found');
      }
      
      final updated = loop.copyWith(predictionHit: wasCorrect);
      await save(updated);
      
      Logger.info('Prediction outcome recorded for $id: ${wasCorrect ? "Hit" : "Miss"}');
    } catch (e, stack) {
      Logger.error('Failed to record prediction outcome', e, stack);
      rethrow;
    }
  }
  
  /// Add a transfer event (where learning was applied)
  Future<void> addTransferEvent(String id, DateTime date, String context) async {
    try {
      final loop = await get(id);
      if (loop == null) {
        throw Exception('Learning loop not found');
      }
      
      final newEvent = TransferEvent(date: date, context: context);
      final updatedEvents = [...loop.transferEvents, newEvent];
      final updatedLoop = loop.copyWith(
        transferEvents: updatedEvents,
        transferCount: updatedEvents.length,
      );
      
      await save(updatedLoop);
      Logger.info('Transfer event added to $id');
    } catch (e, stack) {
      Logger.error('Failed to add transfer event', e, stack);
      rethrow;
    }
  }
  
  /// Get upcoming reviews (next 7 days)
  Future<List<LearningLoop>> getUpcomingReviews({int daysAhead = 7}) async {
    try {
      final loops = await list();
      final now = DateTime.now();
      final cutoff = now.add(Duration(days: daysAhead));
      
      return loops.where((loop) {
        final nextReview = loop.getNextReviewDate();
        if (nextReview == null) return false;
        return nextReview.isAfter(now) && nextReview.isBefore(cutoff);
      }).toList();
    } catch (e, stack) {
      Logger.error('Failed to get upcoming reviews', e, stack);
      return [];
    }
  }
  
  /// Get learning loops that need review today
  Future<List<LearningLoop>> getReviewsDueToday() async {
    try {
      final loops = await list();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      return loops.where((loop) {
        final nextReview = loop.getNextReviewDate();
        if (nextReview == null) return false;
        return nextReview.isAfter(today) && nextReview.isBefore(tomorrow);
      }).toList();
    } catch (e, stack) {
      Logger.error('Failed to get reviews due today', e, stack);
      return [];
    }
  }
  
  /// Get analytics data
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final loops = await list();
      
      // Calculate prediction accuracy
      final loopsWithPrediction = loops.where((l) => l.predictionHit != null).toList();
      final hits = loopsWithPrediction.where((l) => l.predictionHit == true).length;
      final accuracy = loopsWithPrediction.isEmpty 
        ? 0.0 
        : (hits / loopsWithPrediction.length * 100);
      
      // Count biases
      final allBiases = <String, int>{};
      for (final loop in loops) {
        for (final bias in loop.biases) {
          allBiases[bias] = (allBiases[bias] ?? 0) + 1;
        }
      }
      
      // Count transfers
      final totalTransfers = loops.fold<int>(0, (sum, loop) => sum + loop.transferEvents.length);
      
      // Count reviews due
      final upcomingReviews = await getUpcomingReviews();
      
      return {
        'totalLoops': loops.length,
        'predictionAccuracy': accuracy,
        'totalTransfers': totalTransfers,
        'upcomingReviews': upcomingReviews.length,
        'mostCommonBiases': allBiases.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      };
    } catch (e, stack) {
      Logger.error('Failed to get analytics', e, stack);
      return {
        'totalLoops': 0,
        'predictionAccuracy': 0.0,
        'totalTransfers': 0,
        'upcomingReviews': 0,
        'mostCommonBiases': [],
      };
    }
  }
}

/// Provider for learning loop repository
final learningLoopRepositoryProvider = Provider<LearningLoopRepository>((ref) {
  return LearningLoopRepository();
});

/// Provider for learning loop by reflection ID
final learningLoopByReflectionProvider = FutureProvider.family<LearningLoop?, String>(
  (ref, reflectionId) async {
    final repo = ref.watch(learningLoopRepositoryProvider);
    return repo.getByReflectionId(reflectionId);
  },
);

/// Provider for upcoming reviews
final upcomingReviewsProvider = FutureProvider<List<LearningLoop>>((ref) async {
  final repo = ref.watch(learningLoopRepositoryProvider);
  return repo.getUpcomingReviews();
});

/// Provider for learning loop analytics
final learningLoopAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(learningLoopRepositoryProvider);
  return repo.getAnalytics();
});

