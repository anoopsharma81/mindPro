import 'package:flutter_test/flutter_test.dart';
import 'package:metanoia_flutter/features/reflections/data/reflection.dart';
import 'package:metanoia_flutter/common/models/gmc_domain.dart';

void main() {
  group('Reflection', () {
    test('creates reflection with basic fields', () {
      final reflection = Reflection(
        id: 'test-id',
        title: 'Test Reflection',
        what: 'What happened',
        soWhat: 'Analysis',
        nowWhat: 'Action plan',
        tags: ['tag1', 'tag2'],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        linkedCpdIds: [],
      );

      expect(reflection.id, 'test-id');
      expect(reflection.title, 'Test Reflection');
      expect(reflection.tags.length, 2);
    });

    test('creates reflection with AI fields', () {
      final reflection = Reflection(
        id: 'test-id',
        title: 'Test Reflection',
        what: 'What happened',
        soWhat: 'Analysis',
        nowWhat: 'Action plan',
        tags: [],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        linkedCpdIds: [],
        score: 0.85,
        rating: 4,
        domains: [1, 2],
        iterations: [{'role': 'user', 'content': 'test'}],
      );

      expect(reflection.score, 0.85);
      expect(reflection.rating, 4);
      expect(reflection.domains, [1, 2]);
      expect(reflection.hasAiImprovement, isTrue);
      expect(reflection.hasRating, isTrue);
    });

    test('toJson includes all fields', () {
      final reflection = Reflection(
        id: 'test-id',
        title: 'Test Reflection',
        what: 'What happened',
        soWhat: 'Analysis',
        nowWhat: 'Action plan',
        tags: ['tag1'],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        linkedCpdIds: [],
        score: 0.85,
        rating: 4,
        domains: [1, 2],
      );

      final json = reflection.toJson();

      expect(json['id'], 'test-id');
      expect(json['title'], 'Test Reflection');
      expect(json['score'], 0.85);
      expect(json['rating'], 4);
      expect(json['domains'], [1, 2]);
    });

    test('fromJson creates reflection correctly', () {
      final json = {
        'id': 'test-id',
        'title': 'Test Reflection',
        'what': 'What happened',
        'soWhat': 'Analysis',
        'nowWhat': 'Action plan',
        'tags': ['tag1', 'tag2'],
        'createdAt': '2025-01-01T00:00:00.000',
        'updatedAt': '2025-01-01T00:00:00.000',
        'linkedCpdIds': [],
        'score': 0.85,
        'rating': 4,
        'domains': [1, 2],
      };

      final reflection = Reflection.fromJson(json);

      expect(reflection.id, 'test-id');
      expect(reflection.score, 0.85);
      expect(reflection.rating, 4);
      expect(reflection.domains, [1, 2]);
    });

    test('handles null AI fields', () {
      final json = {
        'id': 'test-id',
        'title': 'Test Reflection',
        'what': 'What happened',
        'soWhat': 'Analysis',
        'nowWhat': 'Action plan',
        'tags': [],
        'createdAt': '2025-01-01T00:00:00.000',
        'updatedAt': '2025-01-01T00:00:00.000',
        'linkedCpdIds': [],
      };

      final reflection = Reflection.fromJson(json);

      expect(reflection.score, isNull);
      expect(reflection.rating, isNull);
      expect(reflection.domains, isNull);
      expect(reflection.hasAiImprovement, isFalse);
      expect(reflection.hasRating, isFalse);
    });

    test('gmcDomains returns correct enums', () {
      final reflection = Reflection(
        id: 'test-id',
        title: 'Test',
        what: 'what',
        soWhat: 'so what',
        nowWhat: 'now what',
        tags: [],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        linkedCpdIds: [],
        domains: [1, 3],
      );

      final gmcDomains = reflection.gmcDomains;

      expect(gmcDomains.length, 2);
      expect(gmcDomains[0], GmcDomain.knowledge);
      expect(gmcDomains[1], GmcDomain.communication);
    });

    test('ratingDisplay shows correct stars', () {
      final reflection = Reflection(
        id: 'test-id',
        title: 'Test',
        what: 'what',
        soWhat: 'so what',
        nowWhat: 'now what',
        tags: [],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        linkedCpdIds: [],
        rating: 3,
      );

      expect(reflection.ratingDisplay, '⭐⭐⭐');
    });

    test('ratingDisplay shows "Not rated" for null', () {
      final reflection = Reflection(
        id: 'test-id',
        title: 'Test',
        what: 'what',
        soWhat: 'so what',
        nowWhat: 'now what',
        tags: [],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        linkedCpdIds: [],
      );

      expect(reflection.ratingDisplay, 'Not rated');
    });

    test('copyWith updates AI fields', () {
      final original = Reflection(
        id: 'test-id',
        title: 'Test',
        what: 'what',
        soWhat: 'so what',
        nowWhat: 'now what',
        tags: [],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
        linkedCpdIds: [],
      );

      final updated = original.copyWith(
        score: 0.9,
        rating: 5,
        domains: [1, 2, 3],
      );

      expect(updated.score, 0.9);
      expect(updated.rating, 5);
      expect(updated.domains, [1, 2, 3]);
      expect(updated.title, 'Test'); // Unchanged
    });
  });
}





