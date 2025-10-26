import '../../../common/models/gmc_domain.dart';

class Reflection {
  final String id;
  final String title;
  final String what;
  final String soWhat;
  final String nowWhat;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> linkedCpdIds;
  
  // AI/Metanoia fields
  final double? score;                        // Quality score from self-play (0.0-1.0)
  final List<Map<String, dynamic>>? iterations; // Self-play iteration history
  final int? rating;                          // User rating (1-5)
  final List<int>? domains;                   // GMC domain numbers [1,2,3,4]
  
  // AI Extraction fields
  final String? sourceType;                   // "photo", "document", "gallery", "manual", "voice"
  final String? extractedText;                // Original extracted text for reference
  final String? sourceUrl;                    // Firebase Storage URL of original file
  final double? aiConfidence;                 // 0.0-1.0 confidence score from AI
  final bool isAiGenerated;                   // True if created from AI extraction
  final DateTime? extractedAt;                // When extraction happened
  
  // Audio/Voice fields
  final String? audioUrl;                     // Firebase Storage URL of audio recording
  final int? audioDurationSeconds;            // Duration of recording
  final String? transcriptionText;            // Raw transcription text
  final String? transcriptionMethod;          // "on-device" | "whisper"
  final double? transcriptionConfidence;      // 0.0-1.0 transcription confidence

  Reflection({
    required this.id,
    required this.title,
    required this.what,
    required this.soWhat,
    required this.nowWhat,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.linkedCpdIds,
    this.score,
    this.iterations,
    this.rating,
    this.domains,
    this.sourceType,
    this.extractedText,
    this.sourceUrl,
    this.aiConfidence,
    this.isAiGenerated = false,
    this.extractedAt,
    this.audioUrl,
    this.audioDurationSeconds,
    this.transcriptionText,
    this.transcriptionMethod,
    this.transcriptionConfidence,
  });

  Reflection copyWith({
    String? title,
    String? what,
    String? soWhat,
    String? nowWhat,
    List<String>? tags,
    DateTime? updatedAt,
    List<String>? linkedCpdIds,
    double? score,
    List<Map<String, dynamic>>? iterations,
    int? rating,
    List<int>? domains,
    String? sourceType,
    String? extractedText,
    String? sourceUrl,
    double? aiConfidence,
    bool? isAiGenerated,
    DateTime? extractedAt,
    String? audioUrl,
    int? audioDurationSeconds,
    String? transcriptionText,
    String? transcriptionMethod,
    double? transcriptionConfidence,
  }) => Reflection(
    id: id,
    title: title ?? this.title,
    what: what ?? this.what,
    soWhat: soWhat ?? this.soWhat,
    nowWhat: nowWhat ?? this.nowWhat,
    tags: tags ?? this.tags,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    linkedCpdIds: linkedCpdIds ?? this.linkedCpdIds,
    score: score ?? this.score,
    iterations: iterations ?? this.iterations,
    rating: rating ?? this.rating,
    domains: domains ?? this.domains,
    sourceType: sourceType ?? this.sourceType,
    extractedText: extractedText ?? this.extractedText,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    aiConfidence: aiConfidence ?? this.aiConfidence,
    isAiGenerated: isAiGenerated ?? this.isAiGenerated,
    extractedAt: extractedAt ?? this.extractedAt,
    audioUrl: audioUrl ?? this.audioUrl,
    audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
    transcriptionText: transcriptionText ?? this.transcriptionText,
    transcriptionMethod: transcriptionMethod ?? this.transcriptionMethod,
    transcriptionConfidence: transcriptionConfidence ?? this.transcriptionConfidence,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'what': what,
    'soWhat': soWhat,
    'nowWhat': nowWhat,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'linkedCpdIds': linkedCpdIds,
    if (score != null) 'score': score,
    if (iterations != null) 'iterations': iterations,
    if (rating != null) 'rating': rating,
    if (domains != null) 'domains': domains,
    if (sourceType != null) 'sourceType': sourceType,
    if (extractedText != null) 'extractedText': extractedText,
    if (sourceUrl != null) 'sourceUrl': sourceUrl,
    if (aiConfidence != null) 'aiConfidence': aiConfidence,
    'isAiGenerated': isAiGenerated,
    if (extractedAt != null) 'extractedAt': extractedAt!.toIso8601String(),
    if (audioUrl != null) 'audioUrl': audioUrl,
    if (audioDurationSeconds != null) 'audioDurationSeconds': audioDurationSeconds,
    if (transcriptionText != null) 'transcriptionText': transcriptionText,
    if (transcriptionMethod != null) 'transcriptionMethod': transcriptionMethod,
    if (transcriptionConfidence != null) 'transcriptionConfidence': transcriptionConfidence,
  };

  static Reflection fromJson(Map<String, dynamic> j) => Reflection(
    id: j['id'] as String,
    title: j['title'] as String,
    what: j['what'] as String,
    soWhat: j['soWhat'] as String,
    nowWhat: j['nowWhat'] as String,
    tags: (j['tags'] as List).cast<String>(),
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
    linkedCpdIds: (j['linkedCpdIds'] as List).cast<String>(),
    score: j['score'] != null ? (j['score'] as num).toDouble() : null,
    iterations: j['iterations'] != null 
      ? (j['iterations'] as List).cast<Map<String, dynamic>>()
      : null,
    rating: j['rating'] as int?,
    domains: j['domains'] != null
      ? (j['domains'] as List).cast<int>()
      : null,
    sourceType: j['sourceType'] as String?,
    extractedText: j['extractedText'] as String?,
    sourceUrl: j['sourceUrl'] as String?,
    aiConfidence: j['aiConfidence'] != null ? (j['aiConfidence'] as num).toDouble() : null,
    isAiGenerated: j['isAiGenerated'] as bool? ?? false,
    extractedAt: j['extractedAt'] != null ? DateTime.parse(j['extractedAt'] as String) : null,
    audioUrl: j['audioUrl'] as String?,
    audioDurationSeconds: j['audioDurationSeconds'] as int?,
    transcriptionText: j['transcriptionText'] as String?,
    transcriptionMethod: j['transcriptionMethod'] as String?,
    transcriptionConfidence: j['transcriptionConfidence'] != null ? (j['transcriptionConfidence'] as num).toDouble() : null,
  );
  
  /// Get GMC domains as enum list
  List<GmcDomain> get gmcDomains {
    if (domains == null || domains!.isEmpty) return [];
    return domains!.map((num) => GmcDomain.fromNumber(num)).toList();
  }
  
  /// Check if reflection has been AI-improved
  bool get hasAiImprovement => iterations != null && iterations!.isNotEmpty;
  
  /// Check if reflection has been rated
  bool get hasRating => rating != null;
  
  /// Get rating as display string
  String get ratingDisplay {
    if (rating == null) return 'Not rated';
    return '⭐' * rating!;
  }
}
