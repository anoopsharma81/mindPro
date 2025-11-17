/// Learning Loop data model
/// 
/// Represents a cognitive science-based learning framework
/// with 7 steps: Gate, Observation, Encoding, Prediction, Feedback, Bias, Update Rule
class LearningLoop {
  final String id;
  final String reflectionId;  // Link to parent reflection
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;  // Owner of this learning loop
  
  // 1. GATE - Emotional & Attentional State
  final int attentionLevel;        // 0-3 (0=distracted, 3=highly focused)
  final int emotionValence;        // -3 to +3 (negative to positive)
  final int emotionArousal;        // 0-3 (calm to intense)
  final String? contextNote;       // Brief context description
  
  // 2. OBSERVATION & ACTION
  final List<String> observations; // 1-4 key observations
  final String? action;            // Clinical action taken
  
  // 3. ENCODING - Pattern Recognition
  final String patternName;        // Clinical pattern identified
  final List<String> priorKnowledgeLinks;  // 0-3 connections to prior knowledge
  final List<String> chunkTags;    // 0-8 memory retrieval tags
  
  // 4. PREDICTION - Hypothesis Formation
  final String hypothesis;         // What was predicted
  final int probabilityPercent;    // 0-100 confidence
  final List<String> discriminators; // 0-3 expected key features
  final int confidenceBucket;      // 50, 70, 85, or 95 (for calibration)
  
  // 5. FEEDBACK - Outcome Comparison
  final String outcome;            // What actually happened
  final String? errorSignal;       // Prediction vs reality difference
  
  // 6. BIAS REFLECTION - Cognitive Biases
  final List<String> biases;       // 0-5 cognitive biases identified
  final List<String> counterMoves; // 0-3 strategies to counter biases
  
  // 7. UPDATE RULE - Actionable Learning
  final String ifThenRule;         // If-then learning rule
  final String? microRep48h;       // Practice task within 48 hours
  final List<int> spacedPlanDays;  // Review schedule [2, 7, 30, 90]
  
  // OUTCOMES (tracked over time)
  final bool? predictionHit;       // Was prediction correct?
  final DateTime? retentionCheckDue;
  final List<TransferEvent> transferEvents;  // Where learning was applied
  final double? retentionScore;    // 0-100
  final int? transferCount;

  LearningLoop({
    required this.id,
    required this.reflectionId,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.attentionLevel,
    required this.emotionValence,
    required this.emotionArousal,
    this.contextNote,
    required this.observations,
    this.action,
    required this.patternName,
    this.priorKnowledgeLinks = const [],
    this.chunkTags = const [],
    required this.hypothesis,
    required this.probabilityPercent,
    this.discriminators = const [],
    required this.confidenceBucket,
    required this.outcome,
    this.errorSignal,
    this.biases = const [],
    this.counterMoves = const [],
    required this.ifThenRule,
    this.microRep48h,
    this.spacedPlanDays = const [],
    this.predictionHit,
    this.retentionCheckDue,
    this.transferEvents = const [],
    this.retentionScore,
    this.transferCount,
  });

