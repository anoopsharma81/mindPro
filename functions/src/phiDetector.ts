/**
 * PHI (Protected Health Information) Detector
 * 
 * Detects potential patient-identifiable information in text
 * for NHS GDPR compliance
 */

export interface PhiWarning {
  type: string;
  severity: 'low' | 'medium' | 'high';
  matches: string[];
}

export class PhiDetector {
  /**
   * Detect PHI in text
   */
  detectPhi(text: string): PhiWarning[] {
    const warnings: PhiWarning[] = [];

    // NHS Number pattern (10 digits with spaces)
    const nhsNumbers = this.detectNhsNumbers(text);
    if (nhsNumbers.length > 0) {
      warnings.push({
        type: 'NHS_NUMBER',
        severity: 'high',
        matches: nhsNumbers,
      });
    }

    // Names (Mr/Mrs/Ms/Dr followed by capitalized words)
    const names = this.detectNames(text);
    if (names.length > 0) {
      warnings.push({
        type: 'NAME',
        severity: 'high',
        matches: names,
      });
    }

    // Dates of birth
    const dobs = this.detectDatesOfBirth(text);
    if (dobs.length > 0) {
      warnings.push({
        type: 'DATE_OF_BIRTH',
        severity: 'high',
        matches: dobs,
      });
    }

    // Addresses
    const addresses = this.detectAddresses(text);
    if (addresses.length > 0) {
      warnings.push({
        type: 'ADDRESS',
        severity: 'medium',
        matches: addresses,
      });
    }

    // Phone numbers (UK format)
    const phoneNumbers = this.detectPhoneNumbers(text);
    if (phoneNumbers.length > 0) {
      warnings.push({
        type: 'PHONE_NUMBER',
        severity: 'medium',
        matches: phoneNumbers,
      });
    }

    // Email addresses
    const emails = this.detectEmails(text);
    if (emails.length > 0) {
      warnings.push({
        type: 'EMAIL',
        severity: 'medium',
        matches: emails,
      });
    }

    return warnings;
  }

  /**
   * Check if text contains PHI
   */
  containsPhi(text: string): boolean {
    return this.detectPhi(text).length > 0;
  }

  // Detection methods

  private detectNhsNumbers(text: string): string[] {
    // NHS numbers: 10 digits, often with spaces (e.g., 485 777 3456)
    const pattern = /\b\d{3}\s?\d{3}\s?\d{4}\b/g;
    return this.extractMatches(text, pattern);
  }

  private detectNames(text: string): string[] {
    // Titles followed by capitalized words
    const pattern = /\b(Mr|Mrs|Ms|Miss|Dr|Professor|Prof)\s+[A-Z][a-z]+(\s+[A-Z][a-z]+)*\b/g;
    return this.extractMatches(text, pattern);
  }

  private detectDatesOfBirth(text: string): string[] {
    const patterns = [
      // DD/MM/YYYY, DD-MM-YYYY
      /\b\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4}\b/g,
      // DD MMM YYYY (e.g., 15 Jan 1990)
      /\b\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4}\b/gi,
      // "DOB: ", "Date of Birth: "
      /\b(DOB|Date of Birth):\s*[\w\s\/\-]+/gi,
    ];

    const matches: string[] = [];
    patterns.forEach(pattern => {
      matches.push(...this.extractMatches(text, pattern));
    });
    return matches;
  }

  private detectAddresses(text: string): string[] {
    const patterns = [
      // UK postcodes
      /\b[A-Z]{1,2}\d{1,2}\s?\d[A-Z]{2}\b/gi,
      // "Address: "
      /\bAddress:\s*[^\n]+/gi,
    ];

    const matches: string[] = [];
    patterns.forEach(pattern => {
      matches.push(...this.extractMatches(text, pattern));
    });
    return matches;
  }

  private detectPhoneNumbers(text: string): string[] {
    const patterns = [
      // UK phone numbers
      /\b0\d{10}\b/g, // 07123456789
      /\b0\d{3}\s?\d{3}\s?\d{4}\b/g, // 0123 456 7890
      /\b\+44\s?\d{10}\b/g, // +44 7123456789
    ];

    const matches: string[] = [];
    patterns.forEach(pattern => {
      matches.push(...this.extractMatches(text, pattern));
    });
    return matches;
  }

  private detectEmails(text: string): string[] {
    const pattern = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g;
    return this.extractMatches(text, pattern);
  }

  /**
   * Extract unique matches from text using regex
   */
  private extractMatches(text: string, pattern: RegExp): string[] {
    const matches = text.match(pattern);
    if (!matches) return [];
    
    // Return unique matches
    return [...new Set(matches)];
  }
}

export const phiDetector = new PhiDetector();


