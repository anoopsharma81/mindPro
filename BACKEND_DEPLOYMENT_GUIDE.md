# Backend Deployment Guide

**AI Document Extraction - Firebase Cloud Functions Setup**

---

## 🎯 Overview

This guide walks you through deploying the backend AI extraction service that powers the document/photo-to-reflection feature.

### What You'll Deploy:
- ✨ Firebase Cloud Functions (Node.js/TypeScript)
- 🔍 Google Cloud Vision API (OCR)
- 🤖 OpenAI GPT-3.5 Turbo (AI generation)
- 🔒 PHI Detection
- 🌍 EU Region (London) for NHS compliance

---

## 📋 Prerequisites

### 1. Tools Installed
```bash
# Node.js (v18+)
node --version  # Should be v18 or higher

# npm
npm --version

# Firebase CLI
npm install -g firebase-tools
firebase --version

# Login to Firebase
firebase login
```

### 2. Accounts & API Keys

#### Firebase Project
- You should already have a Firebase project (from Phase 1)
- Project ID: `[your-project-id]`

#### OpenAI API Key
1. Go to https://platform.openai.com/api-keys
2. Create account if needed
3. Click "Create new secret key"
4. Copy the key (starts with `sk-...`)
5. **IMPORTANT**: Save it securely - you won't see it again!

#### Google Cloud Project
- Your Firebase project automatically has a Google Cloud project
- Project ID is the same as Firebase project ID

---

## 🚀 Step-by-Step Deployment

### Step 1: Install Function Dependencies

```bash
cd functions
npm install
```

This installs:
- `firebase-functions` - Cloud Functions framework
- `firebase-admin` - Admin SDK
- `@google-cloud/vision` - OCR service
- `openai` - GPT-3.5 Turbo
- `pdf-parse` - PDF text extraction
- TypeScript and development tools

### Step 2: Enable Google Cloud Vision API

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your Firebase project
3. Navigate to **APIs & Services** → **Library**
4. Search for "**Cloud Vision API**"
5. Click "**Enable**"

✅ This should take a few seconds

### Step 3: Set Up API Keys (Secrets)

Firebase uses Secret Manager to securely store API keys:

```bash
# Set OpenAI API Key
firebase functions:secrets:set OPENAI_API_KEY
# When prompted, paste your OpenAI API key

# Set Google Cloud Project ID
firebase functions:secrets:set GOOGLE_CLOUD_PROJECT_ID
# When prompted, paste your Firebase project ID
```

✅ Secrets are now securely stored

### Step 4: Build TypeScript

```bash
npm run build
```

This compiles TypeScript to JavaScript in the `lib/` folder.

### Step 5: Deploy Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Or deploy specific function
firebase deploy --only functions:extractReflectionFromDocument
```

**Expected output:**
```
✔  functions[extractReflectionFromDocument(europe-west2)] Successful create operation.
Function URL: https://europe-west2-[project-id].cloudfunctions.net/...
```

⏱️ **First deployment takes 3-5 minutes**

### Step 6: Verify Deployment

```bash
# Check function is deployed
firebase functions:list

# View logs
firebase functions:log --only extractReflectionFromDocument
```

---

## 🧪 Testing

### Option 1: Test from Flutter App

1. **Update Flutter app** (if not done):
   ```bash
   cd ..  # Back to project root
   flutter pub get
   ```

2. **Run app**:
   ```bash
   flutter run
   ```

3. **Test flow**:
   - Go to Reflections
   - Click [+]
   - Choose "From Document/Photo (AI)"
   - Take a photo with text
   - Wait for AI processing
   - Review generated reflection!

### Option 2: Test with Firebase Emulator (Local)

```bash
cd functions
npm run serve
```

Then update Flutter app to use local emulator:
```dart
// In main.dart (for testing only)
FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
```

### Option 3: Test with curl

```bash
# Get function URL from deployment output
FUNCTION_URL="https://europe-west2-[project-id].cloudfunctions.net/extractReflectionFromDocument"

curl -X POST $FUNCTION_URL \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer [YOUR_FIREBASE_ID_TOKEN]" \
  -d '{
    "data": {
      "userId": "[USER_ID]",
      "source": "photo",
      "photoUrl": "[FIREBASE_STORAGE_URL]",
      "mimeType": "image/jpeg"
    }
  }'
```

---

## 💰 Cost Management

### Free Tier (Monthly)
- **Cloud Functions**: 2M invocations, 400K GB-seconds
- **Google Cloud Vision**: 1,000 images
- **Firebase Storage**: 1GB stored, 10GB downloaded
- **Firestore**: 50K reads, 20K writes

### After Free Tier
- **Google Cloud Vision**: $1.50 per 1,000 images
- **OpenAI GPT-3.5**: ~$0.002 per reflection
- **Cloud Functions**: $0.0000025 per GB-second
- **Total per extraction**: ~$0.0035

### Monthly Estimates
```
1000 users × 4 extractions/month = 4,000 extractions

Costs:
- Google Vision: $6 (after 1K free)
- OpenAI: $8
- Cloud Functions: ~$0
Total: ~$14/month
```

### Cost Optimization Tips
1. Set usage quotas in Google Cloud Console
2. Monitor with cost alerts
3. Use Firebase Analytics to track usage
4. Consider caching common extractions

---

## 📊 Monitoring & Logs

### View Real-Time Logs

```bash
# All logs
firebase functions:log

