# Complete Setup Guide - Photo Extraction

## Current Status

✅ **Working:**
- Flutter app running on iPhone
- Firebase Storage (uploads work)
- Backend API running on port 3001
- Firebase Admin (optional, can add later)

❌ **Not Working:**
- Photo extraction (needs OpenAI API key)

## The Problem

Photo extraction uses OpenAI GPT-4o Vision to analyze photos. The backend currently has a placeholder API key (`sk-placeholder-key`), which causes the 500 error.

**Error in backend logs:**
```
❌ Extraction failed: AuthenticationError: 401 Incorrect API key provided
```

---

## Solution: Add Your OpenAI API Key

You have **TWO options**:

### Option A: Add OpenAI API Key (Enable Photo Extraction) ⭐

**Cost:** ~$0.01-0.02 per photo (new accounts get $5 free)

1. **Get API Key:**
   - Go to: https://platform.openai.com/api-keys
   - Sign in or create account
   - Click "Create new secret key"
   - Copy the key (starts with `sk-`)

2. **Add to Backend:**
   ```bash
   # Replace YOUR_KEY_HERE with your actual key
   echo "# Backend API Configuration
   PORT=3001
   NODE_ENV=development
   OPENAI_API_KEY=YOUR_KEY_HERE
   FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json" > /Users/anup/code/Medflutter/metanoia_flutter/backend/.env
   ```

3. **Restart Backend:**
   ```bash
   lsof -ti :3001 | xargs kill -9
   cd /Users/anup/code/Medflutter/metanoia_flutter/backend && npm start
   ```

4. **Test:**
   - Hot restart Flutter app (press `R`)
   - Try photo extraction
   - Should work! ✅

---

### Option B: Use Manual Entry (Disable Photo Extraction)

If you don't want to use OpenAI right now, you can still use the app by entering reflections manually.

**What works without OpenAI:**
- ✅ Manual reflection entry
- ✅ Self-play improvements (uses same key, but you can skip)
- ✅ All other app features
- ✅ CPD tracking
- ✅ Export to PDF

**What requires OpenAI:**
- ❌ Photo extraction
- ❌ Document extraction
- ❌ AI improvements (self-play, reinforcement)

---

## Quick Command Reference

### Check Backend Status
```bash
curl http://localhost:3001/api/health
```

### View Backend Logs
```bash
tail -f /Users/anup/code/Medflutter/metanoia_flutter/backend/backend.log
```

### Check Current API Key
```bash
cat /Users/anup/code/Medflutter/metanoia_flutter/backend/.env
```

### Restart Backend
```bash
lsof -ti :3001 | xargs kill -9
cd /Users/anup/code/Medflutter/metanoia_flutter/backend && npm start
```

---

## Firebase Admin (Optional)

Firebase Admin is **optional** for development. It enables:
- Backend auth token verification
- Admin access to Firestore from backend
- Better security in production

**Current status:** Running without Firebase Admin (OK for dev)

**To enable:**
1. Download service account key from Firebase Console
2. Save as `backend/firebase-service-account.json`
3. Already configured in `.env` ✅
4. Restart backend

---

## Architecture Overview

```
┌─────────────────┐
│   Flutter App   │
│   (iPhone)      │
└────────┬────────┘
         │
         ├─ Upload Photo ──→ Firebase Storage ✅
         │
         └─ Extract Content ──→ Backend API (port 3001)
                                    │
                                    └─→ OpenAI GPT-4o Vision
                                        (Needs API Key) ❌
```

---

## Cost Breakdown

### OpenAI Pricing
- **New accounts:** $5 free credits
- **Photo extraction:** ~500-1000 tokens per photo
- **Cost per photo:** ~$0.01-0.02 (1-2 cents)
- **100 photos:** ~$1-2

### Recommendation
Sign up for OpenAI, use the $5 free credits to try it out. If you like it, add $10-20 for continued use.

---

## Next Steps

**To enable photo extraction:**

1. ✅ Go to https://platform.openai.com/api-keys
2. ✅ Create new secret key
3. ✅ Add to `backend/.env` (command above)
4. ✅ Restart backend
5. ✅ Test in app

**Or just use manual entry for now** and add OpenAI later when you're ready! ✨

---

## Files to Edit

### backend/.env (Primary Config)
```bash
# Backend API Configuration
PORT=3001
NODE_ENV=development

# OpenAI API Key - REQUIRED for photo extraction
OPENAI_API_KEY=sk-your-actual-key-here

# Firebase Admin - OPTIONAL for development
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```

---

## Troubleshooting

### "500 Error" on Photo Upload
**Problem:** Invalid/missing OpenAI API key  
**Solution:** Add real API key to `.env` and restart

### "Connection Refused"
**Problem:** Backend not running  
**Solution:** Start backend: `cd backend && npm start`

### "Timeout After 10 Seconds"
**Problem:** Slow network or OpenAI API issue  
**Solution:** Check internet connection, try again

### "Placeholder Key" in Logs
**Problem:** `.env` not updated or backend not restarted  
**Solution:** Update `.env` with real key, then restart

---

## Summary

**Current Issue:** OpenAI API key is placeholder  
**Impact:** Photo extraction returns 500 error  
**Solution:** Add real OpenAI API key OR use manual entry  
**Time to Fix:** 5 minutes (if you have OpenAI account)  
**Cost:** $5 free credits, then ~$0.01/photo  

---

## Ready to Enable?

Run this (replace YOUR_KEY):
```bash
echo "# Backend API Configuration
PORT=3001
NODE_ENV=development
OPENAI_API_KEY=YOUR_KEY_HERE
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json" > /Users/anup/code/Medflutter/metanoia_flutter/backend/.env && lsof -ti :3001 | xargs kill -9 && cd /Users/anup/code/Medflutter/metanoia_flutter/backend && npm start
```

Then press `R` in Flutter terminal to hot restart! 🚀

