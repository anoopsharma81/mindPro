// import vision from '@google-cloud/vision';
import * as functions from 'firebase-functions';
// import axios from 'axios';

// Note: OCR service temporarily disabled - using GPT-4o Vision instead
// To enable: npm install @google-cloud/vision axios

/**
 * OCR Service using Google Cloud Vision API
 */
export class OcrService {
  // private client: vision.ImageAnnotatorClient;

  constructor() {
    // this.client = new vision.ImageAnnotatorClient();
  }

  /**
   * Extract text from image using Google Cloud Vision
   */
  async extractTextFromImage(imageUrl: string): Promise<string> {
    try {
      functions.logger.info('Starting OCR extraction', { imageUrl });

      // Download image from Firebase Storage
      // const response = await axios.get(imageUrl, {
      //   responseType: 'arraybuffer',
      // });
      // const imageBuffer = Buffer.from(response.data);

      // Perform text detection
      // const [result] = await this.client.textDetection({
      //   image: { content: imageBuffer },
      // });
      
      // Temporarily disabled - using GPT-4o Vision instead
      throw new Error('OCR service disabled - use GPT-4o Vision');
    } catch (error: any) {
      functions.logger.error('OCR extraction failed', {
        error: error.message,
      });
      throw new Error(`OCR failed: ${error.message}`);
    }
  }

  /**
   * Extract text from PDF document
   */
  async extractTextFromPdf(pdfUrl: string): Promise<string> {
    try {
      functions.logger.info('Starting PDF text extraction', { pdfUrl });

      // Download PDF
      // const response = await axios.get(pdfUrl, {
      //   responseType: 'arraybuffer',
      // });
      // const pdfBuffer = Buffer.from(response.data);

      // Use pdf-parse library
      // const pdfParse = require('pdf-parse');
      // const data = await pdfParse(pdfBuffer);
      
      // Temporarily disabled
      throw new Error('PDF extraction disabled - use GPT-4o Vision');
    } catch (error: any) {
      functions.logger.error('PDF extraction failed', {
        error: error.message,
      });
      throw new Error(`PDF extraction failed: ${error.message}`);
    }
  }

  /**
   * Extract text based on MIME type
   */
  async extractText(fileUrl: string, mimeType: string): Promise<string> {
    if (mimeType.startsWith('image/')) {
      return this.extractTextFromImage(fileUrl);
    } else if (mimeType === 'application/pdf') {
      return this.extractTextFromPdf(fileUrl);
    } else if (mimeType === 'text/plain') {
      // Plain text - just download and return
      // const response = await axios.get(fileUrl);
      // return response.data;
      throw new Error('Text extraction disabled - use GPT-4o Vision');
    } else {
      throw new Error(`Unsupported MIME type: ${mimeType}`);
    }
  }
}

export const ocrService = new OcrService();


