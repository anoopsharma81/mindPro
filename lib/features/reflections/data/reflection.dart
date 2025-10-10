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
    score: j['score'] as double?,
    iterations: j['iterations'] != null 
      ? (j['iterations'] as List).cast<Map<String, dynamic>>()
      : null,
    rating: j['rating'] as int?,
    domains: j['domains'] != null
      ? (j['domains'] as List).cast<int>()
      : null,
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
