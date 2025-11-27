import OpenAI from 'openai';
import * as functions from 'firebase-functions';

/**
 * Reflection data structure
 */
export interface ReflectionData {
  title: string;
  what: string;
  soWhat: string;
  nowWhat: string;
  tags: string[];
  suggestedDomains: number[];
  confidence: number;
}

/**
 * AI Service using OpenAI GPT-3.5 Turbo
 */
export class AiService {
  private openai: OpenAI | null = null;

  constructor() {
    // Don't initialize OpenAI here - will be initialized lazily
    // This allows Firebase to analyze the code without the secret being set
    this.openai = null as any;
  }

  private getOpenAI(): OpenAI {
    if (!this.openai) {
      const apiKey = process.env.OPENAI_API_KEY;
      if (!apiKey) {
        throw new Error('OPENAI_API_KEY environment variable not set');
      }
      this.openai = new OpenAI({ apiKey });
    }
    return this.openai;
  }

  /**
   * Generate structured reflection from extracted text
   */
  async generateReflection(extractedText: string): Promise<ReflectionData> {
    try {
      functions.logger.info('Starting AI reflection generation', {
        textLength: extractedText.length,
      });

      const prompt = this.buildPrompt(extractedText);

      const completion = await this.getOpenAI().chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: this.getSystemPrompt(),
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
        temperature: 0.7,
        max_tokens: 1500,
        response_format: { type: 'json_object' },
      });

      const responseText = completion.choices[0]?.message?.content;
      if (!responseText) {
        throw new Error('No response from AI');
      }

      // Parse JSON response
      const reflection = JSON.parse(responseText);

      // Validate response structure
      this.validateReflection(reflection);

      // Calculate confidence based on text quality
      const confidence = this.calculateConfidence(extractedText, reflection);

      functions.logger.info('AI generation successful', {
        confidence,
      });

      return {
        title: reflection.title || 'Untitled Reflection',
        what: reflection.what || '',
        soWhat: reflection.soWhat || '',
        nowWhat: reflection.nowWhat || '',
        tags: reflection.tags || [],
        suggestedDomains: reflection.suggestedDomains || [],
        confidence,
      };
    } catch (error: any) {
      functions.logger.error('AI generation failed', {
        error: error.message,
      });
      throw new Error(`AI generation failed: ${error.message}`);
    }
  }

  /**
   * System prompt for the AI
   */
  private getSystemPrompt(): string {
    return `You are an AI assistant helping NHS doctors create structured reflections for their appraisal portfolios.

Your task is to analyze text extracted from documents or photos and create a well-structured reflection using the "What, So What, Now What" framework, which is standard for NHS appraisals.

Guidelines:
1. What: Describe the event/experience objectively (50-100 words)
2. So What: Analyze what was learned, implications, feelings (50-100 words)
3. Now What: Identify concrete action steps (30-50 words, can use bullet points)
4. Keep medical terminology accurate
5. Be supportive and constructive
6. Extract 3-5 relevant tags (single words or short phrases)
7. Suggest relevant GMC domains (1-4):
   - 1: Knowledge, skills, performance
   - 2: Safety and quality
   - 3: Communication, partnership, teamwork
   - 4: Maintaining trust

GMC Good Medical Practice Domains:
- Domain 1: Knowledge, skills and performance
- Domain 2: Safety and quality
- Domain 3: Communication, partnership and teamwork
- Domain 4: Maintaining trust

IMPORTANT: Respond ONLY with valid JSON in this exact format:
{
  "title": "Brief title (5-8 words)",
  "what": "Objective description of what happened",
  "soWhat": "Analysis and learning",
  "nowWhat": "Action plan",
  "tags": ["tag1", "tag2", "tag3"],
  "suggestedDomains": [1, 3]
}`;
  }

  /**
   * Build user prompt with extracted text
   */
  private buildPrompt(extractedText: string): string {
    // Limit text length to avoid token limits
    const maxLength = 2000;
    const truncatedText = extractedText.length > maxLength
      ? extractedText.substring(0, maxLength) + '...'
      : extractedText;

    return `Please analyze the following text and create a structured NHS reflection using the What/So What/Now What framework.

Extracted text:
"""
${truncatedText}
"""

Create a structured reflection as JSON following the exact format specified in the system prompt.`;
  }

  /**
   * Validate reflection structure
   */
  private validateReflection(reflection: any): void {
    if (!reflection.title || typeof reflection.title !== 'string') {
      throw new Error('Invalid reflection: missing or invalid title');
    }
    if (!reflection.what || typeof reflection.what !== 'string') {
      throw new Error('Invalid reflection: missing or invalid what');
    }
    if (!reflection.soWhat || typeof reflection.soWhat !== 'string') {
      throw new Error('Invalid reflection: missing or invalid soWhat');
    }
    if (!reflection.nowWhat || typeof reflection.nowWhat !== 'string') {
      throw new Error('Invalid reflection: missing or invalid nowWhat');
    }
    if (!Array.isArray(reflection.tags)) {
      throw new Error('Invalid reflection: tags must be an array');
    }
    if (!Array.isArray(reflection.suggestedDomains)) {
      throw new Error('Invalid reflection: suggestedDomains must be an array');
    }
  }

  /**
   * Calculate confidence score based on various factors
   */
  private calculateConfidence(
    extractedText: string,
    reflection: ReflectionData
  ): number {
    let score = 0.5; // Base score

    // Factor 1: Text length (longer text = more context = higher confidence)
    if (extractedText.length > 500) score += 0.2;
    else if (extractedText.length > 200) score += 0.1;

    // Factor 2: Reflection completeness
    if (reflection.what.length > 100) score += 0.1;
    if (reflection.soWhat.length > 100) score += 0.1;
    if (reflection.nowWhat.length > 50) score += 0.05;

    // Factor 3: Tags and domains
    if (reflection.tags.length >= 3) score += 0.05;
    if (reflection.suggestedDomains.length > 0) score += 0.05;

    // Factor 4: Medical keywords presence
    const medicalKeywords = [
      'patient', 'doctor', 'nurse', 'clinical', 'diagnosis',
      'treatment', 'ward', 'hospital', 'NHS', 'care', 'safety',
      'communication', 'teamwork', 'learning', 'teaching'
    ];
    const textLower = extractedText.toLowerCase();
    const keywordMatches = medicalKeywords.filter(kw =>
      textLower.includes(kw)
    ).length;
    score += Math.min(keywordMatches * 0.02, 0.1);

    // Clamp to [0, 1]
    return Math.max(0, Math.min(1, score));
  }
}

export const aiService = new AiService();


