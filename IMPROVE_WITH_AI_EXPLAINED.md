# "Improve with AI" Function - Complete Explanation

## 🎯 What Does It Do?

The **"Improve with AI"** feature (also called "Self-Play") uses AI to enhance your reflection by:
1. **Analyzing** your reflection content
2. **Detecting** if it's a clinical case or general reflection
3. **Improving** the structure, depth, and quality
4. **Iterating** (default: 1 iteration) to refine the output
5. **Returning** an improved version you can accept or reject

---

## 🔄 How It Works

### Step 1: User Clicks "Improve with AI"
- Location: Reflection Edit Page (after saving)
- Button: Purple gradient button with ✨ icon
- File: `lib/features/reflections/presentation/reflection_edit_page.dart`

### Step 2: Opens Self-Play Runner
- Screen: `SelfPlayRunner` widget
- File: `lib/features/reflections/presentation/selfplay_runner.dart`
- Collects reflection data:
  - Title
  - Year
  - What happened
  - So what (analysis)
  - Now what (action)

### Step 3: Calls Firebase Function
- Function: `selfPlay` (Firebase Callable Function)
- Location: `functions/src/apiFunctions.ts` (lines 222-340)
- Endpoint: `https://europe-west2-mindclon-dev.cloudfunctions.net/selfPlay`
- Sends: `{ year, title, context, iterations }`

### Step 4: AI Processing
The function:
1. **Detects content type** using regex:
   ```typescript
   const isClinicalCase = /ataxia|diagnosis|symptoms?|patient presented|differential|investigation|treatment|clinical|examination/i.test(reflectionContext);
   ```

2. **Selects appropriate prompts** based on content type

3. **Runs iterations** (default: 1, can be adjusted with slider)
   - Each iteration calls OpenAI GPT-3.5-turbo
   - Each iteration improves on the previous output

4. **Returns improved text**

### Step 5: User Reviews & Accepts/Rejects
- Shows BEFORE (original) and AFTER (improved) comparison
- User can accept changes or reject them
- If accepted, saves to Firestore

---

## 📝 What Prompts Does It Use?

### **Important**: The function does NOT use the prompt files from `backend/prompts/`

Instead, the prompts are **hardcoded directly in the Firebase Function** (`functions/src/apiFunctions.ts`).

However, the prompts are **very similar** to the files in `backend/prompts/`:

---

### For **Clinical Cases** (when medical terms detected):

#### System Prompt (lines 246-258):
```
You are an expert NHS clinical educator helping doctors analyze complex medical cases and develop clinical reasoning skills.

Your task: Analyze this clinical case using a structured clinical reasoning framework. Break down the doctor's thinking process and provide insights that enhance diagnostic reasoning and reduce cognitive bias.

Framework to use:
1. INPUT - What clinical information was presented
2. PATTERN RECOGNITION - How the doctor approached the problem
3. ANALYTICAL REASONING - Systematic analysis and differential diagnosis
4. BIAS FILTER - Identify potential cognitive biases (anchoring, confirmation bias, premature closure, etc.)
5. OUTPUT - Clinical decision and learning points

Maintain the doctor's authentic voice but enhance clinical reasoning depth and systematic thinking.
```

**Similar to**: `backend/prompts/clinical_case_system.txt`

#### User Prompt (lines 277-303):
```
Analyze this clinical case using the clinical reasoning framework:

Title: {title}
Year: {year}

Clinical Case:
{improved}

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

Provide clear, educational insights that improve clinical reasoning.
```

**Similar to**: `backend/prompts/clinical_case_user.txt`

---

### For **General Reflections** (default):

#### System Prompt (lines 259-269):
```
You are an expert NHS clinical educator helping doctors write high-quality reflections for their appraisal.

GMC reflective practice guidelines:
1. Describe what happened (the experience)
2. Reflect on thoughts and feelings
3. Evaluate what was good and what could be improved
4. Analyze to make sense of the experience
5. Conclude with what was learned
6. Action plan for future practice

Your task: Improve the doctor's reflection using the "What? So what? Now what?" framework. Make it more structured, insightful, and aligned with GMC requirements. Maintain the doctor's authentic voice but enhance depth and learning.
```

**Similar to**: `backend/prompts/general_reflection_system.txt`

#### User Prompt (lines 304-312):
```
Improve this NHS reflection:

Title: {title}
Year: {year}

Original reflection:
{improved}

Enhance it using the "What? So what? Now what?" framework while keeping the doctor's authentic voice.
```

**Similar to**: `backend/prompts/general_reflection_user.txt` (but simpler)

---

## 🔍 Key Differences from Backend Prompt Files

### What's Different:
1. **Location**: Prompts are in Firebase Function code, not separate files
2. **Format**: No template variables like `{{title}}` - uses JavaScript template literals
3. **Simplification**: General reflection user prompt is shorter than the file version
4. **Dynamic**: Content type detection happens at runtime

### What's the Same:
- Same system prompts (clinical case and general reflection)
- Same frameworks (clinical reasoning vs. What/So What/Now What)
- Same goals (improve quality, maintain authentic voice)

---

## 🛠️ Technical Details

### Function Configuration:
```typescript
export const selfPlay = functions
  .region('europe-west2')
  .runWith({
    timeoutSeconds: 300,  // 5 minutes max
    memory: '512MB',
    secrets: ['OPENAI_API_KEY'],
  })
```

### AI Model:
- **Model**: `gpt-3.5-turbo`
- **Temperature**: `0.7` (default)
- **Max Tokens**: `1500` (reduced from 2000 for speed)
- **Iterations**: Default `1` (was 3, optimized for speed)

### Input:
```typescript
{
  year: string,
  title: string,
  context: string,  // Combined "What/So What/Now What"
  iterations: number  // Default: 1
}
```

### Output:
```typescript
{
  success: true,
  improved: string,  // The enhanced reflection text
  iterations: number
}
```

---

## 📂 File Locations

### Frontend (Flutter):
- **UI Button**: `lib/features/reflections/presentation/reflection_edit_page.dart`
- **Self-Play Screen**: `lib/features/reflections/presentation/selfplay_runner.dart`
- **API Service**: `lib/services/api_service.dart` (method: `runSelfPlay`)

### Backend (Firebase Functions):
- **Function**: `functions/src/apiFunctions.ts` (lines 222-340)
- **Exported**: `functions/src/index.ts`

### Prompt Files (Reference Only - Not Used):
- `backend/prompts/clinical_case_system.txt`
- `backend/prompts/clinical_case_user.txt`
- `backend/prompts/general_reflection_system.txt`
- `backend/prompts/general_reflection_user.txt`

---

## 🎨 User Experience

1. **Button**: "Improve with AI" (purple gradient, ✨ icon)
2. **Loading**: Shows "Running AI..." with progress
3. **Result**: Before/After comparison view
4. **Actions**: 
   - "Accept & Save" → Updates reflection in Firestore
   - "Reject Changes" → Keeps original

---

## 💡 Summary

**What it does**: Uses AI to improve reflection quality by enhancing structure, depth, and GMC alignment.

**What prompts it uses**: 
- **Hardcoded in Firebase Function** (`functions/src/apiFunctions.ts`)
- **Similar to** `backend/prompts/` files but not directly using them
- **Two types**: Clinical case prompts vs. General reflection prompts
- **Auto-detects** which type based on content

**How to modify prompts**: Edit `functions/src/apiFunctions.ts` lines 246-312, then redeploy:
```bash
cd functions && npm run build
firebase deploy --only functions:selfPlay
```

