import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import OpenAI from 'openai';

// Lazy initialization of OpenAI to avoid errors during Firebase analysis
function getOpenAI(): OpenAI {
  let apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error('OPENAI_API_KEY environment variable not set');
  }
  // Clean the API key: remove all whitespace (including newlines), "Bearer " prefix, etc.
  apiKey = apiKey.replace(/\s+/g, '').trim(); // Remove all whitespace including newlines
  // Remove "Bearer " prefix if present (case-insensitive)
  if (apiKey.toLowerCase().startsWith('bearer')) {
    apiKey = apiKey.substring(6).trim();
  }
  // Validate API key format (should start with "sk-" and be reasonable length)
  if (!apiKey || !apiKey.startsWith('sk-') || apiKey.length < 20) {
    throw new Error(`OPENAI_API_KEY appears to be invalid. Expected format: sk-... (got ${apiKey ? `${apiKey.substring(0, 10)}...` : 'empty'})`);
  }
  return new OpenAI({ apiKey });
}

/**
 * Extract reflection from document/photo
 * POST /api/extract
 */
export const extract = functions
  .region('europe-west2')
  .runWith({
    timeoutSeconds: 540,
    memory: '512MB',
    secrets: ['OPENAI_API_KEY'],
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { photoUrl, source, mimeType } = data;
    if (!photoUrl || !source || !mimeType) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    try {
      // Download file from Firebase Storage
      const fileResponse = await fetch(photoUrl);
      if (!fileResponse.ok) {
        throw new Error(`Failed to download file: ${fileResponse.statusText}`);
      }
      
      const fileBuffer = Buffer.from(await fileResponse.arrayBuffer());
      const base64Image = fileBuffer.toString('base64');

      // Use GPT-4o Vision to extract content
      const response = await getOpenAI().chat.completions.create({
        model: 'gpt-4o',
        messages: [
          {
            role: 'system',
            content: 'You are an AI assistant that extracts structured reflection content from medical documents, certificates, and photos. Extract key information and structure it into a reflection format.',
          },
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
                text: 'Extract the content from this image and structure it as a reflection with: title, what (description), soWhat (analysis), nowWhat (action plan), tags, and suggested GMC domains (1-4).',
              },
            ],
          },
        ],
        max_tokens: 2000,
      });

      const content = response.choices[0]?.message?.content || '';
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      
      if (!jsonMatch) {
        throw new Error('Failed to parse AI response');
      }

      const extracted = JSON.parse(jsonMatch[0]);

      return {
        success: true,
        reflection: {
          title: extracted.title || 'Extracted Reflection',
          what: extracted.what || '',
          soWhat: extracted.soWhat || '',
          nowWhat: extracted.nowWhat || '',
          tags: extracted.tags || [],
          suggestedDomains: extracted.suggestedDomains || [1],
          confidence: extracted.confidence || 0.8,
        },
      };
    } catch (error: any) {
      functions.logger.error('Extraction failed', error);
      throw new functions.https.HttpsError('internal', 'Extraction failed', error.message);
    }
  });

/**
 * Transcribe audio using Whisper
 * POST /api/reflections/transcribe
 */
export const transcribeAudio = functions
  .region('europe-west2')
  .runWith({
    timeoutSeconds: 540,
    memory: '512MB',
    secrets: ['OPENAI_API_KEY'],
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { audioUrl } = data;
    if (!audioUrl) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing audioUrl');
    }

    try {
      // Download audio from Firebase Storage
      const audioResponse = await fetch(audioUrl);
      if (!audioResponse.ok) {
        throw new Error(`Failed to download audio: ${audioResponse.statusText}`);
      }

      const audioBuffer = Buffer.from(await audioResponse.arrayBuffer());
      
      // Create a File-like object for OpenAI (Node.js compatible)
      // OpenAI SDK expects a File object with name and stream
      const audioFile = new File([audioBuffer], 'audio.m4a', { type: 'audio/m4a' });

      // Transcribe with Whisper
      const transcription = await getOpenAI().audio.transcriptions.create({
        file: audioFile,
        model: 'whisper-1',
        language: 'en',
      });

      return {
        success: true,
        transcription: transcription.text,
      };
    } catch (error: any) {
      functions.logger.error('Transcription failed', error);
      throw new functions.https.HttpsError('internal', 'Transcription failed', error.message);
    }
  });

