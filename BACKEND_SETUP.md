# 🚀 Backend Setup - ChatGPT API Integration

**Quick setup guide to enable AI features in your app**

---

## ⚡ Quick Start (5 Minutes)

### Step 1: Get OpenAI API Key (2 minutes)

1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign in or create account
3. Click "Create new secret key"
4. Copy the key (starts with `sk-...`)

**Cost**: ~$0.02-0.05 per reflection improvement

### Step 2: Install Backend (2 minutes)

```bash
cd backend
npm install
```

### Step 3: Configure (1 minute)

Create `.env` file in `backend/` folder:

```bash
cp .env.example .env
```

Edit `backend/.env`:
```envfg
OPENAI_API_KEY=sk-your-actual-key-here
PORT=3000
```

### Step 4: Run Server

```bash
npm start
```

You should see:
```
🚀 Metanoia Backend API running on http://localhost:3000
✅ OpenAI API: Configured
Ready for requests! 🎉
```

**Done!** The backend is running! ✅

---

## Testing It Works

### Test 1: Health Check

Open browser to: http://localhost:3000/api/health

Should see:
```json
{
  "status": "ok",
  "message": "Metanoia Backend API",
  "openai": true,
  "firebase": false
}
```

### Test 2: Run Flutter App

```bash
# In another terminal:
flutter run -d chrome  # Or iOS/Android
```

### Test 3: Use Self-Play

1. Create or edit a reflection
2. Click "Self-Play" button
3. Wait 5-10 seconds
4. ✅ Should see improved reflection!

**No more 401 error!** 🎉

---

## What Each Endpoint Does

### 1. Self-Play (`/api/reflection/selfplay`)

**What it does**:
- Takes your draft reflection
- Uses GPT-4 to improve it
- Applies "What? So what? Now what?" framework
- Returns enhanced version

**Example**:
```
Input: "I saw a patient today who was anxious."

Output: "I encountered a patient presenting with significant anxiety...
[Detailed reflection following GMC guidelines]
...This experience highlighted the importance of..."
```

### 2. CPD Auto-Tag (`/api/cpd`)

**What it does**:
- Analyzes CPD activity
- Suggests type (course, reading, etc.)
- Maps to GMC domains (1-4)
- Generates impact statement

**Example**:
```
Input: "BLS Course - Basic Life Support refresher"

Output:
- Type: course
- Domains: [1, 2] (Knowledge, Safety)
- Impact: "Enhances emergency response capability..."
```

### 3. Reinforce (`/api/reflection/reinforce`)

**What it does**:
- Records your rating (1-10) of improved reflections
- Stores feedback for future improvements
- (Currently just logs, can be enhanced)

---

## Configuration Options

### Change AI Model

Edit `backend/server.js` line ~90:

```javascript
// For best quality (recommended):
model: "gpt-4-turbo-preview"

// For faster/cheaper:
model: "gpt-3.5-turbo"

// For latest:
model: "gpt-4o"
```

### Adjust AI Creativity

```javascript
temperature: 0.7  // Default - balanced
temperature: 0.3  // More consistent
temperature: 0.9  // More creative
```

### Change Max Length

```javascript
max_tokens: 1500  // Default
max_tokens: 2000  // Longer reflections
max_tokens: 1000  // Shorter, cheaper
```

---

## Development vs Production

### Development (Default):
```env
NODE_ENV=development
```
- ✅ CORS allows localhost
- ⚠️  Firebase auth optional
- ✅ Detailed logging
- ✅ Good for testing

### Production:
```env
NODE_ENV=production
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```
- ✅ Strict CORS
- ✅ Firebase auth required
- ✅ Error handling
- ✅ Ready for deployment

---

## Cost Estimation

### OpenAI API Costs:

**GPT-4 Turbo Pricing** (as of Oct 2024):
- Input: $0.01 per 1K tokens
- Output: $0.03 per 1K tokens

**Typical Usage per Reflection**:
- Input: ~500 tokens (original reflection + prompt)
- Output: ~1000 tokens (improved reflection)
- **Cost**: ~$0.035 per improvement

**Monthly Estimates**:
- 10 reflections/month: ~$0.35
- 50 reflections/month: ~$1.75
- 200 reflections/month: ~$7.00

**Very affordable for the value provided!** ✅

---

## Deployment Guide

### Option 1: Railway.app (Easiest)

1. Go to [Railway.app](https://railway.app)
2. "New Project" → "Deploy from GitHub"
3. Select your repo → `backend` folder
4. Add environment variables:
   - `OPENAI_API_KEY`
   - Upload `firebase-service-account.json`
5. Deploy!

**Cost**: Free tier available, then $5/month

### Option 2: Google Cloud Run

```bash
# Install Google Cloud CLI first
gcloud run deploy metanoia-backend \
  --source ./backend \
  --region us-central1 \
  --allow-unauthenticated
```

Set environment variables in Cloud Run console.

**Cost**: Pay per request, very cheap

### Option 3: Render.com

1. Connect GitHub
2. Select `backend` folder
3. Set env vars
4. Deploy

**Cost**: Free tier available

---

## Updating Flutter App to Use Deployed Backend

### Update .env in Flutter:

```env
# .env
API_BASE_URL=https://your-backend-url.com/api
```

Or hardcode in `lib/core/env.dart`:
```dart
static const apiBaseUrl = 'https://your-backend-url.com/api';
```

Rebuild Flutter app:
```bash
flutter run
```

---

## Security Notes

### Current Setup:
- ✅ Firebase token verification (in production)
- ✅ CORS protection
- ✅ User isolation (each user sees only their data)
- ✅ Rate limiting (via cloud provider)

### For Production:
1. Enable Firebase Admin authentication
2. Set up proper CORS
3. Add rate limiting
4. Monitor API costs
5. Set up logging/monitoring

---

## Troubleshooting

### "OPENAI_API_KEY not set"
**Fix**: Add key to `.env` file

### "401 Unauthorized" in Flutter app
**Causes**:
1. Backend not running → Start with `npm start`
2. Wrong URL → Check `API_BASE_URL` in Flutter
3. CORS issue → Check backend logs

### "Firebase admin error"
**Fix**: Either:
- Add service account JSON file, OR
- Run in development mode (auth skipped)

### Slow responses
**Solutions**:
- Use GPT-3.5-turbo (faster)
- Reduce max_tokens
- Add loading indicators in app

---

## Testing Locally

### Start Backend:
```bash
cd backend
npm start
```

### Run Flutter App:
```bash
# Another terminal
flutter run -d chrome
```

### Test Self-Play:
1. Create a reflection
2. Click "Self-Play"
3. Wait ~5-10 seconds
4. See improved version!

---

## Next Steps

1. ✅ Get OpenAI API key
2. ✅ Run `npm install` in backend/
3. ✅ Add API key to `.env`
4. ✅ Run `npm start`
5. ✅ Test with Flutter app
6. ⏳ Deploy to cloud when ready

---

**Your AI-powered backend is ready! Just add your OpenAI key and run it!** 🤖✨



