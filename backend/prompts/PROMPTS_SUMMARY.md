# AI Prompts Quick Reference

## 📁 Files Created

All prompts are now stored in individual text files in `backend/prompts/`:

### Clinical Case Analysis
- ✅ `clinical_case_system.txt` - System prompt
- ✅ `clinical_case_user.txt` - User prompt template

### General Reflection
- ✅ `general_reflection_system.txt` - System prompt
- ✅ `general_reflection_user.txt` - User prompt template

### Voice Transcription
- ✅ `voice_structure_system.txt` - System prompt
- ✅ `voice_structure_user.txt` - User prompt template

### Document Extraction
- ✅ `document_extraction_system.txt` - System prompt
- ✅ `document_extraction_user.txt` - User prompt template

### CPD Tagging
- ✅ `cpd_tagging_system.txt` - System prompt
- ✅ `cpd_tagging_user.txt` - User prompt template

## 🔧 Recent Update

**Changed**: Step 2 of Clinical Reasoning Framework
- **Old**: `COGNITIVE PROCESS`
- **New**: `PATTERN RECOGNITION`

**Reason**: More accurate terminology for clinical reasoning
- Pattern recognition is the primary cognitive strategy doctors use
- Includes multiple reasoning approaches:
  - Pattern recognition (fast, intuitive)
  - Hypothetico-deductive reasoning (systematic)
  - Systematic approach (step-by-step)

**Files Updated**:
- ✅ `backend/server.js` (line 186, 218)
- ✅ `backend/prompts/clinical_case_system.txt`
- ✅ `backend/prompts/clinical_case_user.txt`
- ✅ `AI_PROMPTS_DOCUMENTATION.md`

## 📊 Clinical Reasoning Framework

### 5-Step Framework for Clinical Cases

1. **INPUT**
   - Clinical information presented
   - Chief complaint, history, examination, investigations

2. **PATTERN RECOGNITION** ⭐ (Updated)
   - How the doctor approached the problem
   - Pattern recognition vs systematic reasoning
   - Diagnostic thinking process

3. **ANALYTICAL REASONING**
   - Systematic analysis
   - Differential diagnosis
   - Key diagnostic features

4. **BIAS FILTER**
   - Identify cognitive biases:
     - Anchoring bias
     - Confirmation bias
     - Premature closure
     - Availability heuristic
   - How to avoid them

5. **OUTPUT**
   - Clinical decision
   - Management plan
   - Learning points
   - Future approach

## 🎯 Pattern Recognition Explained

**What is Pattern Recognition?**
- Fast, intuitive thinking based on experience
- "I've seen this before" recognition
- Non-analytical processing

**When Doctors Use It:**
- Experienced clinicians recognize patterns quickly
- Common presentations trigger automatic recognition
- Efficient for typical cases

**Complemented By:**
- **Hypothetico-deductive reasoning**: Generating and testing hypotheses
- **Systematic approach**: Step-by-step analysis for complex cases

**Why This Matters:**
- Understanding HOW doctors think helps improve their thinking
- Identifies when fast thinking might lead to errors
- Encourages metacognition (thinking about thinking)

## 💡 Usage Example

```javascript
// System prompt
const systemPrompt = readFileSync('./prompts/clinical_case_system.txt', 'utf8');

// User prompt with variables
const userPrompt = readFileSync('./prompts/clinical_case_user.txt', 'utf8')
  .replace('{{title}}', 'Chest Pain in ED')
  .replace('{{year}}', '2025')
  .replace('{{context}}', 'A 45-year-old male...');

// OpenAI call
const completion = await openai.chat.completions.create({
  model: 'gpt-3.5-turbo',
  messages: [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: userPrompt }
  ],
  temperature: 0.7
});
```

## 📖 Related Documentation

- `README.md` - Full prompts directory documentation
- `AI_PROMPTS_DOCUMENTATION.md` - Complete prompts guide
- `backend/server.js` - Current implementation

## 🚀 Next Steps

1. ✅ Prompts extracted to separate files
2. ✅ Updated framework terminology
3. ⏳ Optionally: Load prompts from files in server.js
4. ⏳ Optionally: Add prompt versioning
5. ⏳ Optionally: A/B test prompt variations

## 🔍 Testing the Change

```bash
# Restart backend server
cd backend
PORT=3001 node server.js

# Test with clinical case
# The AI should now use "PATTERN RECOGNITION" in its analysis
```

---

**Last Updated**: 2025-01-15
**Version**: 1.1
**Status**: ✅ Production Ready