/**
 * Structure transcription into reflection
 * POST /api/reflections/structure
 */
export const structureTranscription = functions
  .region('europe-west2')
  .runWith({
    timeoutSeconds: 300,
    memory: '512MB',
    secrets: ['OPENAI_API_KEY'],
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { transcription } = data;
    if (!transcription) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing transcription');
    }

    try {
      const response = await getOpenAI().chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: 'You are an AI assistant that structures voice transcriptions into professional medical reflections using the "What? So What? Now What?" framework.',
          },
          {
            role: 'user',
            content: `Structure this transcription into a reflection:\n\n${transcription}\n\nReturn JSON with: title, what, soWhat, nowWhat, tags (array), suggestedDomains (array of numbers 1-4).`,
          },
        ],
        response_format: { type: 'json_object' },
        max_tokens: 1500,
      });

      const content = response.choices[0]?.message?.content || '{}';
      const structured = JSON.parse(content);

      return {
        success: true,
        reflection: {
          title: structured.title || 'Voice Reflection',
          what: structured.what || transcription,
          soWhat: structured.soWhat || '',
          nowWhat: structured.nowWhat || '',
          tags: structured.tags || [],
          suggestedDomains: structured.suggestedDomains || [1],
        },
      };
    } catch (error: any) {
      functions.logger.error('Structuring failed', error);
      throw new functions.https.HttpsError('internal', 'Structuring failed', error.message);
    }
  });

/**
 * Self-play reflection improvement
 * POST /api/reflection/selfplay
 */
export const selfPlay = functions
  .region('europe-west2')
  .runWith({
    timeoutSeconds: 300,
    memory: '512MB',
    secrets: ['OPENAI_API_KEY'],
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { year, title, context: reflectionContext, iterations = 3 } = data;
    if (!year || !title || !reflectionContext) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    try {
      functions.logger.info('Starting self-play', { iterations, title });
      
      // Detect if this is a clinical case (contains medical terms/symptoms)
      const isClinicalCase = /ataxia|diagnosis|symptoms?|patient presented|differential|investigation|treatment|clinical|examination/i.test(reflectionContext);
      
      // System prompt based on content type
      const systemPrompt = isClinicalCase 
        ? `You are an expert NHS clinical educator helping doctors analyze complex medical cases and develop clinical reasoning skills.

Your task: Analyze this clinical case using a structured clinical reasoning framework. Break down the doctor's thinking process and provide insights that enhance diagnostic reasoning and reduce cognitive bias.

Framework to use:
1. INPUT - What clinical information was presented
2. PATTERN RECOGNITION - How the doctor approached the problem
3. ANALYTICAL REASONING - Systematic analysis and differential diagnosis
4. BIAS FILTER - Identify potential cognitive biases (anchoring, confirmation bias, premature closure, etc.)
5. OUTPUT - Clinical decision and learning points

Maintain the doctor's authentic voice but enhance clinical reasoning depth and systematic thinking.`
        : `You are an expert NHS clinical educator helping doctors write high-quality reflections for their appraisal.

GMC reflective practice guidelines:
1. Describe what happened (the experience)
2. Reflect on thoughts and feelings
3. Evaluate what was good and what could be improved
4. Analyze to make sense of the experience
5. Conclude with what was learned
6. Action plan for future practice

Your task: Improve the doctor's reflection using the "What? So what? Now what?" framework. Make it more structured, insightful, and aligned with GMC requirements. Maintain the doctor's authentic voice but enhance depth and learning.`;

      let improved = reflectionContext;
      
      for (let i = 0; i < iterations; i++) {
        functions.logger.info(`Self-play iteration ${i + 1}/${iterations}`, { isClinicalCase });
        
        // User prompt based on content type
        const userPrompt = isClinicalCase
          ? `Analyze this clinical case using the clinical reasoning framework:

Title: ${title}
Year: ${year}

Clinical Case:
${improved}

Structure your analysis as:

1. INPUT
[Summarize key clinical information presented]

2. PATTERN RECOGNITION
[Describe the thinking approach used - pattern recognition, hypothetico-deductive reasoning, systematic approach]

3. ANALYTICAL REASONING
[Systematic analysis, differential diagnosis, key diagnostic features]

4. BIAS FILTER
[Identify potential cognitive biases and how to avoid them]

5. OUTPUT
[Clinical decision, learning points, and future approach]

Provide clear, educational insights that improve clinical reasoning.`
          : `Improve this NHS reflection:

Title: ${title}
Year: ${year}

Original reflection:
${improved}

Enhance it using the "What? So what? Now what?" framework while keeping the doctor's authentic voice.`;

        const response = await getOpenAI().chat.completions.create({
          model: 'gpt-3.5-turbo',
          messages: [
            {
              role: 'system',
              content: systemPrompt,
            },
            {
              role: 'user',
              content: userPrompt,
            },
          ],
          max_tokens: 1500, // Reduced from 2000 for faster response
          temperature: 0.7,
        });

        improved = response.choices[0]?.message?.content || improved;
        functions.logger.info(`Iteration ${i + 1} complete`, { length: improved.length });
      }
      
      functions.logger.info('Self-play complete', { finalLength: improved.length });

      return {
        success: true,
        improved,
        iterations,
      };
    } catch (error: any) {
      functions.logger.error('Self-play failed', error);
      throw new functions.https.HttpsError('internal', 'Self-play failed', error.message);
    }
  });

