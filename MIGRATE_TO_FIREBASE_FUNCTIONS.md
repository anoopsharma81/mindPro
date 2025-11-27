# Migrate App to Firebase Functions (No Mac Required)

## 🎯 Goal

Make the app work **without needing the Mac backend server**. All APIs will run on Firebase Cloud Functions.

---

## ✅ What's Been Done

1. **Created Firebase Functions** for all backend endpoints:
   - `extract` - Document/photo extraction
   - `transcribeAudio` - Voice transcription (Whisper)
   - `structureTranscription` - Structure voice into reflection
   - `selfPlay` - Reflection improvement
   - `reinforce` - Rating feedback
   - `autoTagCpd` - CPD auto-tagging
   - `generateLearningLoop` - Learning loop generation

2. **Updated `env.dart`** to use Firebase Functions by default:
   - Changed from: `http://192.168.1.189:3001/api` (local)
   - Changed to: `https://europe-west2-mindclon-dev.cloudfunctions.net` (Firebase)

---

## 🚀 Next Steps

### Step 1: Update API Service to Use Firebase Functions

The app currently uses HTTP (Dio) to call the backend. We need to update it to use Firebase Callable Functions.

**File**: `lib/services/api_service.dart`

**Change from**:
```dart
final response = await _dio.post('/extract', data: {...});
```

**Change to**:
```dart
final callable = FirebaseFunctions.instance.httpsCallable('extract');
final result = await callable.call({...});
```

### Step 2: Deploy Firebase Functions

```bash
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions
```

### Step 3: Set OpenAI API Key Secret

```bash
firebase functions:secrets:set OPENAI_API_KEY
# Enter your OpenAI API key when prompted
```

### Step 4: Test

After deployment, the app will work **anywhere** without needing the Mac!

---

## 📝 Files to Update

1. **`lib/services/api_service.dart`** - Change from Dio HTTP to Firebase Callable Functions
2. **`lib/services/document_extraction_service.dart`** - Update to use Firebase Functions
3. **`lib/features/reflections/services/voice_transcription_service.dart`** - Update to use Firebase Functions
4. **`lib/features/learning_loops/services/learning_loop_service.dart`** - Update to use Firebase Functions

---

## 🔄 Migration Strategy

### Option A: Gradual Migration (Recommended)
- Keep both HTTP and Firebase Functions support
- Add a flag to switch between them
- Test Firebase Functions first, then switch

### Option B: Complete Migration
- Update all services at once
- Deploy functions
- Test everything

---

## ✅ Benefits

- ✅ **Works anywhere** - No Mac needed
- ✅ **Always available** - Cloud-based
- ✅ **Auto-scaling** - Handles traffic automatically
- ✅ **Secure** - Firebase handles auth
- ✅ **Cost-effective** - Pay per use

---

*Once functions are deployed and API service is updated, the app will work completely independently!*






