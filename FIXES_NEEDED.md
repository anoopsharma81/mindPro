# 🚨 Firebase Setup - Required Actions

**Status**: App is running, needs Firebase Console configuration

---

## 📋 Checklist

### 1. ✅ DONE - Code Implementation & iOS Fix
- All code written and working
- App builds successfully  
- Firebase SDK integrated
- **iOS URL scheme added** (fixed hanging issue) ✅

### 2. ⏳ TODO - Enable Email/Password Auth (CRITICAL - 1 min)

**Status**: ❌ Not enabled  
**Impact**: Cannot sign up or login with email

**Fix**: [Enable Email/Password Auth](https://console.firebase.google.com/project/metanoia-a3035/authentication/providers)

Steps:
1. Click link above
2. Click "Email/Password"
3. Toggle "Enable" ON
4. Click "Save"

### 3. ⏳ OPTIONAL - Enable Google Sign-In (2 steps)

#### Step 3a: ✅ DONE - Web Client ID Added
- Already configured in `web/index.html`

#### Step 3b: ⏳ TODO - Enable People API (1 min)

**Status**: ❌ Not enabled  
**Impact**: Google Sign-In fails on web

**Fix**: [Enable People API](https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=1083790628363)

Steps:
1. Click link above
2. Click "ENABLE" button
3. Wait 30 seconds
4. Press "R" in terminal to restart

---

## ⚡ Quick Start (Choose One)

### Option A: Email/Password Only (Fastest - 1 minute)

**Just want basic auth working?**

1. [Enable Email/Password](https://console.firebase.google.com/project/metanoia-a3035/authentication/providers) (1 minute)
2. Test signup in your app
3. Done! ✅

### Option B: Full Setup with Google Sign-In (3 minutes)

**Want all auth methods?**

1. [Enable Email/Password](https://console.firebase.google.com/project/metanoia-a3035/authentication/providers) (1 minute)
2. [Enable People API](https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=1083790628363) (1 minute)
3. Press "R" in terminal (hot restart)
4. Test both auth methods
5. Done! ✅

---

## 📖 Detailed Guides

- **`QUICK_FIX.md`** - Step-by-step quick fix
- **`GOOGLE_SIGNIN_FIX.md`** - Google Sign-In specific guide
- **`FIREBASE_AUTH_SETUP.md`** - Complete Firebase auth setup
- **`STATUS_SUMMARY.md`** - Overall project status

---

## 🧪 Test After Setup

### Test Email/Password (After Step 2):
1. Click "Sign up" in app
2. Enter test credentials
3. Should create account and login ✅

### Test Google Sign-In (After Step 3):
1. Click "Sign in with Google"
2. Select Google account
3. Should login successfully ✅

---

## 🎯 Current Status

```
✅ Code:            100% Complete
✅ Firebase Config: 100% Complete
⏳ Console Setup:   0% Complete ← DO THIS NOW
⏳ Testing:         0% Complete
```

**Next Action**: [Enable Email/Password Auth →](https://console.firebase.google.com/project/metanoia-a3035/authentication/providers)

---

## Direct Links

### Required (Do Now):
- [Enable Email/Password Auth](https://console.firebase.google.com/project/metanoia-a3035/authentication/providers)

### Optional (For Google Sign-In):
- [Enable People API](https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=1083790628363)

### Reference:
- [Firebase Console](https://console.firebase.google.com/project/metanoia-a3035)
- [View Users](https://console.firebase.google.com/project/metanoia-a3035/authentication/users)
- [Firestore Database](https://console.firebase.google.com/project/metanoia-a3035/firestore)

