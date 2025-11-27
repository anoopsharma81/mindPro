import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import OpenAI from 'openai';
import admin from 'firebase-admin';
import { readFileSync } from 'fs';
import { createRequire } from 'module';

// Import CommonJS modules
const require = createRequire(import.meta.url);
const PDFExtract = require('pdf.js-extract').PDFExtract;
const mammoth = require('mammoth');

// Initialize PDF extractor
const pdfExtract = new PDFExtract();

// Load environment variables
dotenv.config();

// Initialize Express
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);
    
    // Allow localhost and 127.0.0.1 for development
    if (origin.includes('localhost') || origin.includes('127.0.0.1')) {
      return callback(null, true);
    }
    
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true
}));
app.use(express.json());

// Initialize Firebase Admin
let isFirebaseInitialized = false;
if (process.env.NODE_ENV === 'production' || process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
  try {
    const serviceAccount = JSON.parse(
      readFileSync(process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './firebase-service-account.json', 'utf8')
    );
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    isFirebaseInitialized = true;
    console.log('✅ Firebase Admin initialized');
  } catch (error) {
    console.warn('⚠️  Firebase Admin: Could not load service account key');
    console.warn('   Auth verification will be skipped. This is OK for development.');
  }
} else {
  console.log('🔧 Development mode: Running without Firebase Admin auth');
  console.log('   To enable auth verification: Set FIREBASE_SERVICE_ACCOUNT_PATH in .env');
}

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

// Verify Firebase token middleware
async function verifyFirebaseToken(req, res, next) {
  // Skip in development if Firebase not configured
  if (!admin.apps.length) {
    console.log('⚠️  Skipping auth verification (development mode)');
    req.user = { uid: 'dev-user', email: 'dev@example.com' };
    return next();
  }

  // Allow requests without auth header in development
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    console.log('⚠️  No auth header, allowing in development mode');
    req.user = { uid: 'dev-user', email: 'dev@example.com' };
    return next();
  }

  const token = authHeader.split('Bearer ')[1];
  
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Token verification failed:', error);
    return res.status(401).json({ error: 'Unauthorized: Invalid token' });
  }
}

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Metanoia Backend API',
    openai: !!process.env.OPENAI_API_KEY,
    firebase: admin.apps.length > 0
  });
});

