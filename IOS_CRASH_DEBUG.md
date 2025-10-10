# iOS App Crash - Debugging Guide

## Issue
App launches on iOS simulator but immediately crashes with "Lost connection to device"

## Timeline
```
✅ Xcode build done (46.1s)
✅ Firebase initialized
✅ Firestore offline persistence enabled
✅ Hive initialized
❌ Lost connection to device (app crashed)
```

---

## Likely Causes

### 1. Firebase Auth Not Enabled (Most Likely)
The app tries to use Firebase Auth on startup, but the auth providers aren't enabled.

**Fix**: Enable Email/Password auth in Firebase Console (1 minute)
- [Enable Email/Password Auth](https://console.firebase.google.com/project/metanoia-a3035/authentication/providers)

### 2. Missing iOS Permissions
iOS requires certain permissions in Info.plist

### 3. Firebase Configuration Issue
iOS-specific Firebase setup might have an issue

---

## Quick Fix Steps

### Step 1: Enable Firebase Auth (CRITICAL)
This is likely causing the crash.

1. Go to [Firebase Console](https://console.firebase.google.com/project/metanoia-a3035/authentication/providers)
2. Click "Email/Password"
3. Toggle "Enable" ON
4. Click "Save"
5. Restart the app

### Step 2: Check Xcode Console for Crash Logs

Run with Xcode to see detailed crash logs:

```bash
# Open Xcode
open ios/Runner.xcworkspace

# Then in Xcode:
# 1. Select iPhone simulator from device dropdown
# 2. Click Run (▶️) button
# 3. Watch console at bottom for error messages
```

### Step 3: Check iOS Permissions

Let me check your Info.plist...

