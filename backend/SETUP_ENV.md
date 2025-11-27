# Backend Environment Setup

## ❌ Error

The backend server needs the `OPENAI_API_KEY` environment variable.

## ✅ Fix: Create .env File

### Step 1: Create .env File

In the `backend` directory, create a `.env` file:

```bash
cd /Users/gbc/code/mindPro/backend
nano .env
```

Or use any text editor.

### Step 2: Add Your OpenAI API Key

Add this line to the `.env` file:

```
OPENAI_API_KEY=sk-your-actual-api-key-here
PORT=3001
```

**Replace `sk-your-actual-api-key-here` with your real OpenAI API key.**

### Step 3: Get Your OpenAI API Key

If you don't have one:
1. Go to: https://platform.openai.com/api-keys
2. Sign in or create an account
3. Click "Create new secret key"
4. Copy the key (starts with `sk-`)
5. Paste it in the `.env` file

### Step 4: Start Server Again

After creating the `.env` file:

```bash
cd /Users/gbc/code/mindPro/backend
PORT=3001 node server.js
```

---

## 📝 Example .env File

```
OPENAI_API_KEY=sk-proj-abc123xyz...
PORT=3001
```

---

## 🔒 Security Note

- **Never commit** the `.env` file to git
- The `.env` file should be in `.gitignore`
- Keep your API key secret

---

## ✅ Verify Setup

After creating `.env` and starting the server, you should see:

```
✅ OpenAI initialized
🔧 Development mode: Running without Firebase Admin auth
Server running on http://localhost:3001
```

---

*Create the .env file with your OpenAI API key and restart the server!*