// Document/Photo extraction endpoint
app.post('/api/extract', verifyFirebaseToken, async (req, res) => {
  try {
    const { photoUrl, source, mimeType } = req.body;
    
    if (!photoUrl) {
      return res.status(400).json({ error: 'photoUrl is required' });
    }

    console.log(`📄 Extracting from ${source}: ${photoUrl.substring(0, 100)}...`);
    console.log(`   MIME type: ${mimeType}`);

    // Download the file first
    const fileResponse = await fetch(photoUrl);
    if (!fileResponse.ok) {
      throw new Error(`Failed to download file: ${fileResponse.statusText}`);
    }
    
    const fileBuffer = Buffer.from(await fileResponse.arrayBuffer());
    console.log(`   File size: ${(fileBuffer.length / 1024).toFixed(2)} KB`);

    let extractedText = '';
    let processingMethod = '';

    // Determine file type and extract content
    const mime = (mimeType || '').toLowerCase();
    
    // Handle PDFs
    if (mime.includes('pdf')) {
      console.log('📑 Processing PDF document...');
      try {
        const pdfData = await pdfExtract.extractBuffer(fileBuffer);
        const textParts = [];
        
        for (const page of pdfData.pages) {
          const pageText = page.content
            .map(item => item.str || '')
            .join(' ');
          textParts.push(pageText);
        }
        
        extractedText = textParts.join('\n\n').trim();
        processingMethod = 'pdf-text-extraction';
        console.log(`   Extracted ${extractedText.length} characters from ${pdfData.pages.length} pages`);
      } catch (pdfError) {
        console.error('   PDF extraction failed:', pdfError.message);
        return res.status(400).json({ 
          error: 'PDF processing failed',
          details: 'Could not extract text from PDF. It may be scanned or corrupted. Try uploading as an image instead.'
        });
      }
    }
    // Handle Word documents
    else if (mime.includes('word') || mime.includes('msword') || mime.includes('officedocument')) {
      console.log('📝 Processing Word document...');
      try {
        const result = await mammoth.extractRawText({ buffer: fileBuffer });
        extractedText = result.value.trim();
        processingMethod = 'word-text-extraction';
        console.log(`   Extracted ${extractedText.length} characters from Word doc`);
      } catch (wordError) {
        console.error('   Word extraction failed:', wordError.message);
        return res.status(400).json({ 
          error: 'Word document processing failed',
          details: 'Could not extract text from Word document.'
        });
      }
    }
    // Handle plain text files
    else if (mime.includes('text/plain')) {
      console.log('📄 Processing text file...');
      extractedText = fileBuffer.toString('utf-8').trim();
      processingMethod = 'text-file';
      console.log(`   Read ${extractedText.length} characters from text file`);
    }
    // Handle images (existing Vision API approach)
    else if (mime.includes('image') || mime.includes('png') || mime.includes('jpeg') || mime.includes('jpg') || mime.includes('gif') || mime.includes('webp')) {
      console.log('🖼️  Processing image with Vision API...');
      processingMethod = 'vision-api';
      
      const completion = await openai.chat.completions.create({
        model: 'gpt-4o',
        messages: [
          {
            role: 'system',
            content: `You are an expert at extracting reflection content from documents and photos. 
Extract the key information and structure it into a reflection using the "What? So what? Now what?" framework.
Return a JSON object with: title, what, soWhat, nowWhat, tags (array), suggestedDomains (array of GMC domain numbers 1-4), confidence (0-1).`
          },
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: `Extract reflection content from this ${source}. If it's handwritten notes, certificates, or learning materials, create a structured reflection from it.`
              },
              {
                type: 'image_url',
                image_url: { url: photoUrl }
              }
            ]
          }
        ],
        response_format: { type: 'json_object' },
        max_tokens: 2000
      });

      const result = JSON.parse(completion.choices[0].message.content);
      console.log(`✅ Vision extraction completed (confidence: ${result.confidence || 'N/A'})`);

      return res.json({
        reflection: {
          title: result.title || 'Untitled Reflection',
          what: result.what || '',
          soWhat: result.soWhat || '',
          nowWhat: result.nowWhat || '',
          tags: result.tags || [],
          suggestedDomains: result.suggestedDomains || [],
          confidence: result.confidence || 0.5
        },
        metadata: {
          source,
          extractedText: result.extractedText || null,
          processingMethod
        }
      });
    }
    else {
      return res.status(400).json({ 
        error: 'Unsupported file format',
        details: `Supported: PDF, Word (.doc/.docx), Text (.txt), Images (PNG/JPEG/GIF/WebP). Received: ${mimeType}`
      });
    }

    // For text-based documents (PDF, Word, Text), process with GPT
    if (extractedText) {
      if (extractedText.length < 10) {
        return res.status(400).json({ 
          error: 'No text found',
          details: 'Document appears to be empty or is a scanned image. Try uploading as a photo instead.'
        });
      }

      console.log('🤖 Processing extracted text with GPT-4o...');
      
      const completion = await openai.chat.completions.create({
        model: 'gpt-4o',
        messages: [
          {
            role: 'system',
            content: `You are an expert at extracting reflection content from documents. 
Extract the key information and structure it into a reflection using the "What? So what? Now what?" framework.
Return a JSON object with: title, what, soWhat, nowWhat, tags (array), suggestedDomains (array of GMC domain numbers 1-4), confidence (0-1).`
          },
          {
            role: 'user',
            content: `Extract and structure this content into a medical reflection:\n\n${extractedText}`
          }
        ],
        response_format: { type: 'json_object' },
        max_tokens: 2000
      });

      const result = JSON.parse(completion.choices[0].message.content);
      console.log(`✅ Text extraction completed (confidence: ${result.confidence || 'N/A'})`);

      return res.json({
        reflection: {
          title: result.title || 'Untitled Reflection',
          what: result.what || '',
          soWhat: result.soWhat || '',
          nowWhat: result.nowWhat || '',
          tags: result.tags || [],
          suggestedDomains: result.suggestedDomains || [],
          confidence: result.confidence || 0.7
        },
        metadata: {
          source,
          extractedText: extractedText.substring(0, 500), // First 500 chars for reference
          processingMethod
        }
      });
    }

  } catch (error) {
    console.error('❌ Extraction failed:', error);
    
    let errorMessage = 'Extraction failed';
    let errorDetails = error.message;
    
    if (error.message && error.message.includes('unsupported image')) {
      errorMessage = 'Unsupported file format';
      errorDetails = 'Please upload a supported file: PDF, Word, Text, or Image (PNG/JPEG/GIF/WebP).';
    }
    
    res.status(500).json({ 
      error: errorMessage, 
      details: errorDetails 
    });
  }
});

