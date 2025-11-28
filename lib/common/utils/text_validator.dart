/// Utility to validate if text is meaningful or nonsensical
class TextValidator {
  /// Check if text appears to be meaningful (not random characters/nonsense)
  static bool isMeaningful(String text) {
    if (text.trim().isEmpty) return false;
    
    final trimmed = text.trim();
    
    // Very short text (less than 3 chars) is likely not meaningful
    if (trimmed.length < 3) return false;
    
    // Check for patterns that indicate nonsense:
    
    // 1. Too many special characters relative to letters
    final letterCount = trimmed.replaceAll(RegExp(r'[^a-zA-Z]'), '').length;
    final specialCharCount = trimmed.replaceAll(RegExp(r'[a-zA-Z0-9\s]'), '').length;
    if (letterCount > 0 && specialCharCount / letterCount > 0.5) {
      return false; // Too many special chars
    }
    
    // 2. Check for repeated character patterns (like "aaaa" or "abcabc")
    if (_hasRepeatingPatterns(trimmed)) {
      return false;
    }
    
    // 3. Check if it's mostly random characters without spaces
    // Meaningful text usually has spaces or is a single word
    final hasSpaces = trimmed.contains(' ');
    final wordCount = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    
    // If no spaces and very long, likely nonsense
    if (!hasSpaces && trimmed.length > 20) {
      // Check if it's a single long word (might be valid) vs random chars
      final hasVowels = RegExp(r'[aeiouAEIOU]').hasMatch(trimmed);
      if (!hasVowels || _hasTooManyConsonants(trimmed)) {
        return false;
      }
    }
    
    // 4. Check for common words (if it has spaces, should have some common words)
    if (hasSpaces && wordCount >= 2) {
      final commonWords = [
        'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
        'of', 'with', 'by', 'from', 'as', 'is', 'was', 'are', 'were', 'be',
        'been', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
        'could', 'should', 'may', 'might', 'can', 'this', 'that', 'these',
        'those', 'i', 'you', 'he', 'she', 'it', 'we', 'they', 'patient',
        'today', 'was', 'were', 'saw', 'did', 'felt', 'thought', 'learned'
      ];
      final lowerText = trimmed.toLowerCase();
      final hasCommonWord = commonWords.any((word) => 
        lowerText.contains(RegExp('\\b$word\\b'))
      );
      if (!hasCommonWord && wordCount >= 3) {
        // Multiple words but no common words - likely nonsense
        return false;
      }
    }
    
    // 5. Check character distribution (random text has more uniform distribution)
    if (trimmed.length > 10 && _hasUniformDistribution(trimmed)) {
      return false;
    }
    
    return true;
  }
  
  /// Check if text has repeating patterns
  static bool _hasRepeatingPatterns(String text) {
    // Check for same character repeated many times
    for (int i = 0; i < text.length - 3; i++) {
      final char = text[i];
      int count = 1;
      for (int j = i + 1; j < text.length && text[j] == char; j++) {
        count++;
      }
      if (count >= 4) return true; // 4+ same chars in a row
    }
    
    // Check for repeating substrings (like "abcabc")
    if (text.length >= 6) {
      for (int len = 2; len <= text.length ~/ 2; len++) {
        final pattern = text.substring(0, len);
        if (text.length % len == 0) {
          bool isRepeating = true;
          for (int i = len; i < text.length; i += len) {
            if (text.substring(i, i + len) != pattern) {
              isRepeating = false;
              break;
            }
          }
          if (isRepeating) return true;
        }
      }
    }
    
    return false;
  }
  
  /// Check if text has too many consonants in a row
  static bool _hasTooManyConsonants(String text) {
    final consonants = RegExp(r'[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]');
    int maxConsecutive = 0;
    int current = 0;
    
    for (int i = 0; i < text.length; i++) {
      if (consonants.hasMatch(text[i])) {
        current++;
        maxConsecutive = current > maxConsecutive ? current : maxConsecutive;
      } else {
        current = 0;
      }
    }
    
    // More than 5 consonants in a row is unusual
    return maxConsecutive > 5;
  }
  
  /// Check if character distribution is too uniform (indicates random text)
  static bool _hasUniformDistribution(String text) {
    if (text.length < 10) return false;
    
    final charCounts = <String, int>{};
    for (int i = 0; i < text.length; i++) {
      final char = text[i].toLowerCase();
      if (RegExp(r'[a-z]').hasMatch(char)) {
        charCounts[char] = (charCounts[char] ?? 0) + 1;
      }
    }
    
    if (charCounts.isEmpty) return false;
    
    final counts = charCounts.values.toList();
    final avg = counts.reduce((a, b) => a + b) / counts.length;
    final variance = counts.map((c) => (c - avg) * (c - avg)).reduce((a, b) => a + b) / counts.length;
    
    // Very low variance indicates uniform distribution (random text)
    return variance < 0.5;
  }
  
  /// Check if AI response actually relates to the input text
  /// Returns true if the response seems to be about the input, false if generic
  static bool responseRelatesToInput(String input, String? responseTitle, String? responseWhat) {
    if (responseTitle == null && responseWhat == null) return false;
    
    final inputLower = input.toLowerCase();
    final titleLower = responseTitle?.toLowerCase() ?? '';
    final whatLower = responseWhat?.toLowerCase() ?? '';
    final combinedResponse = '$titleLower $whatLower';
    
    // Check if response contains key words from input
    // Extract meaningful words from input (3+ chars, not common words)
    final inputWords = inputLower
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 3)
        .where((w) => !_isCommonWord(w))
        .toSet();
    
    if (inputWords.isEmpty) {
      // Input is too short or only common words - can't validate
      return true; // Assume it's fine
    }
    
    // Check if at least some input words appear in response
    final wordsInResponse = inputWords.where((word) => 
      combinedResponse.contains(word)
    ).length;
    
    // If less than 30% of unique meaningful words from input appear in response,
    // it's likely a generic response
    if (inputWords.length > 2 && wordsInResponse / inputWords.length < 0.3) {
      return false;
    }
    
    // Check for generic phrases that indicate the AI didn't understand
    final genericPhrases = [
      'nonsensical text',
      'lacks coherent',
      'does not contain',
      'unable to determine',
      'cannot understand',
      'appears to be',
      'seems to be',
      'transcription error',
      'voice recognition',
      'failed to capture',
    ];
    
    final hasGenericPhrase = genericPhrases.any((phrase) => 
      combinedResponse.contains(phrase)
    );
    
    if (hasGenericPhrase && wordsInResponse == 0) {
      return false; // Generic response about not understanding
    }
    
    return true;
  }
  
  static bool _isCommonWord(String word) {
    const commonWords = {
      'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'her',
      'was', 'one', 'our', 'out', 'day', 'get', 'has', 'him', 'his', 'how',
      'its', 'may', 'new', 'now', 'old', 'see', 'two', 'way', 'who', 'boy',
      'did', 'let', 'put', 'say', 'she', 'too', 'use', 'patient',
      'today', 'saw', 'felt', 'thought', 'learned', 'reflection'
    };
    return commonWords.contains(word);
  }
}