  LearningLoop copyWith({
    String? reflectionId,
    DateTime? updatedAt,
    int? attentionLevel,
    int? emotionValence,
    int? emotionArousal,
    String? contextNote,
    List<String>? observations,
    String? action,
    String? patternName,
    List<String>? priorKnowledgeLinks,
    List<String>? chunkTags,
    String? hypothesis,
    int? probabilityPercent,
    List<String>? discriminators,
    int? confidenceBucket,
    String? outcome,
    String? errorSignal,
    List<String>? biases,
    List<String>? counterMoves,
    String? ifThenRule,
    String? microRep48h,
    List<int>? spacedPlanDays,
    bool? predictionHit,
    DateTime? retentionCheckDue,
    List<TransferEvent>? transferEvents,
    double? retentionScore,
    int? transferCount,
  }) => LearningLoop(
    id: id,
    reflectionId: reflectionId ?? this.reflectionId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    userId: userId,
    attentionLevel: attentionLevel ?? this.attentionLevel,
    emotionValence: emotionValence ?? this.emotionValence,
    emotionArousal: emotionArousal ?? this.emotionArousal,
    contextNote: contextNote ?? this.contextNote,
    observations: observations ?? this.observations,
    action: action ?? this.action,
    patternName: patternName ?? this.patternName,
    priorKnowledgeLinks: priorKnowledgeLinks ?? this.priorKnowledgeLinks,
    chunkTags: chunkTags ?? this.chunkTags,
    hypothesis: hypothesis ?? this.hypothesis,
    probabilityPercent: probabilityPercent ?? this.probabilityPercent,
    discriminators: discriminators ?? this.discriminators,
    confidenceBucket: confidenceBucket ?? this.confidenceBucket,
    outcome: outcome ?? this.outcome,
    errorSignal: errorSignal ?? this.errorSignal,
    biases: biases ?? this.biases,
    counterMoves: counterMoves ?? this.counterMoves,
    ifThenRule: ifThenRule ?? this.ifThenRule,
    microRep48h: microRep48h ?? this.microRep48h,
    spacedPlanDays: spacedPlanDays ?? this.spacedPlanDays,
    predictionHit: predictionHit ?? this.predictionHit,
    retentionCheckDue: retentionCheckDue ?? this.retentionCheckDue,
    transferEvents: transferEvents ?? this.transferEvents,
    retentionScore: retentionScore ?? this.retentionScore,
    transferCount: transferCount ?? this.transferCount,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'reflectionId': reflectionId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'userId': userId,
    'gate': {
      'attention_0_3': attentionLevel,
      'emotion_valence_-3_+3': emotionValence,
      'emotion_arousal_0_3': emotionArousal,
      if (contextNote != null) 'context_note': contextNote,
    },
    'observation_action': {
      'observations': observations,
      if (action != null) 'action': action,
    },
    'encoding': {
      'pattern_name': patternName,
      'links_prior_knowledge': priorKnowledgeLinks,
      'chunk_tags': chunkTags,
    },
    'prediction': {
      'hypothesis': hypothesis,
      'probability_pct': probabilityPercent,
      'discriminators_expected': discriminators,
      'confidence_bucket': confidenceBucket,
    },
    'feedback': {
      'outcome': outcome,
      if (errorSignal != null) 'error_signal': errorSignal,
    },
    'reflection_bias': {
      'bias_tags': biases,
      'counter_moves': counterMoves,
    },
    'update_rule': {
      'if_then': ifThenRule,
      if (microRep48h != null) 'micro_rep_48h': microRep48h,
      'spaced_plan_days': spacedPlanDays,
    },
    'outcomes': {
      if (predictionHit != null) 'hit': predictionHit,
      if (retentionCheckDue != null) 'retention_check_due': retentionCheckDue!.toIso8601String(),
      'transfer_events': transferEvents.map((e) => e.toJson()).toList(),
      if (retentionScore != null) 'retention_score_0_100': retentionScore,
      if (transferCount != null) 'transfer_count': transferCount,
    },
  };

