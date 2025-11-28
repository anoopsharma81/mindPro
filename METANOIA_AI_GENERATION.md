# Metanoia Reflection AI Generation Feature

## Overview

This feature allows users to generate structured Metanoia reflections from raw case notes using AI. Users can input clinical case notes or scenarios, and the system will automatically fill out all Metanoia reflection fields using the Metanoia framework.

## Components

### 1. Frontend (Flutter)

**File**: `lib/features/metanoia/presentation/metanoia_reflection_edit_page.dart`

- Added `_generateFromInput()` method that:
  - Shows a dialog for case notes input
  - Calls the API service to generate reflection
  - Populates all form fields with the generated content

- Added `_CaseNotesInputDialog` widget for user input

- Added "Generate from case notes" button (✨ icon) in the AppBar

**File**: `lib/services/api_service.dart`

- Added `generateMetanoiaReflection()` method that:
  - Calls Firebase Function `generateMetanoiaReflection` (if using Firebase)
  - Falls back to HTTP endpoint `/metanoia/generate` (if using backend server)
  - Handles errors and timeouts

### 2. Backend Prompts

**Files**: 
- `backend/prompts/metanoia_reflection_system.txt` - System prompt for AI
- `backend/prompts/metanoia_reflection_user.txt` - User prompt template

The system prompt instructs the AI to:
- Analyze raw case notes
- Generate structured Metanoia reflection with all required fields
- Follow the Metanoia framework (Pattern Recognition, Analytical Reasoning, Bias Filtering, Learning, Retrieval Plan)
- Return valid JSON matching the MetanoiaReflection schema

### 3. Backend Implementation (To Be Added)

You need to implement one of the following:

#### Option A: Firebase Cloud Function

Create `functions/src/generateMetanoiaReflection.ts`:

```typescript
import { onCall } from 'firebase-functions/v2/https';
import { AiService } from './aiService';
import * as fs from 'fs';
import * as path from 'path';

export const generateMetanoiaReflection = onCall(async (request) => {
  const { caseNotes, domain } = request.data;
  
  if (!caseNotes || caseNotes.trim().length < 50) {
    throw new Error('caseNotes is required and must be at least 50 characters');
  }

  const aiService = new AiService();
  
  // Load prompts
  const systemPrompt = fs.readFileSync(
    path.join(__dirname, '../../backend/prompts/metanoia_reflection_system.txt'),
    'utf8'
  );
  const userPromptTemplate = fs.readFileSync(
    path.join(__dirname, '../../backend/prompts/metanoia_reflection_user.txt'),
    'utf8'
  );
  
  // Replace template variables
  let userPrompt = userPromptTemplate.replace('{{caseNotes}}', caseNotes);
  if (domain) {
    userPrompt = userPrompt.replace('{{#if domain}}', '');
    userPrompt = userPrompt.replace('{{/if}}', '');
    userPrompt = userPrompt.replace('Clinical domain: {{domain}}', `Clinical domain: ${domain}`);
  } else {
    userPrompt = userPrompt.replace(/{{#if domain}}[\s\S]*?{{{\/if}}}/g, '');
  }
  
  // Generate reflection using OpenAI
  const reflection = await aiService.generateMetanoiaReflection(
    systemPrompt,
    userPrompt
  );
  
  return reflection;
});
```

#### Option B: Backend Server Endpoint

Add to `backend/server.js`:

```javascript
// Generate Metanoia reflection from case notes
app.post('/api/metanoia/generate', verifyFirebaseToken, async (req, res) => {
  try {
    const { caseNotes, domain } = req.body;
    
    if (!caseNotes || caseNotes.trim().length < 50) {
      return res.status(400).json({ 
        error: 'caseNotes is required and must be at least 50 characters'
      });
    }

    console.log('🧠 Generating Metanoia reflection...');
    
    // Load prompts
    const systemPrompt = readFileSync('./prompts/metanoia_reflection_system.txt', 'utf8');
    const userPromptTemplate = readFileSync('./prompts/metanoia_reflection_user.txt', 'utf8');
    
    // Replace template variables
    let userPrompt = userPromptTemplate.replace('{{caseNotes}}', caseNotes);
    if (domain) {
      userPrompt = userPrompt.replace('{{#if domain}}', '');
      userPrompt = userPrompt.replace('{{/if}}', '');
      userPrompt = userPrompt.replace('Clinical domain: {{domain}}', `Clinical domain: ${domain}`);
    } else {
      userPrompt = userPrompt.replace(/{{#if domain}}[\s\S]*?{{{\/if}}}/g, '');
    }
    
    // Call OpenAI
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ],
      response_format: { type: 'json_object' },
      temperature: 0.7,
      max_tokens: 3000
    });
    
    const reflection = JSON.parse(completion.choices[0].message.content);
    
    // Add metadata
    reflection.id = require('uuid').v4();
    reflection.createdAt = new Date().toISOString();
    if (domain) reflection.domain = domain;
    
    console.log('✅ Metanoia reflection generated');
    
    res.json(reflection);
  } catch (error) {
    console.error('❌ Metanoia generation failed:', error);
    res.status(500).json({ 
      error: 'Metanoia reflection generation failed',
      details: error.message 
    });
  }
});
```

## Usage

1. Navigate to "New Metanoia Reflection" page
2. Click the ✨ (auto_awesome) icon in the AppBar
3. Enter case notes in the dialog (minimum 50 characters)
4. Click "Generate"
5. All fields will be automatically populated with AI-generated content
6. Review and edit as needed
7. Save the reflection

## JSON Response Format

The API must return a JSON object matching the `MetanoiaReflection` schema:

```json
{
  "id": "uuid",
  "caseTitle": "Brief title",
  "caseDescription": "Case summary",
  "patternRecognition": {
    "keyFeatures": ["feature1", "feature2"],
    "prototype": "If pattern then..."
  },
  "analyticalReasoning": {
    "initialDifferential": ["dx1", "dx2"],
    "discriminatorsForDiagnosis": ["disc1", "disc2"],
    "managementLogic": ["step1", "step2"]
  },
  "biasFiltering": {
    "identifiedBiases": ["bias1", "bias2"],
    "correctiveRules": ["rule1", "rule2"]
  },
  "learning": {
    "encoding": "What to store",
    "prediction": "Future behavior",
    "update": "Mental model change"
  },
  "retrievalPlan": {
    "6_weeks": "6 week review",
    "6_months": "6 month review",
    "12_months": "12 month review"
  },
  "createdAt": "ISO8601 timestamp",
  "domain": "Optional domain"
}
```

## Next Steps

1. Implement the backend endpoint/function (choose Option A or B above)
2. Test with sample case notes
3. Deploy backend changes
4. Test end-to-end from Flutter app

