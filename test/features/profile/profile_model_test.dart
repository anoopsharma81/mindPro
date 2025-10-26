import 'package:flutter_test/flutter_test.dart';
import 'package:metanoia_flutter/features/profile/profile_model.dart';

void main() {
  group('Profile', () {
    test('creates profile with all fields', () {
      final profile = Profile(
        uid: 'test-uid',
        displayName: 'Dr. Test User',
        gmcNumber: '1234567',
        defaultYear: '2025',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      expect(profile.uid, 'test-uid');
      expect(profile.displayName, 'Dr. Test User');
      expect(profile.gmcNumber, '1234567');
      expect(profile.defaultYear, '2025');
    });

    test('toJson includes all fields', () {
      final profile = Profile(
        uid: 'test-uid',
        displayName: 'Dr. Test User',
        gmcNumber: '1234567',
        defaultYear: '2025',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final json = profile.toJson();

      expect(json['displayName'], 'Dr. Test User');
      expect(json['gmcNumber'], '1234567');
      expect(json['defaultYear'], '2025');
      expect(json['createdAt'], isNotEmpty);
      expect(json['updatedAt'], isNotEmpty);
    });

    test('fromJson creates profile correctly', () {
      final json = {
        'displayName': 'Dr. Test User',
        'gmcNumber': '1234567',
        'defaultYear': '2025',
        'createdAt': '2025-01-01T00:00:00.000',
        'updatedAt': '2025-01-01T00:00:00.000',
      };

      final profile = Profile.fromJson('test-uid', json);

      expect(profile.uid, 'test-uid');
      expect(profile.displayName, 'Dr. Test User');
      expect(profile.gmcNumber, '1234567');
      expect(profile.defaultYear, '2025');
    });

    test('copyWith updates only specified fields', () {
      final original = Profile(
        uid: 'test-uid',
        displayName: 'Dr. Test User',
        gmcNumber: '1234567',
        defaultYear: '2025',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final updated = original.copyWith(displayName: 'Dr. New Name');

      expect(updated.displayName, 'Dr. New Name');
      expect(updated.gmcNumber, '1234567'); // Unchanged
      expect(updated.uid, 'test-uid'); // Unchanged
    });
  });

  group('YearConfig', () {
    test('creates year config with all fields', () {
      final yearConfig = YearConfig(
        year: '2025',
        specialty: 'General Practice',
        org: 'NHS Test Trust',
        appraiserName: 'Dr. Jane Smith',
        appraiserRole: 'Educational Supervisor',
        appraisalDate: DateTime(2025, 12, 1),
        location: 'London',
      );

      expect(yearConfig.year, '2025');
      expect(yearConfig.specialty, 'General Practice');
      expect(yearConfig.appraiserName, 'Dr. Jane Smith');
    });

    test('toJson includes all fields', () {
      final yearConfig = YearConfig(
        year: '2025',
        specialty: 'General Practice',
        org: 'NHS Test Trust',
        appraiserName: 'Dr. Jane Smith',
        appraiserRole: 'Educational Supervisor',
        appraisalDate: DateTime(2025, 12, 1),
        location: 'London',
      );

      final json = yearConfig.toJson();

      expect(json['specialty'], 'General Practice');
      expect(json['org'], 'NHS Test Trust');
      expect(json['appraiserName'], 'Dr. Jane Smith');
      expect(json['appraisalDate'], isNotEmpty);
    });

    test('fromJson creates year config correctly', () {
      final json = {
        'specialty': 'General Practice',
        'org': 'NHS Test Trust',
        'appraiserName': 'Dr. Jane Smith',
        'appraiserRole': 'Educational Supervisor',
        'appraisalDate': '2025-12-01T00:00:00.000',
        'location': 'London',
      };

      final yearConfig = YearConfig.fromJson('2025', json);

      expect(yearConfig.year, '2025');
      expect(yearConfig.specialty, 'General Practice');
      expect(yearConfig.org, 'NHS Test Trust');
    });

    test('handles null appraisal date', () {
      final json = {
        'specialty': 'General Practice',
        'org': 'NHS Test Trust',
        'appraiserName': '',
        'appraiserRole': '',
        'location': '',
      };

      final yearConfig = YearConfig.fromJson('2025', json);

      expect(yearConfig.appraisalDate, isNull);
    });
  });
}





