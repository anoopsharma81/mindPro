# OpenAI API Key Configuration Fix

## Error

```
❌ Extraction failed: AuthenticationError: 401 Incorrect API key provided: sk-place******-key
```

## Problem

The backend `.env` file has a placeholder API key instead of your real OpenAI API key.

## Solution

You need to add your real OpenAI API key to the backend configuration.

---

## Method 1: Interactive Setup Script (Easiest) ⭐

Run this in your terminal:

```bash
cd /Users/anup/code/Medflutter/metanoia_flutter/backend
./setup-env.sh
```

The script will:
1. Ask for your OpenAI API key
2. Validate it
3. Update the `.env` file
4. Give you next steps

---

## Method 2: Manual Setup

### Step 1: Get Your OpenAI API Key

1. Go to: https://platform.openai.com/api-keys
2. Sign in (or create an account if you don't have one)
3. Click **"Create new secret key"**
4. Give it a name (e.g., "Metanoia Backend")
5. **Copy the key** (it starts with `sk-`)

⚠️ **IMPORTANT**: Save the key somewhere safe! You can only see it once.

### Step 2: Update backend/.env

Open the file:
```bash
nano /Users/anup/code/Medflutter/metanoia_flutter/backend/.env
```

Change this line:
```
OPENAI_API_KEY=sk-placeholder-key
```

To:
```
OPENAI_API_KEY=sk-your-actual-key-here
```

Save and exit:
- Press `Ctrl + O` (save)
- Press `Enter` (confirm)
- Press `Ctrl + X` (exit)

### Step 3: Restart the Backend

```bash
# Stop the current backend
lsof -ti :3001 | xargs kill -9

# Start it again
cd /Users/anup/code/Medflutter/metanoia_flutter/backend
npm start
```

You should see:
```
✅ OpenAI API: Configured
```

---

## Method 3: Command Line (Quick)

If you already have your API key, run this one command:

```bash
cd /Users/anup/code/Medflutter/metanoia_flutter/backend
cat > .env << 'EOF'
# Backend API Configuration
PORT=3001
NODE_ENV=development
OPENAI_API_KEY=sk-your-actual-key-here
EOF
```

Replace `sk-your-actual-key-here` with your real key, then restart the backend.

---

## Verify It's Working

After updating the key and restarting:

### Check Backend Logs

You should see:
```
✅ OpenAI API: Configured
Ready for requests! 🎉
```

### Test Photo Extraction

1. Open your app
2. Go to Reflections → Create from Photo
3. Take/select a photo
4. Should extract successfully! ✅

---

## Cost Information

### OpenAI Pricing

Photo extraction uses **GPT-4o Vision**:
- **$2.50** per 1 million input tokens
- **$10.00** per 1 million output tokens

### Typical Usage

- Each photo extraction: ~500-1000 tokens
- Cost per extraction: ~$0.01-0.02 (1-2 cents)
- 100 photos: ~$1-2

### Free Tier

New OpenAI accounts get **$5 free credits** to try it out!

---

## Security Best Practices

### ✅ DO:
- Keep your API key secret
- Use `.gitignore` to exclude `.env` files (already configured)
- Rotate keys regularly
- Monitor usage in OpenAI dashboard

### ❌ DON'T:
- Commit `.env` to Git
- Share your key publicly
- Use the same key for production and development
- Leave unused keys active

---

## Troubleshooting

### "Invalid API Key" Error

**Problem**: Key is incorrect or expired

**Solution**:
1. Go to https://platform.openai.com/api-keys
2. Verify your key is active
3. Create a new key if needed
4. Update `.env` and restart

### "Insufficient Quota" Error

**Problem**: You've used all your credits

**Solution**:
1. Go to https://platform.openai.com/account/billing
2. Add payment method
3. Add credits ($10 minimum)
4. Try again

### Backend Shows "Placeholder Key"

**Problem**: `.env` wasn't updated or backend not restarted

**Solution**:
```bash
# Check current key
cat /Users/anup/code/Medflutter/metanoia_flutter/backend/.env

# Should show your real key, not "placeholder"
# If not, update it using Method 1, 2, or 3 above

# Then restart
lsof -ti :3001 | xargs kill -9
cd /Users/anup/code/Medflutter/metanoia_flutter/backend && npm start
```

---

## Alternative: Disable Photo Extraction (Temporary)

If you don't want to use OpenAI right now, you can:

1. Comment out photo extraction in the app
2. Or use manual reflection entry instead
3. Enable it later when you're ready

But for the full experience, adding the API key is recommended! ✨

---

## Summary

**Issue**: Placeholder API key  
**Fix**: Add real OpenAI API key  
**Methods**: Interactive script, manual, or command line  
**Cost**: ~$0.01-0.02 per photo extraction  
**Free**: $5 credits for new accounts  

---

## Quick Start Command

```bash
cd /Users/anup/code/Medflutter/metanoia_flutter/backend
./setup-env.sh
```

That's it! 🚀