// Self-play reflection improvement endpoint
app.post('/api/reflection/selfplay', verifyFirebaseToken, async (req, res) => {
  try {
    const { year, title, context, iterations = 3 } = req.body;
    
    if (!context) {
      return res.status(400).json({ error: 'Context is required' });
    }

    console.log(`🤖 Running self-play for: ${title}`);

    // Detect if this is a clinical case (contains medical terms/symptoms)
    const isClinicalCase = /ataxia|diagnosis|symptoms?|patient presented|differential|investigation|treatment|clinical|examination/i.test(context);

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

    const userPrompt = isClinicalCase
      ? `Analyze this clinical case using the clinical reasoning framework:

Title: ${title}
Year: ${year}

Clinical Case:
${context}

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
${context}

Enhance it using the "What? So what? Now what?" framework while keeping the doctor's authentic voice.`;

    // Call OpenAI API with timeout
    const completion = await Promise.race([
      openai.chat.completions.create({
        model: "gpt-3.5-turbo",  // Using GPT-3.5 (available to all accounts)
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt }
        ],
        temperature: 0.7,
        max_tokens: 1500
      }),
      new Promise((_, reject) => 
        setTimeout(() => reject(new Error('OpenAI API timeout')), 30000)
      )
    ]);

    const improvedText = completion.choices[0].message.content;

    // Calculate a simple quality score (mock for now)
    const score = Math.min(10, 5 + (improvedText.length / context.length) * 2);

    // Return improved reflection
    res.json({
      improved: improvedText,
      score: parseFloat(score.toFixed(1)),
      iterations: [
        { version: 1, text: improvedText }
      ],
      usage: {
        prompt_tokens: completion.usage.prompt_tokens,
        completion_tokens: completion.usage.completion_tokens,
        total_tokens: completion.usage.total_tokens
      }
    });

    console.log(`✅ Self-play completed (${completion.usage.total_tokens} tokens)`);

  } catch (error) {
    console.error('Self-play error:', error);
    res.status(500).json({ 
      error: 'Self-play failed', 
      message: error.message 
    });
  }
});

// Reinforce reflection with rating
app.post('/api/reflection/reinforce', verifyFirebaseToken, async (req, res) => {
  try {
    const { year, rid, rating } = req.body;
    
    console.log(`📊 Reinforcement learning: Reflection ${rid} rated ${rating}/10`);
    
    // In a real implementation, this would:
    // 1. Store the rating
    // 2. Update the AI model with this feedback
    // 3. Improve future suggestions
    
    res.json({ 
      success: true,
      message: 'Rating recorded for future model improvements'
    });

  } catch (error) {
    console.error('Reinforce error:', error);
    res.status(500).json({ error: 'Reinforce failed', message: error.message });
  }
});