/**
 * Reinforce reflection rating
 * POST /api/reflection/reinforce
 */
export const reinforce = functions
  .region('europe-west2')
  .runWith({
    timeoutSeconds: 60,
    memory: '256MB',
    secrets: ['OPENAI_API_KEY'],
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { year, rid, rating } = data;
    if (!year || !rid || rating === undefined) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    // Store rating in Firestore for future learning
    try {
      await admin.firestore()
        .collection('users')
        .doc(context.auth.uid)
        .collection('reflections')
        .doc(rid)
        .update({
          userRating: rating,
          ratedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      return {
        success: true,
        message: 'Rating saved',
      };
    } catch (error: any) {
      functions.logger.error('Reinforce failed', error);
      throw new functions.https.HttpsError('internal', 'Failed to save rating', error.message);
    }
  });

/**
 * Auto-tag CPD entry
 * POST /api/cpd
 */
export const autoTagCpd = functions
  .region('europe-west2')
  .runWith({
    timeoutSeconds: 60,
    memory: '256MB',
    secrets: ['OPENAI_API_KEY'],
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { year, title, summary, hours } = data;
    if (!year || !title || !summary) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    try {
      const response = await getOpenAI().chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: 'You are an AI assistant that tags CPD activities with GMC domains (1-4) and relevant keywords.',
          },
          {
            role: 'user',
            content: `Tag this CPD activity:\n\nTitle: ${title}\nSummary: ${summary}\nHours: ${hours}\n\nReturn JSON with: domains (array of numbers 1-4), tags (array of strings).`,
          },
        ],
        response_format: { type: 'json_object' },
        max_tokens: 500,
      });

      const content = response.choices[0]?.message?.content || '{}';
      const tagged = JSON.parse(content);

      return {
        success: true,
        domains: tagged.domains || [1],
        tags: tagged.tags || [],
      };
    } catch (error: any) {
      functions.logger.error('CPD tagging failed', error);
      throw new functions.https.HttpsError('internal', 'Tagging failed', error.message);
    }
  });

/**
 * Generate learning loop from clinical text
 * POST /api/learning-loop/generate
 * Matches backend API: expects clinical_text directly
 */
