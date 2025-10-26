/// PHI (Protected Health Information) Detection Utility
/// Helps prevent accidental inclusion of patient identifiable information
/// in reflections and CPD entries

class PhiDetector {
  // Common PHI patterns to detect
  static final List<RegExp> _patterns = [
    // NHS Number (10 digits)
    RegExp(r'\b\d{3}\s?\d{3}\s?\d{4}\b', caseSensitive: false),
    
    // Names that look like full names (Mr/Mrs/Ms/Dr + First Last or First Middle Last)
    RegExp(r'\b(Mr|Mrs|Ms|Dr|Miss|Prof|Professor)\.?\s+[A-Z][a-z]+\s+[A-Z][a-z]+\b', caseSensitive: false),
    
    // Patient identifiers
    RegExp(r'\bpatient\s+(?:id|number|identifier)\s*:?\s*\w+', caseSensitive: false),
    RegExp(r'\bMRN\s*:?\s*\w+', caseSensitive: false), // Medical Record Number
    
    // Dates of birth
    RegExp(r'\bDOB\s*:?\s*\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b', caseSensitive: false),
    RegExp(r'\bborn\s+(?:on\s+)?\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b', caseSensitive: false),
    
    // Addresses (partial - postcode patterns)
    RegExp(r'\b[A-Z]{1,2}\d{1,2}\s?\d[A-Z]{2}\b'), // UK postcode
    RegExp(r'\b\d+\s+[A-Z][a-z]+\s+(Street|Road|Avenue|Lane|Drive|Close|Way)\b', caseSensitive: false),
    
    // Phone numbers (UK format)
    RegExp(r'\b0\d{10}\b'),
    RegExp(r'\b\+44\s?\d{10}\b'),
    
    // Email addresses
    RegExp(r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b'),
    
    // Hospital numbers
    RegExp(r'\b[Hh]ospital\s+[Nn]umber\s*:?\s*\w+', caseSensitive: false),
    
    // Ward/bed numbers (common patterns)
    RegExp(r'\bward\s+[A-Z0-9]+\b', caseSensitive: false),
    RegExp(r'\bbed\s+\d+', caseSensitive: false),
  ];
  
  // High-risk keywords
  static final List<String> _keywords = [
    'patient name',
    'patient\'s name',
    'nhs number',
    'date of birth',
    'hospital number',
    'medical record',
    'home address',
    'phone number',
    'email address',
  ];
  
  /// Check text for potential PHI
  /// Returns list of detected PHI types
  static List<String> detectPhi(String text) {
    final detected = <String>{};
    final lowerText = text.toLowerCase();
    
    // Check for pattern matches
    for (final pattern in _patterns) {
      if (pattern.hasMatch(text)) {
        detected.add(_getPatternDescription(pattern));
      }
    }
    
    // Check for keywords
    for (final keyword in _keywords) {
      if (lowerText.contains(keyword)) {
        detected.add('Keyword: "$keyword"');
      }
    }
    
    return detected.toList();
  }
  
  /// Check if text contains potential PHI
  static bool containsPhi(String text) {
    return detectPhi(text).isNotEmpty;
  }
  
  /// Get warning level based on number of PHI indicators
  static PhiWarningLevel getWarningLevel(String text) {
    final detected = detectPhi(text);
    
    if (detected.isEmpty) return PhiWarningLevel.none;
    if (detected.length == 1) return PhiWarningLevel.low;
    if (detected.length <= 3) return PhiWarningLevel.medium;
    return PhiWarningLevel.high;
  }
  
  static String _getPatternDescription(RegExp pattern) {
    final patternStr = pattern.pattern;
    
    if (patternStr.contains('NHS') || patternStr.contains(r'\d{3}\s?\d{3}\s?\d{4}')) {
      return 'Possible NHS Number';
    }
    if (patternStr.contains('Mr|Mrs|Ms|Dr')) {
      return 'Possible patient name';
    }
    if (patternStr.contains('DOB') || patternStr.contains('born')) {
      return 'Possible date of birth';
    }
    if (patternStr.contains('@')) {
      return 'Email address';
    }
    if (patternStr.contains('postcode') || patternStr.contains('[A-Z]{1,2}\\d{1,2}')) {
      return 'Possible address/postcode';
    }
    if (patternStr.contains('0\\d{10}') || patternStr.contains('\\+44')) {
      return 'Phone number';
    }
    if (patternStr.contains('ward') || patternStr.contains('bed')) {
      return 'Ward/bed identifier';
    }
    
    return 'Potential PHI detected';
  }
  
  /// Get user-friendly warning message
  static String getWarningMessage(List<String> detected) {
    if (detected.isEmpty) return '';
    
    final buf = StringBuffer();
    buf.writeln('⚠️ Potential Patient Information Detected\n');
    buf.writeln('The following may contain identifiable patient information:\n');
    
    for (final item in detected) {
      buf.writeln('• $item');
    }
    
    buf.writeln('\n📋 NHS IG Guidance:');
    buf.writeln('Reflections should NOT contain:');
    buf.writeln('• Patient names or identifiers');
    buf.writeln('• NHS numbers or hospital numbers');
    buf.writeln('• Dates of birth');
    buf.writeln('• Addresses or contact details');
    buf.writeln('• Specific ward/bed locations\n');
    
    buf.writeln('✅ Please use:');
    buf.writeln('• Generic descriptions (e.g., "a patient")');
    buf.writeln('• Age ranges instead of DOB');
    buf.writeln('• General locations instead of specifics');
    
    return buf.toString();
  }
}

/// Warning levels for PHI detection
enum PhiWarningLevel {
  none,     // No PHI detected
  low,      // 1 indicator - might be false positive
  medium,   // 2-3 indicators - likely contains PHI
  high,     // 4+ indicators - almost certainly contains PHI
}

extension PhiWarningLevelExt on PhiWarningLevel {
  String get description {
    switch (this) {
      case PhiWarningLevel.none:
        return 'No issues detected';
      case PhiWarningLevel.low:
        return 'Possible patient information detected';
      case PhiWarningLevel.medium:
        return 'Likely patient information detected';
      case PhiWarningLevel.high:
        return 'Patient information detected';
    }
  }
  
  bool get shouldWarn => this != PhiWarningLevel.none;
}





