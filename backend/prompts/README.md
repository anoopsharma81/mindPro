# AI Prompts Directory

This directory contains all the AI prompts used in the Metanoia backend.

## Structure

Each AI feature has two files:
- `*_system.txt` - System prompt (defines the AI's role and behavior)
- `*_user.txt` - User prompt template (the actual request with placeholders)

## Prompt Files

### 1. Clinical Case Analysis
- `clinical_case_system.txt` - System prompt for clinical reasoning
- `clinical_case_user.txt` - User prompt template with 5-step framework

**Variables**: `{{title}}`, `{{year}}`, `{{context}}`

**Framework**:
1. INPUT - Clinical information presented
2. PATTERN RECOGNITION - Thinking approach (changed from COGNITIVE PROCESS)
3. ANALYTICAL REASONING - Differential diagnosis
4. BIAS FILTER - Cognitive bias identification
5. OUTPUT - Clinical decision & learning

### 2. General Reflection Improvement
- `general_reflection_system.txt` - System prompt for GMC-aligned reflections
- `general_reflection_user.txt` - User prompt template

**Variables**: `{{title}}`, `{{year}}`, `{{context}}`

**Framework**: "What? So What? Now What?"

### 3. Voice Transcription Structuring
- `voice_structure_system.txt` - System prompt for voice-to-reflection
- `voice_structure_user.txt` - User prompt template

**Variables**: `{{transcription}}`

**Output**: JSON with title, what, soWhat, nowWhat, tags, suggestedDomains

### 4. Document/Photo Extraction
- `document_extraction_system.txt` - System prompt for vision AI
- `document_extraction_user.txt` - User prompt template

**Variables**: `{{source}}`

**Note**: Image is attached separately via OpenAI vision API

### 5. CPD Auto-Tagging
- `cpd_tagging_system.txt` - System prompt for CPD categorization
- `cpd_tagging_user.txt` - User prompt template

**Variables**: `{{title}}`, `{{summary}}`, `{{hours}}`, `{{date}}`

**Output**: JSON with type, domains, impact

## Usage in Code

Currently, prompts are hardcoded in `server.js`. To use these files:

```javascript
import { readFileSync } from 'fs';

// Load prompt templates
const clinicalSystemPrompt = readFileSync('./prompts/clinical_case_system.txt', 'utf8');
const clinicalUserPrompt = readFileSync('./prompts/clinical_case_user.txt', 'utf8');

// Replace variables
const userPrompt = clinicalUserPrompt
  .replace('{{title}}', title)
  .replace('{{year}}', year)
  .replace('{{context}}', context);

// Use in OpenAI call
const completion = await openai.chat.completions.create({
  model: 'gpt-3.5-turbo',
  messages: [
    { role: 'system', content: clinicalSystemPrompt },
    { role: 'user', content: userPrompt }
  ]
});
```

## Editing Prompts

### Best Practices
1. **Keep prompts focused** - One clear task per prompt
2. **Use examples** - Show expected output format
3. **Set constraints** - Define limits (word count, format, etc.)
4. **Test changes** - Verify with real data before deploying
5. **Version control** - Track prompt changes in git

### Testing Prompts
```bash
# Test locally
cd backend
node server.js

# Make API call with test data
curl -X POST http://localhost:3001/api/reflection/selfplay \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","year":"2025","context":"Test case..."}'
```

## GMC Domains Reference

1. **Professional Knowledge & Skills** - Clinical knowledge, diagnosis, treatment
2. **Safety & Quality** - Patient safety, quality improvement, risk management
3. **Communication & Teamwork** - Patient communication, teamwork, shared decisions
4. **Maintaining Trust** - Professional behavior, ethics, respect

## Framework Reference

### What? So What? Now What?
- **What?** - Describe objectively what happened
- **So What?** - Analyze and reflect on meaning/learning
- **Now What?** - Action plan for future practice

### Clinical Reasoning (5-Step)
1. **INPUT** - Chief complaint, history, examination, investigations
2. **PATTERN RECOGNITION** - Recognition patterns, reasoning approach
3. **ANALYTICAL REASONING** - Differential diagnosis, diagnostic features
4. **BIAS FILTER** - Anchoring, confirmation bias, premature closure
5. **OUTPUT** - Diagnosis, management, safety netting, learning

## Model Settings

- **GPT-4o-mini**: Voice structuring (cost-effective, good quality)
- **GPT-4o**: Vision tasks (document extraction)
- **GPT-3.5-turbo**: Self-play, CPD (cost-effective for longer content)
- **Whisper-1**: Audio transcription (no custom prompts)

## Temperature Settings

- **0.3**: CPD categorization (consistency needed)
- **0.7**: Reflections and clinical reasoning (creativity needed)

## Future Improvements

1. Load prompts from files instead of hardcoding
2. Add prompt versioning system
3. A/B test different prompt variations
4. Collect user feedback on AI quality
5. Fine-tune models with real NHS data
6. Add prompt templates for new features
7. Implement prompt caching for performance
8. Add multi-language support

## Contributing

When adding new prompts:
1. Create `feature_system.txt` and `feature_user.txt`
2. Document variables and output format
3. Add usage example in this README
4. Test thoroughly before deploying
5. Update `AI_PROMPTS_DOCUMENTATION.md`

