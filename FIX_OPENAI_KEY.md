# 🔑 Fix OpenAI API Key in Firebase

## Problem

The self-play function is failing with:
```
AuthenticationError: 401 Incorrect API key provided
```

This means the OpenAI API key stored in Firebase Secret Manager is incorrect.

---

## ✅ **Quick Fix**

### Step 1: Get Your Correct API Key

You need to use the same OpenAI API key that works in your backend.

**Option A: Check your backend `.env` file**
```bash
cd backend
cat .env | grep OPENAI_API_KEY
```

**Option B: Get a new key from OpenAI**
1. Go to: https://platform.openai.com/api-keys
2. Sign in
3. Click "Create new secret key"
4. Copy the key (starts with `sk-`)

---

### Step 2: Update Firebase Secret

Run this command and paste your **correct** API key when prompted:

```bash
firebase functions:secrets:set OPENAI_API_KEY
```

**Important**: 
- When prompted, paste your **full** API key
- The key should start with `sk-`
- Make sure there are no extra spaces or characters

---

### Step 3: Redeploy Functions

After updating the secret, redeploy the functions:

```bash
cd /Users/gbc/code/mindPro
firebase deploy --only functions
```

This will take 5-10 minutes.

---

### Step 4: Test Again

Hot restart your Flutter app (press `r`) and try self-play again.

---

## 🔍 **Verify Secret is Set Correctly**

Check if the secret is accessible:

```bash
firebase functions:secrets:access OPENAI_API_KEY
```

The output should show your API key starting with `sk-`.

---

## ⚠️ **Common Issues**

1. **Key has extra spaces**: Make sure you copy the key exactly, no leading/trailing spaces
2. **Wrong key**: Use the same key that works in your backend
3. **Key expired**: Generate a new key from OpenAI dashboard
4. **Secret not deployed**: After setting the secret, you must redeploy functions

---

## ✅ **After Fixing**

Once the secret is updated and functions redeployed:
- ✅ Self-play will work
- ✅ All AI features will work
- ✅ No more authentication errors

---

*Run the commands above to fix the API key!*






