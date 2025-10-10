import 'package:flutter/material.dart';

/// GMC Good Medical Practice Domains
/// Reference: https://www.gmc-uk.org/ethical-guidance/ethical-guidance-for-doctors/good-medical-practice
enum GmcDomain {
  knowledge(1, 'Knowledge, Skills and Performance', 'Develop and maintain your professional performance'),
  safety(2, 'Safety and Quality', 'Apply knowledge and experience to practice'),
  communication(3, 'Communication, Partnership and Teamwork', 'Communicate effectively'),
  trust(4, 'Maintaining Trust', 'Treat patients and colleagues fairly and without discrimination');

  const GmcDomain(this.number, this.title, this.description);
  
  final int number;
  final String title;
  final String description;
  
  /// Get domain by number (1-4)
  static GmcDomain fromNumber(int number) {
    return GmcDomain.values.firstWhere(
      (d) => d.number == number,
      orElse: () => GmcDomain.knowledge,
    );
  }
  
  /// Get display name with number
  String get displayName => '$number. $title';
  
  /// Get short name
  String get shortName {
    switch (this) {
      case GmcDomain.knowledge:
        return 'Knowledge & Skills';
      case GmcDomain.safety:
        return 'Safety & Quality';
      case GmcDomain.communication:
        return 'Communication';
      case GmcDomain.trust:
        return 'Maintaining Trust';
    }
  }
  
  /// Get domain color for UI
  Color get color {
    switch (this) {
      case GmcDomain.knowledge:
        return const Color(0xFF4F46E5); // Indigo
      case GmcDomain.safety:
        return const Color(0xFF059669); // Green
      case GmcDomain.communication:
        return const Color(0xFFD97706); // Amber
      case GmcDomain.trust:
        return const Color(0xFFDC2626); // Red
    }
  }
}

