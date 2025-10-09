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
  });

  Reflection copyWith({
    String? title,
    String? what,
    String? soWhat,
    String? nowWhat,
    List<String>? tags,
    DateTime? updatedAt,
    List<String>? linkedCpdIds,
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
  );
}
