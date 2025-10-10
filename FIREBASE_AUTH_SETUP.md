# Firebase Authentication Setup Guide

## Current Issues ⚠️

Based on the error logs, you need to enable authentication methods in Firebase Console:

### 1. Email/Password Authentication - NOT ENABLED ❌

**Error**: `[firebase_auth/operation-not-allowed] The given sign-in provider is disabled`

**Fix**:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `metanoia-a3035`
3. Navigate to **Authentication** → **Sign-in method** tab
4. Click on **Email/Password**
5. Toggle **Enable** to ON
6. Click **Save**

### 2. Google Sign-In Web Client ID - NOT CONFIGURED ❌

**Error**: `ClientID not set. Either set it on a <meta name="google-signin-client_id" content="CLIENT_ID" /> tag`

**Fix for Web**:

#### Option A: Add Client ID to HTML (Recommended)
1. Get your **Web Client ID** from Firebase Console:
   - Go to Firebase Console → Project Settings → General
   - Scroll to "Your apps" → Web app
   - Copy the **Web Client ID** (looks like: `123456789-abc123.apps.googleusercontent.com`)

2. Add to `web/index.html`:
   ```html
   <head>
     ...
     <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID_HERE">
     ...
   </head>
   ```

#### Option B: Pass Client ID in Code
Update `lib/services/auth_service.dart`:
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'YOUR_WEB_CLIENT_ID_HERE', // Add this for web
);
```

---

## Complete Setup Checklist

### Firebase Console Setup

- [ ] **Enable Email/Password Authentication**
  - Go to Authentication → Sign-in method
  - Enable Email/Password provider
  - Save

- [ ] **Enable Google Sign-In** (if not already enabled)
  - Go to Authentication → Sign-in method
  - Enable Google provider
  - Configure support email
  - Save

- [ ] **Get Web Client ID**
  - Go to Project Settings → General
  - Find your Web app
  - Copy the Web Client ID
  - Add to `web/index.html` or code

- [ ] **Optional: Enable Apple Sign-In** (requires Apple Developer account)
  - Go to Authentication → Sign-in method
  - Enable Apple provider
  - Configure service ID and key

### Firestore Security Rules (Important!)

- [ ] **Set up security rules**
  - Go to Firestore Database → Rules
  - Copy the rules from below:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isOwner(uid) { 
      return request.auth != null && request.auth.uid == uid; 
    }
    
    match /profiles/{uid} {
      allow read, update, delete: if isOwner(uid);
      allow create: if request.auth != null && request.auth.uid == uid;
      
      match /years/{year} {
        allow read, write: if isOwner(uid);
        match /reflections/{rid} { allow read, write: if isOwner(uid); }
        match /cpd/{cid} { allow read, write: if isOwner(uid); }
      }
    }
  }
}
```

---

## Quick Fix Steps (5 minutes)

1. **Enable Email/Password** (1 minute)
   ```
   Firebase Console → Authentication → Sign-in method → 
   Email/Password → Enable → Save
   ```

2. **Get Web Client ID** (1 minute)
   ```
   Firebase Console → Project Settings → General → 
   Your apps (Web) → Copy Web Client ID
   ```

3. **Add to web/index.html** (2 minutes)
   ```html
   <meta name="google-signin-client_id" content="PASTE_CLIENT_ID_HERE">
   ```

4. **Hot Restart App** (1 minute)
   ```bash
   # In terminal where Flutter is running:
   Press "r" to hot reload
   # OR
   Press "R" to hot restart
   ```

---

## Testing After Setup

Once configured, test:

1. **Email/Password Sign-Up**
   - Click "Sign up" in the app
   - Enter name, GMC, email, password
   - Should create account successfully

2. **Email/Password Login**
   - Enter email and password
   - Should log in successfully

3. **Google Sign-In** (Web only after client ID is added)
   - Click "Sign in with Google"
   - Should open Google account selector
   - Should authenticate successfully

4. **Profile Creation**
   - After sign up, profile should be created in Firestore
   - Dashboard should show "Welcome, [Name]"
   - Year selector should appear

---

## Current Status

### What's Working ✅
- Firebase initialized
- Firestore offline persistence enabled
- App loads successfully
- Login/Signup UI displays

### What Needs Configuration ⚠️
- Email/Password auth (2 minutes to fix)
- Google Sign-In web client ID (3 minutes to fix)
- Firestore security rules (optional but recommended)

### What's Optional 📝
- Apple Sign-In (requires Apple Developer account)
- Anonymous auth (not currently used)

---

## Environment Variables (Optional)

If you want to keep client IDs in `.env` file:

1. Create `.env` file:
   ```bash
   GOOGLE_CLIENT_ID_WEB=your-web-client-id
   GOOGLE_CLIENT_ID_IOS=your-ios-client-id
   ```

2. Add to `.gitignore`:
   ```
   .env
   ```

3. Update `auth_service.dart` to read from env

---

## Troubleshooting

### Error: "operation-not-allowed"
**Cause**: Auth provider not enabled in Firebase Console  
**Fix**: Enable Email/Password in Firebase Console → Authentication

### Error: "ClientID not set"
**Cause**: Google Sign-In client ID not configured for web  
**Fix**: Add client ID to `web/index.html` meta tag

### Error: "PERMISSION_DENIED"
**Cause**: Firestore security rules not set up  
**Fix**: Add security rules in Firestore Database → Rules

### Users can't sign up/login
**Cause**: Authentication not enabled  
**Fix**: Enable auth providers in Firebase Console

---

## Next Steps After Auth Setup

1. Test sign-up flow
2. Test login flow
3. Verify profile creation in Firestore
4. Test year selector
5. Begin Phase 2 (AI Integration)

---

## Support Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Firebase Auth](https://firebase.flutter.dev/docs/auth/overview/)

