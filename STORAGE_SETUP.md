# Firebase Storage Setup Guide

## Issue Found
Firebase Storage is not enabled in your Firebase project `metanoia-a3035`. This is causing the photo upload error:
```
Firebase Storage: Max retry time for operation exceeded
```

## Quick Fix - Enable Firebase Storage

### Step 1: Open Firebase Console
Go to: https://console.firebase.google.com/project/metanoia-a3035/storage

### Step 2: Click "Get Started"
1. Click the **"Get Started"** button
2. In the dialog, click **"Next"** to accept the default settings
3. Click **"Done"**

### Step 3: Storage Rules (Already Created ✅)
The storage rules file has already been created at `storage.rules`:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User uploads - only owners can read/write their own files
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### Step 4: Deploy Storage Rules
After enabling Storage in the console, run:
```bash
firebase deploy --only storage
```

## What This Fixes
- ✅ Photo upload from CPD Import feature
- ✅ Document upload for AI extraction
- ✅ Any file uploads to Firebase Storage

## Storage Structure
Files will be organized as:
```
users/
  {userId}/
    extractions/
      photo-{timestamp}.jpeg
      photo-{timestamp}.png
      document-{timestamp}.pdf
```

## Security
- Only authenticated users can upload files
- Users can only access their own files
- All uploads are scoped to the user's folder

## Alternative Temporary Fix (Testing Only)
If you want to test without setting up Storage right away, you can temporarily disable the photo upload feature. But it's better to just enable Storage properly.

## Next Steps
1. ✅ Open the link above and click "Get Started"
2. ✅ Run `firebase deploy --only storage`
3. ✅ Restart your app (hot reload with 'r')
4. ✅ Try uploading a photo again