# Specific function
firebase functions:log --only extractReflectionFromDocument

# Follow logs (live)
firebase functions:log --only extractReflectionFromDocument --follow
```

### Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Functions**
4. Click on `extractReflectionFromDocument`
5. View **Logs**, **Metrics**, **Health**

### Google Cloud Console
1. Go to [Cloud Console](https://console.cloud.google.com)
2. Navigate to **Cloud Functions**
3. More detailed metrics and logs

---

## 🔒 Security

### Current Security Measures
✅ Authentication required (Firebase Auth)
✅ User ID validation
✅ PHI detection and logging
✅ Secrets in Secret Manager
✅ HTTPS-only
✅ EU region (GDPR compliant)

### Firestore Security Rules

Make sure these are deployed:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Deploy:
```bash
firebase deploy --only firestore:rules
```

### Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only access their own files
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Deploy:
```bash
firebase deploy --only storage
```

---

## 🐛 Troubleshooting

### Error: "OPENAI_API_KEY not set"

**Solution**:
```bash
firebase functions:secrets:set OPENAI_API_KEY
```

### Error: "Vision API not enabled"

**Solution**:
1. Go to https://console.cloud.google.com/apis/library/vision.googleapis.com
2. Select your project
3. Click "Enable"

### Error: "Permission denied"

**Possible causes**:
1. User not authenticated → Check Firebase Auth
2. Wrong user ID → Verify `userId` matches `auth.uid`
3. Security rules → Check Firestore/Storage rules

### Error: "Function timeout"

**Causes**:
- Large file (>5MB)
- Slow API response
- Complex document

**Solutions**:
- Reduce image size before upload
- Check OpenAI API status
- Increase timeout (max 540s)

### Error: "No text detected"

**Causes**:
- Image quality too low
- No text in image
- Handwriting too messy

**Solutions**:
- Retake photo with better lighting
- Ensure text is clearly visible
- Try typing instead

### Error: "Rate limit exceeded"

**Causes**:
- Too many requests to OpenAI
- Exceeded free tier

**Solutions**:
- Wait and retry
- Check OpenAI dashboard
- Upgrade OpenAI plan

---

## 🔄 Updating Functions

### After Code Changes

```bash
cd functions
npm run build
firebase deploy --only functions
```

### Updating Dependencies

```bash
cd functions
npm update
npm run build
firebase deploy --only functions
```

### Rollback to Previous Version

```bash
# List versions
firebase functions:list

# Delete current version (auto-rollback)
firebase functions:delete extractReflectionFromDocument
# Then redeploy
firebase deploy --only functions
```

---

## 📈 Performance Optimization

### Current Configuration
- **Region**: europe-west2 (London)
- **Memory**: 512MB
- **Timeout**: 540 seconds (9 minutes)
- **Concurrency**: Auto-scaled

### Optimization Tips

1. **Reduce image size before upload**:
   ```dart
   // In Flutter
   final compressedImage = await FlutterImageCompress.compressWithFile(
     file.path,
     quality: 80,
   );
   ```

2. **Cache results**:
   - Store extraction results in Firestore
   - Avoid re-processing same document

3. **Batch processing** (future enhancement):
   - Process multiple documents in one call
   - Reduce overhead

4. **Use GPT-3.5 instead of GPT-4**:
   - Already configured
   - 10x cheaper, fast enough

---

## 🚦 Production Checklist

Before going live:

- [ ] OpenAI API key set as secret
- [ ] Google Cloud Vision API enabled
- [ ] Functions deployed successfully
- [ ] Security rules deployed
- [ ] Test with real photo/document
- [ ] Check logs for errors
- [ ] Set up cost alerts
- [ ] Monitor first 24 hours
- [ ] Test PHI detection
- [ ] Verify EU region deployment
- [ ] Document emergency contacts
- [ ] Set up uptime monitoring

---

## 📞 Support Resources

### Documentation
- [Firebase Functions Docs](https://firebase.google.com/docs/functions)
- [Cloud Vision API Docs](https://cloud.google.com/vision/docs)
- [OpenAI API Docs](https://platform.openai.com/docs)

### Community
- [Firebase Stack Overflow](https://stackoverflow.com/questions/tagged/firebase)
- [OpenAI Community](https://community.openai.com/)

### Emergency Contacts
- **OpenAI Status**: https://status.openai.com/
- **Google Cloud Status**: https://status.cloud.google.com/
- **Firebase Status**: https://status.firebase.google.com/

---

## 🎉 You're Done!

The backend is now deployed and ready to extract reflections from photos and documents!

### Quick Test:
1. Open Flutter app
2. Go to Reflections → [+]
3. Choose "From Document/Photo (AI)"
4. Take a photo of handwritten notes
5. Watch the AI magic happen! ✨

### Next Steps:
- Test with various document types
- Monitor costs in first week
- Collect user feedback
- Optimize based on usage patterns

---

**Need help? Check logs, review error messages, or consult the troubleshooting section above!** 🚀



