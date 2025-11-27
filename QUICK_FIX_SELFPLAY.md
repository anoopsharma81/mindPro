# Quick Fix: Self-Play Connection Timeout

## ✅ Fix Applied

I've updated `lib/services/api_service.dart` to use **Firebase Functions** instead of the local backend server.

The app will now:
- ✅ Use Firebase Functions when available (works without Mac)
- ✅ Fall back to HTTP if Firebase Functions URL not detected
- ✅ Handle authentication automatically via Firebase

---

## 🚀 **Deploy Firebase Functions**

The functions need to be deployed first. Run:

```bash
cd functions
npm install
firebase functions:secrets:set OPENAI_API_KEY  # Enter your OpenAI key
npm run build
cd ..
firebase deploy --only functions
```

**This takes 5-10 minutes on first deployment.**

---

## ⚠️ **If Functions Not Deployed Yet**

If you get errors like "function not found", the functions aren't deployed yet.

**Option 1: Deploy Functions** (Recommended)
- Follow steps above
- App will work anywhere after deployment

**Option 2: Start Local Backend** (Temporary)
- Run: `cd backend && PORT=3001 node server.js`
- App will use local backend until functions are deployed

---

## ✅ **After Deployment**

Once functions are deployed:
1. **Hot restart** the app (press `r` in Flutter terminal)
2. **Self-play will work** without Mac connection
3. **All APIs work** independently

---

## 🔍 **What Changed**

**Before:**
- App tried to connect to `http://192.168.1.189:3001/api` (local backend)
- Backend wasn't running → timeout error

**After:**
- App uses Firebase Functions: `https://europe-west2-mindclon-dev.cloudfunctions.net`
- Works anywhere, no Mac needed
- Auto-authentication via Firebase

---

*Deploy the functions and the app will work independently!*

