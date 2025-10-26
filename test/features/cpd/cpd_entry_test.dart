import 'package:flutter_test/flutter_test.dart';
import 'package:metanoia_flutter/features/cpd/data/cpd_entry.dart';

void main() {
  group('CpdAutoTags', () {
    test('creates auto-tags correctly', () {
      final autoTags = CpdAutoTags(
        suggestedType: 'course',
        domains: [1, 2],
        impact: 'Enhanced clinical skills',
      );

      expect(autoTags.suggestedType, 'course');
      expect(autoTags.domains, [1, 2]);
      expect(autoTags.impact, 'Enhanced clinical skills');
    });

    test('toJson and fromJson work correctly', () {
      final autoTags = CpdAutoTags(
        suggestedType: 'audit',
        domains: [2, 3],
        impact: 'Improved safety practices',
      );

      final json = autoTags.toJson();
      final restored = CpdAutoTags.fromJson(json);

      expect(restored.suggestedType, autoTags.suggestedType);
      expect(restored.domains, autoTags.domains);
      expect(restored.impact, autoTags.impact);
    });
  });

  group('CpdEntry', () {
    test('creates CPD entry with basic fields', () {
      final entry = CpdEntry(
        id: 'test-id',
        type: CpdType.course,
        title: 'Clinical Audit Course',
        hours: 8.0,
        date: DateTime(2025, 1, 15),
        notes: 'Very useful',
        linkedReflectionIds: [],
      );

      expect(entry.id, 'test-id');
      expect(entry.type, CpdType.course);
      expect(entry.hours, 8.0);
      expect(entry.notes, 'Very useful');
    });

    test('creates CPD entry with auto-tags', () {
      final autoTags = CpdAutoTags(
        suggestedType: 'course',
        domains: [1, 2],
        impact: 'Enhanced skills',
      );

      final entry = CpdEntry(
        id: 'test-id',
        type: CpdType.course,
        title: 'Test Course',
        hours: 5.0,
        date: DateTime(2025, 1, 1),
        linkedReflectionIds: [],
        autoTags: autoTags,
      );

      expect(entry.hasAutoTags, isTrue);
      expect(entry.domains, [1, 2]);
      expect(entry.autoTags?.impact, 'Enhanced skills');
    });

    test('domains getter works without autoTags', () {
      final entry = CpdEntry(
        id: 'test-id',
        type: CpdType.reading,
        title: 'Journal Article',
        hours: 1.0,
        date: DateTime(2025, 1, 1),
        linkedReflectionIds: [],
      );

      expect(entry.domains, isEmpty);
      expect(entry.hasAutoTags, isFalse);
    });

    test('toJson includes all fields', () {
      final autoTags = CpdAutoTags(
        suggestedType: 'course',
        domains: [1],
        impact: 'Learning',
      );

      final entry = CpdEntry(
        id: 'test-id',
        type: CpdType.course,
        title: 'Course',
        hours: 3.0,
        date: DateTime(2025, 1, 1),
        notes: 'Notes',
        linkedReflectionIds: ['ref1'],
        autoTags: autoTags,
      );

      final json = entry.toJson();

      expect(json['id'], 'test-id');
      expect(json['type'], 'course');
      expect(json['hours'], 3.0);
      expect(json['autoTags'], isNotNull);
      expect(json['linkedReflectionIds'], ['ref1']);
    });

    test('fromJson creates CPD entry correctly', () {
      final json = {
        'id': 'test-id',
        'type': 'teaching',
        'title': 'Teaching Session',
        'hours': 2.0,
        'date': '2025-01-01T00:00:00.000',
        'notes': 'Medical students',
        'linkedReflectionIds': [],
      };

      final entry = CpdEntry.fromJson(json);

      expect(entry.id, 'test-id');
      expect(entry.type, CpdType.teaching);
      expect(entry.hours, 2.0);
      expect(entry.notes, 'Medical students');
    });

    test('fromJson handles autoTags', () {
      final json = {
        'id': 'test-id',
        'type': 'course',
        'title': 'Course',
        'hours': 5.0,
        'date': '2025-01-01T00:00:00.000',
        'linkedReflectionIds': [],
        'autoTags': {
          'type': 'course',
          'domains': [1, 2],
          'impact': 'Improved knowledge',
        },
      };

      final entry = CpdEntry.fromJson(json);

      expect(entry.hasAutoTags, isTrue);
      expect(entry.domains, [1, 2]);
      expect(entry.autoTags?.impact, 'Improved knowledge');
    });

    test('copyWith updates fields correctly', () {
      final original = CpdEntry(
        id: 'test-id',
        type: CpdType.reading,
        title: 'Original',
        hours: 1.0,
        date: DateTime(2025, 1, 1),
        linkedReflectionIds: [],
      );

      final updated = original.copyWith(
        title: 'Updated',
        hours: 2.0,
      );

      expect(updated.title, 'Updated');
      expect(updated.hours, 2.0);
      expect(updated.type, CpdType.reading); // Unchanged
      expect(updated.id, 'test-id'); // Unchanged
    });
  });
}





