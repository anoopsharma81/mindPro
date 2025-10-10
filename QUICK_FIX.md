# 🚨 Quick Fix - Enable Firebase Authentication

Your app is running but authentication needs to be configured in Firebase Console.

## ⚡ 2-Minute Fix

### Step 1: Enable Email/Password Authentication (1 minute)

1. Open [Firebase Console](https://console.firebase.google.com/project/metanoia-a3035/authentication/providers)
2. Click on **"Email/Password"** in the sign-in methods list
3. Toggle **"Enable"** to ON
4. Click **"Save"**

✅ **Email/Password signup will now work!**

---

### Step 2: Fix Google Sign-In for Web (Optional - 3 minutes)

#### Get Your Web Client ID:

1. Go to [Firebase Project Settings](https://console.firebase.google.com/project/metanoia-a3035/settings/general)
2. Scroll down to **"Your apps"**
3. Find your **Web app** configuration
4. Copy the **Web Client ID** (looks like: `123456789-abc123def456.apps.googleusercontent.com`)

#### Add it to your app:

Open `web/index.html` and uncomment/update line 26:

```html
<!-- Change this: -->
<!-- <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com"> -->

<!-- To this (with your actual client ID): -->
<meta name="google-signin-client_id" content="1083790628363-YOUR_ACTUAL_ID.apps.googleusercontent.com">
```

#### Restart the app:

In your terminal where Flutter is running, press **"R"** (capital R) for hot restart.

---

### Step 3: Enable Google People API (Required for Google Sign-In - 1 minute)

Google Sign-In needs the People API to fetch user profile info.

**Direct Link**: [Enable People API](https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=1083790628363)

1. Click the link above (or go to Google Cloud Console)
2. Make sure project `1083790628363` is selected
3. Click **"ENABLE"** button
4. Wait ~30 seconds for it to activate
5. Hot restart your app (press "R")

✅ **Google Sign-In will now work!**

---

## Test It Out

### Email/Password Signup (Should work immediately after Step 1):

1. In your running app, click **"Sign up"**
2. Fill in:
   - Name: Test User
   - GMC: 1234567
   - Email: test@example.com
   - Password: password123
3. Click **"Sign Up"**
4. ✅ You should be logged in and see the dashboard!

### Email/Password Login:

1. Enter the email and password you just created
2. Click **"Sign in"**
3. ✅ You should be logged in!

---

## Current Status

### ✅ Working Now:
- Firebase is initialized
- Firestore is ready
- App loads successfully

### ⚠️ Needs Firebase Console Config (2 minutes):
- **Email/Password authentication** - Must enable in console
- **Google Sign-In (Web)** - Optional, needs client ID

### 📝 Optional Later:
- Firestore security rules
- Apple Sign-In (requires Apple Developer account)

---

## Quick Commands

If you closed the app, restart it with:

```bash
# For Web (Chrome):
flutter run -d chrome

# For iOS Simulator:
flutter run -d iPhone

# For Android:
flutter run -d android
```

---

## Need Help?

- See `FIREBASE_AUTH_SETUP.md` for detailed instructions
- See `FIREBASE_SETUP.md` for Firebase configuration details
- See `IMPLEMENTATION_STATUS.md` for overall project status

---

## Direct Links

- [Enable Email/Password Auth](https://console.firebase.google.com/project/metanoia-a3035/authentication/providers)
- [Get Web Client ID](https://console.firebase.google.com/project/metanoia-a3035/settings/general)
- [Firestore Database](https://console.firebase.google.com/project/metanoia-a3035/firestore)
- [Authentication Users](https://console.firebase.google.com/project/metanoia-a3035/authentication/users)

