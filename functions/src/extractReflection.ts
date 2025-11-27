// import { ocrService } from './ocrService';
import { aiService, ReflectionData } from './aiService';
import { phiDetector } from './phiDetector';
import * as functions from 'firebase-functions';
import OpenAI from 'openai';

// Lazy initialization to avoid errors during Firebase analysis
function getOpenAI(): OpenAI {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error('OPENAI_API_KEY environment variable not set');
  }
  return new OpenAI({ apiKey });
}

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
    // Step 1: Extract text using GPT-4o Vision (OCR service disabled)
    functions.logger.info('Step 1: Extracting text using GPT-4o Vision');
    
    // Download file from Firebase Storage
    const fileResponse = await fetch(photoUrl);
    if (!fileResponse.ok) {
      throw new Error(`Failed to download file: ${fileResponse.statusText}`);
    }
    
    const fileBuffer = Buffer.from(await fileResponse.arrayBuffer());
    const base64Image = fileBuffer.toString('base64');

    // Use GPT-4o Vision to extract content
    const visionResponse = await getOpenAI().chat.completions.create({
      model: 'gpt-4o',
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'image_url',
              image_url: {
                url: `data:${mimeType};base64,${base64Image}`,
              },
            },
            {
              type: 'text',
              text: 'Extract all text from this image. Return only the extracted text, no formatting or analysis.',
            },
          ],
        },
      ],
      max_tokens: 2000,
    });

    const extractedText = visionResponse.choices[0]?.message?.content || '';

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


