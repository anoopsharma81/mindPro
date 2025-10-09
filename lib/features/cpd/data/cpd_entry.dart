enum CpdType { course, reading, audit, teaching, other }

class CpdEntry {
  final String id;
  final CpdType type;
  final String title;
  final double hours;
  final DateTime date;
  final String? notes;
  final List<String> linkedReflectionIds;

  CpdEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.hours,
    required this.date,
    this.notes,
    required this.linkedReflectionIds,
  });

  CpdEntry copyWith({
    CpdType? type,
    String? title,
    double? hours,
    DateTime? date,
    String? notes,
    List<String>? linkedReflectionIds,
  }) => CpdEntry(
    id: id,
    type: type ?? this.type,
    title: title ?? this.title,
    hours: hours ?? this.hours,
    date: date ?? this.date,
    notes: notes ?? this.notes,
    linkedReflectionIds: linkedReflectionIds ?? this.linkedReflectionIds,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'hours': hours,
    'date': date.toIso8601String(),
    'notes': notes,
    'linkedReflectionIds': linkedReflectionIds,
  };

  static CpdEntry fromJson(Map<String, dynamic> j) => CpdEntry(
    id: j['id'] as String,
    type: CpdType.values.byName(j['type'] as String),
    title: j['title'] as String,
    hours: (j['hours'] as num).toDouble(),
    date: DateTime.parse(j['date'] as String),
    notes: j['notes'] as String?,
    linkedReflectionIds: (j['linkedReflectionIds'] as List).cast<String>(),
  );
}
