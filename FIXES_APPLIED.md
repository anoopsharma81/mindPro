# Fixes Applied - October 16, 2025

## Issues Fixed

### 1. ✅ Type Casting Error in Reflections
**Error**: `type 'int' is not a subtype of type 'double?' in type cast`

**Location**: `lib/features/reflections/data/reflection.dart:90`

**Cause**: Firestore was storing the `score` field as an `int`, but the code expected a `double`.

**Fix**: Updated the `fromJson` method to handle both types:
```dart
// Before:
score: j['score'] as double?,

// After:
score: j['score'] != null ? (j['score'] as num).toDouble() : null,
```

**Status**: ✅ Fixed

---

### 2. ✅ Backend API Connection Error (localhost)
**Error**: `DioException [connection error]` when trying to reach API from iPhone

**Cause**: API URL was set to `localhost:3001`, which doesn't work from physical devices.

**Fix**: 
1. Updated `lib/core/env.dart` to use your computer's IP address:
   ```dart
   defaultValue: 'http://192.168.1.35:3001/api',
   ```
2. Started the backend server on port 3001

**Status**: ✅ Fixed
**Note**: Both iPhone and Mac must be on the same WiFi network

---

### 3. ⚠️ Firebase Storage Not Enabled
**Error**: `Firebase Storage: Max retry time for operation exceeded`

**Cause**: Firebase Storage service was never enabled in the Firebase Console.

**Fixes Applied**:
1. ✅ Created `storage.rules` file with proper security rules
2. ✅ Updated `firebase.json` to reference storage rules
3. ✅ Added better error messages in the app
4. ⏳ **NEEDS MANUAL ACTION**: Enable Storage in Firebase Console

**What Users See Now**:
Instead of a cryptic error, users now get a helpful message:
```
Firebase Storage is not enabled.

Please ask your administrator to:
1. Go to Firebase Console > Storage
2. Click "Get Started"
3. Deploy storage rules

For now, you can create reflections manually.
```

**Manual Steps Required**:
1. Go to: https://console.firebase.google.com/project/metanoia-a3035/storage
2. Click "Get Started"
3. Click "Next" → "Done"
4. Run: `firebase deploy --only storage`

**Status**: ⚠️ Partially fixed (better error handling added, but Storage needs manual enablement)

---

## Files Modified

### Core Files
- `lib/core/env.dart` - Updated API URL to use local IP
- `lib/features/reflections/data/reflection.dart` - Fixed type casting
- `lib/features/reflections/presentation/reflection_from_document_page.dart` - Better error handling

### New Files Created
- `storage.rules` - Firebase Storage security rules
- `STORAGE_SETUP.md` - Setup guide for Firebase Storage
- `FIXES_APPLIED.md` - This file

### Configuration Files
- `firebase.json` - Added storage rules reference

---

## What's Working Now

✅ Reflections load without crashes  
✅ Type casting errors are handled gracefully  
✅ Backend API is accessible from iPhone  
✅ Better error messages for storage issues  
✅ Backend server is running on port 3001  

---

## What Still Needs Manual Action

⏳ **Enable Firebase Storage** (5 minutes)
   - See: `STORAGE_SETUP.md`
   - Link: https://console.firebase.google.com/project/metanoia-a3035/storage

---

## Testing Checklist

After enabling Firebase Storage:

- [ ] Upload a photo from the app
- [ ] Create a reflection from document
- [ ] Verify files appear in Firebase Storage Console
- [ ] Test on both iPhone and Chrome
- [ ] Verify storage rules are working (users can only access their own files)

---

## Network Configuration

**Current Setup**:
- **Computer IP**: 192.168.1.35
- **Backend Port**: 3001
- **API URL**: http://192.168.1.35:3001/api

**If WiFi changes or IP changes**:
1. Get new IP: `ifconfig | grep "inet " | grep -v 127.0.0.1`
2. Update `lib/core/env.dart`
3. Restart app with hot restart (R)

---

## Rollback Instructions

If you need to revert these changes:

1. **Reflection type fix**:
   ```dart
   score: j['score'] as double?,
   ```

2. **API URL**:
   ```dart
   defaultValue: 'http://localhost:3001/api',
   ```

3. **Storage rules**: Delete `storage.rules` and revert `firebase.json`

---

## Summary

**Before**: 
- ❌ App crashed when loading reflections
- ❌ API unreachable from iPhone  
- ❌ Photo uploads failed silently
- ❌ Confusing error messages

**After**:
- ✅ Reflections load correctly
- ✅ API accessible from iPhone
- ✅ Clear error messages
- ⚠️ Photo uploads will work once Storage is enabled

**Next Step**: Enable Firebase Storage (takes 5 minutes)

