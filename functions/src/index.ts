import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { extractReflection } from './extractReflection';
import * as apiFunctions from './apiFunctions';

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Cloud Function for extracting reflection from documents/photos
 * 
 * Endpoint: POST /reflections/extract
 * 
 * Request body:
 * {
 *   userId: string,
 *   source: 'photo' | 'document' | 'gallery',
 *   photoUrl: string,
 *   mimeType: string
 * }
 * 
 * Response:
 * {
 *   success: boolean,
 *   reflection: {
 *     title: string,
 *     what: string,
 *     soWhat: string,
 *     nowWhat: string,
 *     tags: string[],
 *     suggestedDomains: number[],
 *     confidence: number
 *   },
 *   metadata: {
 *     processingTime: number,
 *     extractedText: string
 *   }
 * }
 */
export const extractReflectionFromDocument = functions
  .region('europe-west2') // London region for NHS compliance
  .runWith({
    timeoutSeconds: 540, // 9 minutes (max for Cloud Functions)
    memory: '512MB',
    secrets: ['OPENAI_API_KEY'],
  })
  .https.onCall(async (data, context) => {
    const startTime = Date.now();

    try {
      // Authentication check
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      // Validate request
      const { userId, source, photoUrl, mimeType } = data;

      if (!userId || !source || !photoUrl || !mimeType) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Missing required fields: userId, source, photoUrl, mimeType'
        );
      }

      // Verify user owns the request
      if (context.auth.uid !== userId) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'User ID mismatch'
        );
      }

      // Log request
      functions.logger.info('Extraction request received', {
        userId,
        source,
        mimeType,
      });

      // Extract reflection
      const result = await extractReflection({
        photoUrl,
        source,
        mimeType,
        userId,
      });

      const processingTime = (Date.now() - startTime) / 1000;

      functions.logger.info('Extraction completed', {
        userId,
        processingTime,
        confidence: result.confidence,
      });

      return {
        success: true,
        reflection: {
          title: result.title,
          what: result.what,
          soWhat: result.soWhat,
          nowWhat: result.nowWhat,
          tags: result.tags,
          suggestedDomains: result.suggestedDomains,
          confidence: result.confidence,
        },
        metadata: {
          processingTime,
          extractedText: result.extractedText,
        },
      };
    } catch (error: any) {
      functions.logger.error('Extraction failed', {
        error: error.message,
        stack: error.stack,
      });

      // Return user-friendly error
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        'internal',
        'AI extraction failed. Please try again.',
        { details: error.message }
      );
    }
  });

/**
 * Health check endpoint
 */
export const healthCheck = functions
  .region('europe-west2')
  .https.onRequest((req, res) => {
    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
    });
  });

// Export all API functions
export const extract = apiFunctions.extract;
export const transcribeAudio = apiFunctions.transcribeAudio;
export const structureTranscription = apiFunctions.structureTranscription;
export const selfPlay = apiFunctions.selfPlay;
export const reinforce = apiFunctions.reinforce;
export const autoTagCpd = apiFunctions.autoTagCpd;
export const generateLearningLoop = apiFunctions.generateLearningLoop;