export const generateLearningLoop = functions
  .region('europe-west2')
  .runWith({
    timeoutSeconds: 300,
    memory: '512MB',
    secrets: ['OPENAI_API_KEY'],
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { clinical_text } = data;
    if (!clinical_text || typeof clinical_text !== 'string' || clinical_text.trim().length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing clinical_text. clinical_text is required and must not be empty'
      );
    }

    try {
      functions.logger.info('Generating Learning Loop', {
        textLength: clinical_text.length,
      });

      // System prompt from Learning Loop framework v1.1
      const systemPrompt = `You are an AI assistant helping NHS doctors create structured reflections using the Metanoia Learning Loop framework v1.1.

This framework is based on cognitive science principles and helps doctors improve clinical reasoning through deliberate practice and metacognition.

## Metanoia Reflection - Learning Loop Framework

The Learning Loop is a scientifically-grounded approach to reflection that emphasizes:
1. **Gate**: Emotional and attentional state during the learning experience
2. **Observation & Action**: What was observed and what action was taken
3. **Encoding**: Pattern recognition and linking to prior knowledge
4. **Prediction**: Forming hypotheses with confidence calibration
5. **Feedback**: Outcome comparison and error detection
6. **Reflection on Bias**: Identifying cognitive biases that may have influenced thinking
7. **Update Rule**: Creating actionable learning rules with spaced repetition

Your output MUST strictly follow the Learning Loop JSON schema with all required fields.`;

      // User prompt template
      const userPrompt = `Create a Learning Loop reflection based on the following clinical experience.

Use the Metanoia Learning Loop framework v1.1 to structure this reflection for deliberate practice and metacognitive improvement.

## Clinical Experience

${clinical_text}

## Instructions

Analyze this clinical experience and create a structured Learning Loop reflection that:

1. **Gate**: Assess the emotional and attentional state during this experience
   - How focused was the doctor?
   - What was the emotional tone of the situation?
   - How intense were the emotions?

2. **Observation & Action**: Extract key observations and the clinical action taken
   - What were the most important clinical observations?
   - What decision or action was taken?

3. **Encoding**: Identify the clinical pattern and connections
   - What clinical pattern or principle does this represent?
   - How does this connect to prior medical knowledge?
   - What tags would help retrieve this learning?

4. **Prediction**: Determine what was predicted
   - What hypothesis or prediction was made?
   - How confident was the clinician?
   - What key features were expected?

5. **Feedback**: Compare prediction to outcome
   - What was the actual outcome?
   - What was the error signal (difference between prediction and reality)?

6. **Reflection on Bias**: Identify cognitive biases
   - What cognitive biases might have been present?
   - How can these biases be countered in future?

7. **Update Rule**: Create actionable learning
   - What if-then rule captures this learning?
   - What micro-practice can be done in 48 hours?
   - When should this learning be reviewed? (2, 7, 30, 90 days)

## Output Format

Respond ONLY with valid JSON following the Metanoia Learning Loop v1.1 schema.

Include all required fields:
- gate (with attention_0_3, emotion_valence_-3_+3, emotion_arousal_0_3, context_note)
- observation_action (with observations array and action)
- encoding (with pattern_name, links_prior_knowledge, chunk_tags)
- prediction (with hypothesis, probability_pct, discriminators_expected, confidence_bucket)
- feedback (with outcome, error_signal)
- reflection_bias (with bias_tags, counter_moves)
- update_rule (with if_then, micro_rep_48h, spaced_plan_days)`;

      functions.logger.info('Calling OpenAI GPT-4o for Learning Loop generation...');

      // Call OpenAI with Learning Loop prompts
      const completion = await getOpenAI().chat.completions.create({
        model: 'gpt-4o',
        messages: [
          {
            role: 'system',
            content: systemPrompt,
          },
          {
            role: 'user',
            content: userPrompt,
          },
        ],
        response_format: { type: 'json_object' },
        temperature: 0.7,
        max_tokens: 3000,
      });

      const content = completion.choices[0]?.message?.content || '{}';
      const learningLoop = JSON.parse(content);

      functions.logger.info('Learning Loop generated successfully', {
        pattern: learningLoop.encoding?.pattern_name || 'N/A',
        predictionConfidence: learningLoop.prediction?.probability_pct || 'N/A',
      });

      return {
        success: true,
        learning_loop: learningLoop, // Match backend response format
      };
    } catch (error: any) {
      functions.logger.error('Learning loop generation failed', {
        error: error.message,
        stack: error.stack,
      });
      throw new functions.https.HttpsError(
        'internal',
        'Learning Loop generation failed',
        error.message
      );
    }
  });

