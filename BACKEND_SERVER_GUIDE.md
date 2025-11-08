# Backend Server Guide

## Quick Fix - Connection Refused Error

### Problem
```
SocketException: Connection refused, address = anups-laptop.local, port = 3001
```

This error means the backend server is not running on your Mac.

### Solution
```bash
# Start the backend server
cd backend
PORT=3001 node server.js
```

The server should show:
```
✅ OpenAI initialized
🔧 Development mode: Running without Firebase Admin auth
Server running on http://localhost:3001
```

### Keep Server Running

**Option 1: Terminal Tab (Recommended for Development)**
- Keep a terminal tab open with the server running
- Easy to see logs and errors
- Easy to restart

**Option 2: Background Process**
```bash
cd backend
nohup node server.js > backend.log 2>&1 &
```

To stop:
```bash
ps aux | grep "node server.js" | grep -v grep | awk '{print $2}' | xargs kill
```

**Option 3: Use PM2 (Production-like)**
```bash
# Install PM2
npm install -g pm2

# Start server
cd backend
pm2 start server.js --name metanoia-backend

# View status
pm2 status

# View logs
pm2 logs

# Stop server
pm2 stop metanoia-backend

# Restart server
pm2 restart metanoia-backend
```

### Checking Server Status

```bash
# Check if running
curl http://localhost:3001/api/health

# Should return:
# {"status":"ok","message":"Metanoia Backend API","openai":true,"firebase":false}

# Check from network (same command iPhone uses)
curl http://Anups-Laptop.local:3001/api/health
```

### Current Setup (Development)

```
iPhone App
    ↓
http://Anups-Laptop.local:3001/api
    ↓
Backend Server (Node.js) on Mac
    ↓
OpenAI API
```

**Limitations:**
- ❌ Mac must be on and running server
- ❌ iPhone and Mac must be on same network
- ❌ Server stops when Mac sleeps or terminal closes

### Future Setup (After Firebase Deployment)

```
iPhone App
    ↓
https://us-central1-metanoia-a3035.cloudfunctions.net
    ↓
Firebase Functions (Cloud)
    ↓
OpenAI API
```

**Benefits:**
- ✅ Works anywhere, anytime
- ✅ No Mac needed
- ✅ Auto-scaling
- ✅ Always available

## Development Workflow

### Daily Development
1. Start backend server:
   ```bash
   cd backend
   node server.js
   ```

2. Run Flutter app:
   ```bash
   flutter run
   ```

3. Test AI features on iPhone

### Troubleshooting

**Server won't start:**
```bash
# Check if port 3001 is already in use
lsof -i :3001

# Kill existing process
kill -9 <PID>
```

**Connection refused on iPhone:**
1. Check server is running: `curl http://localhost:3001/api/health`
2. Check Mac hostname: `hostname`
3. Check both devices on same WiFi
4. Check Mac firewall settings (System Preferences → Security & Privacy → Firewall)

**OpenAI API errors:**
1. Check `.env` file has `OPENAI_API_KEY`
2. Verify key is valid: `cat backend/.env`
3. Check OpenAI account has credits

## Environment Variables

Required in `backend/.env`:
```
OPENAI_API_KEY=sk-...
PORT=3001
NODE_ENV=development
```

## Next Steps

For production deployment (AI features work everywhere):
1. Follow `FIREBASE_DEPLOYMENT_GUIDE.md`
2. Deploy to Firebase Functions
3. Update Flutter app with cloud URLs
4. No more need to run local server!