  static LearningLoop fromJson(Map<String, dynamic> j) {
    final gate = j['gate'] as Map<String, dynamic>? ?? {};
    final obsAction = j['observation_action'] as Map<String, dynamic>? ?? {};
    final encoding = j['encoding'] as Map<String, dynamic>? ?? {};
    final prediction = j['prediction'] as Map<String, dynamic>? ?? {};
    final feedback = j['feedback'] as Map<String, dynamic>? ?? {};
    final bias = j['reflection_bias'] as Map<String, dynamic>? ?? {};
    final updateRule = j['update_rule'] as Map<String, dynamic>? ?? {};
    final outcomes = j['outcomes'] as Map<String, dynamic>? ?? {};

    return LearningLoop(
      id: j['id'] as String,
      reflectionId: j['reflectionId'] as String,
      createdAt: DateTime.parse(j['createdAt'] as String),
      updatedAt: DateTime.parse(j['updatedAt'] as String),
      userId: j['userId'] as String,
      
      // Gate
      attentionLevel: gate['attention_0_3'] as int? ?? 2,
      emotionValence: gate['emotion_valence_-3_+3'] as int? ?? 0,
      emotionArousal: gate['emotion_arousal_0_3'] as int? ?? 1,
      contextNote: gate['context_note'] as String?,
      
      // Observation & Action
      observations: (obsAction['observations'] as List?)?.cast<String>() ?? [],
      action: obsAction['action'] as String?,
      
      // Encoding
      patternName: encoding['pattern_name'] as String? ?? '',
      priorKnowledgeLinks: (encoding['links_prior_knowledge'] as List?)?.cast<String>() ?? [],
      chunkTags: (encoding['chunk_tags'] as List?)?.cast<String>() ?? [],
      
      // Prediction
      hypothesis: prediction['hypothesis'] as String? ?? '',
      probabilityPercent: prediction['probability_pct'] as int? ?? 50,
      discriminators: (prediction['discriminators_expected'] as List?)?.cast<String>() ?? [],
      confidenceBucket: prediction['confidence_bucket'] as int? ?? 50,
      
      // Feedback
      outcome: feedback['outcome'] as String? ?? '',
      errorSignal: feedback['error_signal'] as String?,
      
      // Bias Reflection
      biases: (bias['bias_tags'] as List?)?.cast<String>() ?? [],
      counterMoves: (bias['counter_moves'] as List?)?.cast<String>() ?? [],
      
      // Update Rule
      ifThenRule: updateRule['if_then'] as String? ?? '',
      microRep48h: updateRule['micro_rep_48h'] as String?,
      spacedPlanDays: (updateRule['spaced_plan_days'] as List?)?.cast<int>() ?? [],
      
      // Outcomes
      predictionHit: outcomes['hit'] as bool?,
      retentionCheckDue: outcomes['retention_check_due'] != null 
        ? DateTime.parse(outcomes['retention_check_due'] as String)
        : null,
      transferEvents: (outcomes['transfer_events'] as List?)
        ?.map((e) => TransferEvent.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
      retentionScore: outcomes['retention_score_0_100'] != null 
        ? (outcomes['retention_score_0_100'] as num).toDouble()
        : null,
      transferCount: outcomes['transfer_count'] as int?,
    );
  }

  /// Get attention level label
  String get attentionLabel {
    const labels = ['Distracted', 'Moderate', 'Focused', 'Highly Focused'];
    return labels[attentionLevel.clamp(0, 3)];
  }

  /// Get emotion valence label
  String get emotionValenceLabel {
    const labels = [
      'Very Negative',    // -3
      'Negative',         // -2
      'Slightly Negative',// -1
      'Neutral',          // 0
      'Slightly Positive',// +1
      'Positive',         // +2
      'Very Positive',    // +3
    ];
    return labels[(emotionValence + 3).clamp(0, 6)];
  }

  /// Get emotion arousal label
  String get emotionArousalLabel {
    const labels = ['Calm', 'Mild', 'Moderate', 'Intense'];
    return labels[emotionArousal.clamp(0, 3)];
  }

  /// Calculate next review date based on spaced repetition
  DateTime? getNextReviewDate() {
    if (spacedPlanDays.isEmpty) return null;
    
    // Find next review day that hasn't passed yet
    final now = DateTime.now();
    for (final days in spacedPlanDays) {
      final reviewDate = createdAt.add(Duration(days: days));
      if (reviewDate.isAfter(now)) {
        return reviewDate;
      }
    }
    return null;
  }

  /// Check if a review is due
  bool get isReviewDue {
    final nextReview = getNextReviewDate();
    if (nextReview == null) return false;
    return DateTime.now().isAfter(nextReview);
  }
}

/// Transfer Event - when learning was applied to a new context
class TransferEvent {
  final DateTime date;
  final String context;
  
  TransferEvent({
    required this.date,
    required this.context,
  });
  
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'context': context,
  };
  
  static TransferEvent fromJson(Map<String, dynamic> j) => TransferEvent(
    date: DateTime.parse(j['date'] as String),
    context: j['context'] as String,
  );
}