// Auto-tag CPD entry
app.post('/api/cpd', verifyFirebaseToken, async (req, res) => {
  try {
    const { year, title, summary, hours, date } = req.body;
    
    console.log(`🏷️  Auto-tagging CPD: ${title}`);

    const systemPrompt = `You are an NHS CPD categorization expert. Analyze CPD activities and suggest:
1. Type (course, reading, audit, teaching, other)
2. GMC domains (1-4): 1=Professional Knowledge, 2=Safety & Quality, 3=Communication, 4=Working with Colleagues
3. Impact statement (how this improves patient care)

Return JSON only.`;

    const userPrompt = `Categorize this CPD activity:
Title: ${title}
Summary: ${summary || 'No summary provided'}
Hours: ${hours}
Date: ${date}

Return JSON: { "type": "...", "domains": [1,2,3,4], "impact": "..." }`;

    const completion = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",  // Using GPT-3.5 (available to all accounts)
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt }
      ],
      response_format: { type: "json_object" },
      temperature: 0.3
    });

    const result = JSON.parse(completion.choices[0].message.content);

    res.json({
      autoTags: {
        suggestedType: result.type,
        domains: result.domains,
        impact: result.impact
      }
    });

    console.log(`✅ CPD auto-tagged`);

  } catch (error) {
    console.error('CPD auto-tag error:', error);
    res.status(500).json({ error: 'Auto-tag failed', message: error.message });
  }
});

// Export endpoint (placeholder - would generate DOCX/PDF)
app.post('/api/export', verifyFirebaseToken, async (req, res) => {
  try {
    const { year, sections, format } = req.body;
    
    console.log(`📄 Export requested for year ${year} in ${format} format`);
    
    // In a real implementation, this would:
    // 1. Fetch user data from Firestore
    // 2. Generate DOCX/PDF using a library
    // 3. Upload to Firebase Storage
    // 4. Return signed URL
    
    res.json({
      exportId: `export-${Date.now()}`,
      status: 'processing',
      message: 'Export generation not yet implemented. Use local markdown export for now.'
    });

  } catch (error) {
    console.error('Export error:', error);
    res.status(500).json({ error: 'Export failed', message: error.message });
  }
});

// Transcribe audio using Whisper API
app.post('/api/reflections/transcribe', verifyFirebaseToken, async (req, res) => {
  try {
    const { audioUrl } = req.body;
    
    if (!audioUrl) {
      return res.status(400).json({ error: 'audioUrl is required' });
    }

    console.log(`🎤 Transcribing audio from: ${audioUrl.substring(0, 70)}...`);

    // Download the audio file from Firebase Storage
    const audioResponse = await fetch(audioUrl);
    if (!audioResponse.ok) {
      throw new Error(`Failed to download audio: ${audioResponse.statusText}`);
    }
    
    const audioBuffer = await audioResponse.arrayBuffer();
    const audioBlob = new Blob([audioBuffer], { type: 'audio/m4a' });
    
    // Create File object for OpenAI (required format)
    const audioFile = new File([audioBlob], 'audio.m4a', { type: 'audio/m4a' });

    // Use OpenAI Whisper to transcribe the audio
    const transcription = await openai.audio.transcriptions.create({
      file: audioFile,
      model: 'whisper-1',
      language: 'en',
      response_format: 'verbose_json',
    });
    
    console.log(`✅ Transcription completed (${transcription.text.length} characters, confidence: ${transcription.segments?.length > 0 ? 'calculated' : 'N/A'})`);

    res.json({
      text: transcription.text,
      confidence: transcription.segments?.length > 0 
        ? transcription.segments.reduce((sum, seg) => sum + (seg.confidence || 0), 0) / transcription.segments.length
        : 0.8,
      language: transcription.language || 'en',
      duration: transcription.duration || 0,
    });
  } catch (error) {
    console.error('❌ Transcription failed:', error);
    res.status(500).json({ 
      error: 'Transcription failed', 
      details: error.message 
    });
  }
});

