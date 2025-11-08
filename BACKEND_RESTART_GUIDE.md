# Backend Server Restart Guide

## When to Restart

Restart the backend server whenever you make changes to:
- ✅ `backend/server.js` - API endpoints, prompts, logic
- ✅ `backend/prompts/*.txt` - If loading from files (future)
- ✅ Environment variables in `.env`
- ✅ Any backend code changes

## How to Restart

### Option 1: Quick Restart (Recommended)
```bash
# Find and kill the current server process
ps aux | grep "node server.js" | grep -v grep | awk '{print $2}' | xargs kill

# Start the server again
cd backend
PORT=3001 node server.js
```

### Option 2: Using Process ID
```bash
# Find the process ID
ps aux | grep "node server.js" | grep -v grep

# Kill it
kill <PID>

# Start again
cd backend
PORT=3001 node server.js
```

### Option 3: Ctrl+C (If Running in Foreground)
- Press `Ctrl+C` in the terminal running the server
- Start again: `PORT=3001 node server.js`

## Verify Server is Running

```bash
curl http://localhost:3001/api/health
```

Should return:
```json
{"status":"ok","message":"Metanoia Backend API","openai":true,"firebase":false}
```

## Recent Changes Applied

✅ **Updated Clinical Reasoning Framework**
- Changed: `COGNITIVE PROCESS` → `PATTERN RECOGNITION`
- File: `backend/server.js` (lines 186, 218)
- Status: **Server restarted - changes are now live!**

## Testing the Changes

### Test Self-Play with Clinical Case
```bash
curl -X POST http://localhost:3001/api/reflection/selfplay \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Clinical Case",
    "year": "2025",
    "context": "Patient presented with ataxia and confusion. Clinical examination revealed..."
  }'
```

The AI response should now use "PATTERN RECOGNITION" instead of "COGNITIVE PROCESS".

## Auto-Restart Options

### Using nodemon (Development)
```bash
cd backend
npm install -g nodemon
nodemon server.js
```

Benefits:
- Auto-restarts on file changes
- No manual restart needed
- Great for development

### Using PM2 (Production-like)
```bash
npm install -g pm2
cd backend
pm2 start server.js --name metanoia-backend --watch

# View logs
pm2 logs

# Restart manually if needed
pm2 restart metanoia-backend
```

## Current Server Status

🟢 **Backend Server: RUNNING**
- URL: `http://localhost:3001`
- Status: Healthy
- OpenAI: Connected
- Changes: Applied ✅

## Troubleshooting

**Server won't start:**
- Check if port 3001 is already in use: `lsof -i :3001`
- Check environment variables: `cat backend/.env`
- Check OpenAI API key is set

**Changes not reflecting:**
- Verify you restarted the server
- Check the correct file was edited
- Clear any caches if applicable

**Connection refused from iPhone:**
- Ensure server is running: `curl http://localhost:3001/api/health`
- Check both devices on same WiFi
- Verify Mac hostname: `hostname`
- Test network URL: `curl http://Anups-Laptop.local:3001/api/health`

---

**Last Restart**: Just now
**Status**: ✅ All changes applied and live

