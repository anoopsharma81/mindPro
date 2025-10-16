# Metanoia Backend API

Node.js backend server for AI-powered features using OpenAI ChatGPT API.

---

## Features

- ✅ Self-play reflection improvement (GPT-4)
- ✅ Reinforcement learning from ratings
- ✅ Auto-tagging for CPD entries
- ✅ Firebase token authentication
- ⏳ Export generation (placeholder)

---

## Quick Start (5 minutes)

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Set Up Environment Variables

Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Edit `.env`:
```env
OPENAI_API_KEY=sk-your-actual-openai-key-here
```

### 3. (Optional) Set Up Firebase Admin

For production auth verification:

1. Go to [Firebase Console](https://console.firebase.google.com/project/metanoia-a3035/settings/serviceaccounts/adminsdk)
2. Click "Generate New Private Key"
3. Save as `firebase-service-account.json` in `backend/` folder

**For development**: Server works without this (auth verification skipped)

### 4. Run the Server

```bash
npm start
```

Or with auto-reload:
```bash
npm run dev
```

You should see:
```
🚀 Metanoia Backend API running on http://localhost:3000
📡 Health check: http://localhost:3000/api/health
✅ OpenAI API: Configured
Ready for requests! 🎉
```

---

## Testing the API

### Health Check:
```bash
curl http://localhost:3000/api/health
```

### Test Self-Play (Without Auth):
```bash
curl -X POST http://localhost:3000/api/reflection/selfplay \
  -H "Content-Type: application/json" \
  -d '{
    "year": "2024",
    "title": "Patient communication",
    "context": "I spoke with an anxious patient today about their diagnosis.",
    "iterations": 1
  }'
```

---

## API Endpoints

### POST `/api/reflection/selfplay`

Improve a reflection using AI.

**Request**:
```json
{
  "year": "2024",
  "title": "Reflection title",
  "context": "Original reflection text...",
  "iterations": 3
}
```

**Response**:
```json
{
  "improved": "Enhanced reflection with deeper insights...",
  "score": 8.5,
  "iterations": [
    { "version": 1, "text": "..." }
  ],
  "usage": {
    "prompt_tokens": 150,
    "completion_tokens": 500,
    "total_tokens": 650
  }
}
```

### POST `/api/reflection/reinforce`

Record rating for reinforcement learning.

**Request**:
```json
{
  "year": "2024",
  "rid": "reflection-id",
  "rating": 8
}
```

**Response**:
```json
{
  "success": true,
  "message": "Rating recorded"
}
```

### POST `/api/cpd`

Auto-tag CPD entry with AI.

**Request**:
```json
{
  "year": "2024",
  "title": "BLS Course",
  "summary": "Basic Life Support refresher",
  "hours": 4,
  "date": "2024-10-10"
}
```

**Response**:
```json
{
  "autoTags": {
    "suggestedType": "course",
    "domains": [1, 2],
    "impact": "Improves emergency response capability"
  }
}
```

---

## Using from Flutter App

The Flutter app is already configured! Just run the backend:

```bash
# Terminal 1: Start backend
cd backend
npm start

# Terminal 2: Run Flutter app
cd ..
flutter run -d chrome  # Or iOS/Android
```

When backend is running:
- ✅ Self-play button will work
- ✅ CPD auto-tagging will work
- ✅ No more 401 errors!

---

## Configuration

### OpenAI Models Available:

```javascript
// In server.js, change model:
model: "gpt-4-turbo-preview"  // Best quality, slower
model: "gpt-4"                // Good quality
model: "gpt-3.5-turbo"        // Fast, cheaper
```

### Cost Estimates:

| Model | Cost per Reflection | Typical Tokens |
|-------|---------------------|----------------|
| GPT-4 Turbo | ~$0.02-0.05 | 1000-2000 |
| GPT-4 | ~$0.03-0.08 | 1000-2000 |
| GPT-3.5 Turbo | ~$0.002-0.005 | 1000-2000 |

**For testing**: Use GPT-3.5 Turbo (cheap)  
**For production**: Use GPT-4 Turbo (best quality)

---

## Development Mode

### Without Firebase Admin:
- ✅ API works
- ⚠️  Auth verification skipped
- ✅ Good for local testing
- User ID: `dev-user`

### With Firebase Admin:
- ✅ API works
- ✅ Auth verification enabled
- ✅ Production-ready
- User ID: Real Firebase UID

---

## Deployment Options

### Option 1: Cloud Run (Google Cloud)
```bash
# Build and deploy
gcloud run deploy metanoia-backend --source .
```

### Option 2: Render.com
1. Connect GitHub repo
2. Set environment variables
3. Deploy

### Option 3: Railway.app
1. Connect GitHub repo
2. Set environment variables
3. Deploy

### Option 4: Heroku
```bash
heroku create metanoia-backend
git push heroku main
```

---

## Environment Variables for Production

```env
# OpenAI
OPENAI_API_KEY=sk-your-production-key

# Firebase
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json

# Server
PORT=8080
NODE_ENV=production

# CORS (your production domains)
ALLOWED_ORIGINS=https://yourapp.com,https://www.yourapp.com
```

---

## Troubleshooting

### Error: "OPENAI_API_KEY not found"
**Fix**: Add your OpenAI API key to `.env` file

### Error: "Firebase service account not found"
**Solution**: Either:
1. Download from Firebase Console, OR
2. Run in dev mode (auth skipped)

### Error: "CORS blocked"
**Fix**: Add your Flutter app domain to CORS config in `server.js`

---

## Next Steps

1. ✅ Install dependencies (`npm install`)
2. ✅ Add OpenAI API key to `.env`
3. ✅ Run server (`npm start`)
4. ✅ Test with Flutter app
5. ⏳ Deploy to cloud when ready

---

## Files Structure

```
backend/
├── server.js              # Main server code
├── package.json           # Dependencies
├── .env.example          # Environment template
├── .env                  # Your config (create this)
├── .gitignore            # Git ignore
└── firebase-service-account.json  # (optional) Firebase admin key
```

---

**Your backend is ready! Just add your OpenAI API key and run it!** 🚀



