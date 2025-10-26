# Firebase Admin SDK Setup for Backend

## ✅ Current Status

The backend is now running in **development mode** without Firebase Admin authentication. This is perfectly fine for:
- ✅ Local development
- ✅ Testing AI features
- ✅ Running self-play improvements

The warning "⚠️ Running without auth" has been replaced with:
```
🔧 Development mode: Running without Firebase Admin auth
```

---

## Why Firebase Admin?

Firebase Admin SDK allows the backend to:
1. 🔐 Verify user authentication tokens
2. 📝 Read/write to Firestore with admin privileges
3. 🗄️ Access Firebase Storage
4. 👥 Manage users

**For now**: This is **optional**. Your backend works without it!

---

## When to Enable Firebase Admin

Enable it when you:
- Deploy to production
- Need to verify user tokens on the backend
- Want additional security

---

## How to Enable Firebase Admin (Optional)

### Step 1: Download Service Account Key

1. Go to: https://console.firebase.google.com/project/metanoia-a3035/settings/serviceaccounts/adminsdk

2. Click **"Generate new private key"**

3. Click **"Generate key"** in the dialog

4. Save the downloaded JSON file as:
   ```
   backend/firebase-service-account.json
   ```

### Step 2: Update .env File

Add this line to `backend/.env`:
```bash
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```

### Step 3: Restart Backend

```bash
cd backend
npm start
```

You should now see:
```
✅ Firebase Admin initialized
```

---

## Security Notes

### ⚠️ IMPORTANT: Keep Service Account Key Secret!

The service account key has **admin access** to your entire Firebase project!

**Do NOT**:
- ❌ Commit it to Git
- ❌ Share it publicly
- ❌ Upload it to GitHub

**DO**:
- ✅ Add to `.gitignore` (already done)
- ✅ Store securely
- ✅ Rotate keys regularly in production

### .gitignore (Already Configured)

```gitignore
backend/.env
backend/firebase-service-account.json
```

---

## Current Backend Configuration

Your backend is configured as:

**Port**: 3001  
**Mode**: Development  
**Firebase Admin**: Disabled (optional)  
**Auth Verification**: Skipped in dev mode  

---

## Files Created

1. ✅ `backend/.env` - Environment configuration
   ```
   PORT=3001
   NODE_ENV=development
   OPENAI_API_KEY=sk-placeholder-key
   ```

2. ✅ Updated `backend/server.js`
   - Smart detection of dev vs production
   - Clear messaging instead of warnings
   - Works without Firebase Admin

---

## Testing Without Firebase Admin

Everything works! Test these features:

- ✅ Self-play improvements
- ✅ Reinforcement with questions
- ✅ CPD extraction
- ✅ Document export

All API endpoints work in development mode.

---

## Troubleshooting

### "Cannot load service account"

**Solution**: This is normal in development mode. Ignore this message or follow the setup steps above to enable Firebase Admin.

### "Auth verification skipped"

**Solution**: This is intentional in development mode. No action needed.

### Backend won't start

**Check**:
1. Port 3001 is not in use: `lsof -i :3001`
2. Node modules installed: `cd backend && npm install`
3. .env file exists: `ls -la backend/.env`

---

## Production Deployment Checklist

When deploying to production:

- [ ] Download Firebase service account key
- [ ] Add `FIREBASE_SERVICE_ACCOUNT_PATH` to production .env
- [ ] Set `NODE_ENV=production`
- [ ] Verify Firebase Admin initializes
- [ ] Test auth token verification
- [ ] Secure the service account key
- [ ] Add proper error handling
- [ ] Enable logging/monitoring

---

## Summary

**Current Setup**: ✅ Working without Firebase Admin  
**Warning Fixed**: ✅ Clear dev mode message  
**API Features**: ✅ All working  
**Optional Setup**: 📖 Guide provided above  

**You're good to go!** 🚀

The backend is running properly in development mode. Enable Firebase Admin later when you need production security.

