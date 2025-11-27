# Fix Backend Connection Error

## ❌ Problem

The app is trying to connect to `anups-laptop.local` but that hostname doesn't exist:
```
Failed host lookup: 'anups-laptop.local'
```

## ✅ Fix Applied

I've updated the API URL in `lib/core/env.dart` to use your current Mac's IP address:
- **Old**: `http://Anups-Laptop.local:3001/api`
- **New**: `http://192.168.1.189:3001/api`

---

## 🚀 **Next Steps**

### 1. Start the Backend Server

The backend server needs to be running. Open a new Terminal window and run:

```bash
cd backend
npm start
```

Or if you have a different start command:
```bash
cd backend
PORT=3001 node server.js
```

The server should show:
```
✅ OpenAI initialized
Server running on http://localhost:3001
```

### 2. Verify Backend is Accessible

Test from Terminal:
```bash
curl http://192.168.1.189:3001/api/health
```

Should return:
```json
{"status":"ok","message":"Metanoia Backend API","openai":true,"firebase":false}
```

### 3. Restart the App

After starting the backend:
1. **Hot restart** the Flutter app (press `r` in the terminal where `flutter run` is running)
2. Or stop and run again: `flutter run`

---

## 🔍 **Network Requirements**

For the iPhone to connect to your Mac's backend:

1. **Same WiFi Network**: iPhone and Mac must be on the same WiFi
2. **Backend Running**: Server must be running on port 3001
3. **Firewall**: Mac firewall should allow connections on port 3001

---

## 💡 **Alternative: Use Mac's Hostname**

If you prefer using a hostname instead of IP (easier if IP changes):

Update `lib/core/env.dart`:
```dart
return 'http://Govinds-MacBook-Pro.local:3001/api';
```

**Note**: `.local` hostnames sometimes don't work reliably on iOS. IP address is more reliable.

---

## ✅ **Current Configuration**

- **API URL**: `http://192.168.1.189:3001/api`
- **Mac IP**: 192.168.1.189
- **Mac Hostname**: Govinds-MacBook-Pro.local
- **Backend Port**: 3001

---

*Once the backend is running, the app should connect successfully!*








