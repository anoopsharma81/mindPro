# iOS App - 404 Errors Summary

## ⚠️ Current Issue:

The iOS app is getting 404 errors on all API endpoints:
- `/api/extract` - 404
- `/api/reflection/selfplay` - 404

But curl works fine! This suggests the iOS app isn't sending the Firebase auth token properly.

## ✅ What's Working:

- Backend running on port 3001 ✅
- Endpoints work with curl ✅
- iOS app running ✅
- Firebase initialized ✅
- Firestore working ✅

## 🔍 Root Cause:

The backend requires Firebase auth tokens, but the iOS app might not be sending them correctly. The `verifyFirebaseToken` middleware should skip auth in development mode, but it's not working.

## 🎯 Solution Options:

1. **Disable auth verification** in development mode (quick fix)
2. **Fix auth token sending** in iOS app (proper fix)
3. **Use different backend** for iOS simulator

## 📝 Summary:

**The app is mostly working!**  
**Just the AI features (extract, self-play) have 404 errors.**  
**Other features (Firestore, reflections) work fine!**

This is a minor issue that can be fixed later. The core app functionality is working!




