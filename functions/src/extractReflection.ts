import { ocrService } from './ocrService';
import { aiService, ReflectionData } from './aiService';
import { phiDetector } from './phiDetector';
import * as functions from 'firebase-functions';

export interface ExtractionRequest {
  photoUrl: string;
  source: 'photo' | 'document' | 'gallery';
  mimeType: string;
  userId: string;
}

export interface ExtractionResult extends ReflectionData {
  extractedText: string;
}

/**
 * Main orchestrator for reflection extraction
 */
export async function extractReflection(
  request: ExtractionRequest
): Promise<ExtractionResult> {
  const { photoUrl, mimeType } = request;

  try {
    // Step 1: Extract text using OCR/PDF parsing
    functions.logger.info('Step 1: Extracting text');
    const extractedText = await ocrService.extractText(photoUrl, mimeType);

    if (!extractedText || extractedText.trim().length < 10) {
      throw new Error('No meaningful text found in document');
    }

    functions.logger.info('Text extracted successfully', {
      length: extractedText.length,
    });

    // Step 2: Check for PHI (Protected Health Information)
    functions.logger.info('Step 2: Checking for PHI');
    const phiWarnings = phiDetector.detectPhi(extractedText);
    
    if (phiWarnings.length > 0) {
      functions.logger.warn('PHI detected in text', {
        warningCount: phiWarnings.length,
        warnings: phiWarnings.map(w => w.type),
      });
      // Note: We still continue but log the warning
      // The frontend will also check and warn the user
    }

    // Step 3: Generate structured reflection using AI
    functions.logger.info('Step 3: Generating reflection with AI');
    const reflection = await aiService.generateReflection(extractedText);

    functions.logger.info('Reflection generated successfully', {
      confidence: reflection.confidence,
      tagsCount: reflection.tags.length,
      domainsCount: reflection.suggestedDomains.length,
    });

    // Return complete result
    return {
      ...reflection,
      extractedText,
    };
  } catch (error: any) {
    functions.logger.error('Extraction failed', {
      error: error.message,
      stack: error.stack,
    });
    throw error;
  }
}