// Structure voice transcription into reflection format
app.post('/api/reflections/structure', verifyFirebaseToken, async (req, res) => {
  try {
    const { transcription } = req.body;
    
    if (!transcription) {
      return res.status(400).json({ error: 'transcription is required' });
    }

    console.log(`📝 Structuring transcription (${transcription.length} characters)...`);

    // Use OpenAI to structure the transcription
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: `You are an expert NHS clinical educator helping doctors structure voice-recorded reflections.

Convert the voice transcription into a structured reflection using the "What? So What? Now what?" framework.

Return JSON with:
{
  "title": "Brief, descriptive title",
  "what": "What happened? (objective description)",
  "soWhat": "So what? (analysis, learning, significance)",
  "nowWhat": "Now what? (action plan for future)",
  "tags": ["tag1", "tag2"],
  "suggestedDomains": [1, 2] // GMC domains 1-4
}`
        },
        {
          role: 'user',
          content: `Structure this voice transcription into a reflection:\n\n${transcription}`
        }
      ],
      response_format: { type: 'json_object' },
      max_tokens: 1500
    });

    const result = JSON.parse(completion.choices[0].message.content);
    
    console.log(`✅ Structured reflection created: "${result.title}"`);

    res.json({
      title: result.title || 'Voice Reflection',
      what: result.what || transcription,
      soWhat: result.soWhat || '',
      nowWhat: result.nowWhat || '',
      tags: result.tags || [],
      suggestedDomains: result.suggestedDomains || [],
    });
  } catch (error) {
    console.error('❌ Structuring failed:', error);
    res.status(500).json({ 
      error: 'Structuring failed', 
      details: error.message 
    });
  }
});

// ==============================================================================
// LEARNING LOOP GENERATION
// ==============================================================================
// Generate Learning Loop from reflection using cognitive science framework
app.post('/api/learning-loop/generate', verifyFirebaseToken, async (req, res) => {
  try {
    const { clinical_text } = req.body;
    
    console.log('🧠 Generating Learning Loop...');
    
    if (!clinical_text || clinical_text.trim().length === 0) {
      return res.status(400).json({ 
        error: 'Missing clinical_text',
        details: 'clinical_text is required and must not be empty'
      });
    }
    
    console.log(`   Processing ${clinical_text.length} characters of clinical text`);
    
    // Load prompts from files
    const systemPrompt = readFileSync('./prompts/learning_loop_system.txt', 'utf8');
    const userPromptTemplate = readFileSync('./prompts/learning_loop_user.txt', 'utf8');
    
    // Replace template variable
    const userPrompt = userPromptTemplate.replace('{{clinical_text}}', clinical_text);
    
    console.log('   Calling OpenAI GPT-4o for Learning Loop generation...');
    
    // Call OpenAI with Learning Loop prompts (with timeout for long-running requests)
    const completion = await Promise.race([
      openai.chat.completions.create({
        model: 'gpt-4o',
        messages: [
          {
            role: 'system',
            content: systemPrompt
          },
          {
            role: 'user',
            content: userPrompt
          }
        ],
        response_format: { type: 'json_object' },
        temperature: 0.7,
        max_tokens: 3000
      }),
      new Promise((_, reject) => 
        setTimeout(() => reject(new Error('OpenAI API timeout after 90 seconds')), 90000)
      )
    ]);
    
    const learningLoop = JSON.parse(completion.choices[0].message.content);
    
    console.log(`✅ Learning Loop generated successfully`);
    console.log(`   Pattern: ${learningLoop.encoding?.pattern_name || 'N/A'}`);
    console.log(`   Prediction confidence: ${learningLoop.prediction?.probability_pct || 'N/A'}%`);
    
    res.json({
      success: true,
      learning_loop: learningLoop
    });
    
  } catch (error) {
    console.error('❌ Learning Loop generation failed:', error);
    res.status(500).json({ 
      error: 'Learning Loop generation failed', 
      details: error.message 
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`\n🚀 Metanoia Backend API running on http://localhost:${PORT}`);
  console.log(`📡 Health check: http://localhost:${PORT}/api/health`);
  console.log(`\n✅ OpenAI API: ${process.env.OPENAI_API_KEY ? 'Configured' : '❌ NOT CONFIGURED'}`);
  console.log(`✅ Firebase Admin: ${admin.apps.length > 0 ? 'Configured' : '⚠️  Running without auth'}`);
  console.log(`\nReady for requests! 🎉\n`);
});

// Error handling
process.on('unhandledRejection', (error) => {
  console.error('Unhandled rejection:', error);
});

