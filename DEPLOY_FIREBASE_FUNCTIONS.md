# Deploy Firebase Functions - Make App Work Without Mac

## 🎯 Goal

Deploy all backend APIs to Firebase Cloud Functions so the app works **anywhere** without needing the Mac backend server.

---

## ✅ What's Ready

1. **Firebase Functions Created** (`functions/src/apiFunctions.ts`):
   - ✅ `extract` - Document/photo extraction
   - ✅ `transcribeAudio` - Voice transcription
   - ✅ `structureTranscription` - Structure voice into reflection
   - ✅ `selfPlay` - Reflection improvement
   - ✅ `reinforce` - Rating feedback
   - ✅ `autoTagCpd` - CPD auto-tagging
   - ✅ `generateLearningLoop` - Learning loop generation

2. **Environment Updated** (`lib/core/env.dart`):
   - ✅ Default API URL set to Firebase Functions
   - ✅ URL: `https://europe-west2-mindclon-dev.cloudfunctions.net`

---

## 🚀 Deployment Steps

### Step 1: Install Dependencies

```bash
cd functions
npm install
```

### Step 2: Set OpenAI API Key Secret

```bash
firebase functions:secrets:set OPENAI_API_KEY
```

When prompted, enter your OpenAI API key (starts with `sk-`).

### Step 3: Build TypeScript

```bash
cd functions
npm run build
```

This compiles TypeScript to JavaScript.

### Step 4: Deploy Functions

```bash
cd /Users/gbc/code/mindPro
firebase deploy --only functions
```

**First deployment takes 5-10 minutes.**

You'll see output like:
```
✔  functions[extract(europe-west2)] Successful create operation.
✔  functions[transcribeAudio(europe-west2)] Successful create operation.
...
```

### Step 5: Verify Deployment

```bash
firebase functions:list
```

Should show all functions deployed.

---

## 📱 Update App to Use Firebase Functions

The app currently uses HTTP (Dio) to call APIs. We need to update it to use Firebase Callable Functions.

### Option A: Update API Service (Recommended)

**File**: `lib/services/api_service.dart`

Add Firebase Functions support:

```dart
import 'package:cloud_functions/cloud_functions.dart';

class ApiService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west2',
  );
  
  // Use Firebase Functions if enabled, otherwise HTTP
  Future<Map<String, dynamic>> extractFromDocument({
    required String photoUrl,
    required String source,
    String? mimeType,
  }) async {
    if (Env.useFirebaseFunctions) {
      // Use Firebase Callable Function
      final callable = _functions.httpsCallable('extract');
      final result = await callable.call({
        'photoUrl': photoUrl,
        'source': source,
        'mimeType': mimeType,
      });
      return result.data as Map<String, dynamic>;
    } else {
      // Use HTTP (existing code)
      final response = await _dio.post('/extract', data: {...});
      return response.data as Map<String, dynamic>;
    }
  }
}
```

### Option B: Create New Firebase Functions Service

Create `lib/services/firebase_functions_service.dart` that uses callable functions, then update services to use it.

---

## ✅ After Deployment

Once functions are deployed:

1. **App works anywhere** - No Mac needed
2. **Always available** - Cloud-based
3. **Auto-scaling** - Handles traffic automatically
4. **Secure** - Firebase handles authentication

---

## 🔍 Testing

### Test Functions Locally (Optional)

```bash
cd functions
npm run serve
```

Then update app to use emulator:
```dart
FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
```

### Test Deployed Functions

After deployment, test with curl:

```bash
# Health check
curl https://europe-west2-mindclon-dev.cloudfunctions.net/healthCheck

# Test extract (requires auth token)
# Use Flutter app to test
```

---

## 📊 Function URLs

After deployment, functions will be available at:

- `https://europe-west2-mindclon-dev.cloudfunctions.net/extract`
- `https://europe-west2-mindclon-dev.cloudfunctions.net/transcribeAudio`
- `https://europe-west2-mindclon-dev.cloudfunctions.net/structureTranscription`
- `https://europe-west2-mindclon-dev.cloudfunctions.net/selfPlay`
- `https://europe-west2-mindclon-dev.cloudfunctions.net/reinforce`
- `https://europe-west2-mindclon-dev.cloudfunctions.net/autoTagCpd`
- `https://europe-west2-mindclon-dev.cloudfunctions.net/generateLearningLoop`

---

## ⚠️ Important Notes

1. **OpenAI API Key**: Must be set as Firebase secret before deployment
2. **Region**: Functions are in `europe-west2` (London) for NHS compliance
3. **Authentication**: All functions require Firebase Auth (automatic)
4. **Timeouts**: Some functions have 9-minute timeouts for AI processing

---

## 🐛 Troubleshooting

### Functions Not Deploying

```bash
# Check Firebase login
firebase login

# Check project
firebase use mindclon-dev

# Check build errors
cd functions
npm run build
```

### Functions Deployed But Not Working

1. Check function logs:
   ```bash
   firebase functions:log
   ```

2. Verify secrets are set:
   ```bash
   firebase functions:secrets:access OPENAI_API_KEY
   ```

3. Test function directly in Firebase Console

---

## 📝 Next Steps After Deployment

1. Update `lib/services/api_service.dart` to use Firebase Functions
2. Test all features work without Mac
3. Remove local backend dependency
4. Update documentation

---

*Once deployed, your app will work completely independently!* 🎉






