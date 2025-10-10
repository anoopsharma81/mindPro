# Metanoia Flutter Implementation Status

## Phase 1: Foundation - PARTIALLY COMPLETE

### ✅ Completed (Ready for Firebase setup)

1. **Dependencies Added** (`pubspec.yaml`)
   - Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
   - Auth providers: `google_sign_in`, `sign_in_with_apple`
   - HTTP client: `dio`
   - Secure storage: `flutter_secure_storage`
   - Utilities: `url_launcher`, `flutter_dotenv`
   - Observability: `sentry_flutter`

2. **Core Infrastructure**
   - `lib/core/env.dart` - Environment configuration
   - `lib/core/logger.dart` - Logging utility
   - `lib/core/http_client.dart` - Dio HTTP client with Firebase Auth interceptor

3. **Services**
   - `lib/services/auth_service.dart` - Firebase Auth wrapper (email/password, Google, Apple)
   - `lib/services/firestore_service.dart` - Firestore helpers
   - `lib/services/api_service.dart` - Backend API client (selfplay, reinforce, cpd, export)

4. **Data Models**
   - `lib/features/profile/profile_model.dart` - Profile and YearConfig models
   - `lib/features/profile/profile_repository.dart` - Profile/year CRUD operations

5. **State Management**
   - `lib/features/auth/auth_provider.dart` - Riverpod providers for auth state, profile, year selection

6. **UI - Auth**
   - `lib/features/auth/login_page.dart` - Login page with email/password and Google sign-in
   - `lib/features/auth/signup_page.dart` - Signup page with profile creation

7. **UI - Dashboard**
   - Updated `lib/features/dashboard/dashboard_page.dart` - Now includes:
     - Welcome message with user name
     - Year selector dropdown
     - Logout button
     - Icons for quick actions

8. **Router Updates**
   - Updated `lib/router.dart` - Added:
     - Auth routes (`/login`, `/signup`)
     - Auth guard (redirect to login if not authenticated)
     - Redirect to home if already authenticated

9. **Main App**
   - Updated `lib/main.dart` - Firebase initialization on app start

### ✅ Firebase Setup - COMPLETE

**Firebase Project**: `metanoia-a3035`

1. **Firebase Project** ✅
   - Project created and configured
   - Authentication enabled (Email/Password, Google, Apple)
   - Firestore Database enabled
   - Storage enabled

2. **Firebase iOS Configuration** ✅
   - `ios/Runner/GoogleService-Info.plist` added
   - iOS deployment target updated to 13.0
   - Pod install completed (40 pods)
   - App ID: `1:1083790628363:ios:3bea9c1aba4b9b3ec4590e`

3. **Firebase Android Configuration** ✅
   - `android/app/google-services.json` added
   - Google Services plugin configured
   - App ID: `1:1083790628363:android:e42d61f21952047bc4590e`

4. **Firebase Options** ✅
   - `lib/firebase_options.dart` generated
   - Platform-specific configurations for iOS, Android, Web
   - Firebase initialized in main.dart with proper options

5. **Dependencies** ✅
   - All packages installed
   - Firebase SDK 11.15.0
   - Build configurations updated

6. **Update Firestore Security Rules** ⚠️ TODO
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

### 📝 TODO - Phase 1 Remaining

1. Migrate reflection repository to use Firestore (currently uses Hive)
2. Migrate CPD repository to use Firestore (currently uses Hive)
3. Update reflection model to add: `score`, `iterations[]`, `rating`, `domains[1..4]`
4. Update CPD model to add: `autoTags: {type, domains, impact}`
5. Create profile/year editor UI pages
6. Test auth flow end-to-end

---

## Phase 2: AI Integration - NOT STARTED

Requires:
- Backend API running at `http://localhost:3000/api`
- Endpoints: `/reflection/selfplay`, `/reflection/reinforce`
- Update reflection model with AI fields
- Build self-play UI component

---

## Phase 3: Enhanced Export & CPD - NOT STARTED

Requires:
- Backend API endpoints: `/cpd`, `/export`
- Update CPD model with auto-tagging fields
- Build export UI with signed URL download

---

## Phase 4: Security & Privacy - NOT STARTED

Requires:
- PHI detection regex/classifier
- Privacy policy page
- Data deletion UI
- Secure storage for tokens

---

## Phase 5: Testing & CI/CD - NOT STARTED

Requires:
- Unit tests
- Widget tests
- Integration tests
- GitHub Actions setup

---

## Phase 6: Polish & Pilot - NOT STARTED

Requires:
- Onboarding flow
- Empty states
- Performance optimization
- Pilot user materials

---

## Quick Start (After Firebase Setup)

```bash
# 1. Set up Firebase (see above)

# 2. Install dependencies
flutter pub get

# 3. Run on iOS
flutter run -d 375EEFCC-E77C-4201-9F52-EF2CFECAF690

# 4. Create an account
# - App will open to login page
# - Click "Sign up"
# - Enter name, GMC number, email, password
# - Account created with default year (current year)

# 5. Test features
# - Dashboard shows welcome message and year selector
# - Reflections/CPD still use Hive (to be migrated)
# - Export still uses local markdown (to be upgraded)
```

---

## Architecture Decisions Made

1. **Hybrid Storage (Temporary)**
   - Firebase for auth and profiles
   - Hive for reflections/CPD (during migration)
   - Will fully migrate to Firestore in next iteration

2. **Auth Strategy**
   - Email/password primary
   - Google sign-in secondary
   - Apple sign-in prepared (requires Apple Developer account)

3. **Year-Based Data Scoping**
   - All reflections/CPD scoped to `{uid}/years/{year}/`
   - Year selector in dashboard
   - Profile stores default year

4. **API-First for AI Features**
   - Self-play, export, auto-tagging all server-side
   - Client calls REST endpoints
   - Auth via Firebase ID tokens

5. **Offline-First Strategy**
   - Firestore persistence enabled
   - Local Hive cache as fallback
   - Graceful degradation if backend unavailable

---

## Known Issues

1. ~~**Flutter SDK Permissions**~~ ✅ RESOLVED
   - Fixed with system Flutter

2. ~~**Firebase Not Configured**~~ ✅ RESOLVED
   - All Firebase config files added
   - iOS and Android properly configured

3. **Tests Not Updated** ❌
   - Default `test/widget_test.dart` references non-existent `MyApp`
   - Need to update or remove before tests can run
   - See `TEST_PROGRESS.md` for details

4. **Backend API Not Running** ⚠️
   - Self-play, auto-tagging, enhanced export won't work
   - Need to build or provide backend separately

4. **Data Migration Needed**
   - Existing Hive data not automatically migrated
   - Users would lose data on upgrade
   - Need migration script or keep Hive as fallback

---

## Next Immediate Steps

1. ✅ Dependencies added
2. ✅ Core services created
3. ✅ Auth UI created
4. ✅ Flutter permissions fixed
5. ✅ Firebase project created (metanoia-a3035)
6. ✅ Firebase config files added
7. ✅ Pods installed (iOS)
8. ⏳ **NEXT: Test auth flow**
9. ⏳ Set up Firestore security rules
10. ⏳ Migrate repositories to Firestore
11. ⏳ Update data models for AI
12. ⏳ Write unit tests

---

## File Structure Created

```
lib/
├── core/
│   ├── env.dart                     # Environment config
│   ├── logger.dart                  # Logging utility
│   └── http_client.dart            # Dio with auth
├── services/
│   ├── auth_service.dart           # Firebase Auth
│   ├── firestore_service.dart      # Firestore helpers
│   └── api_service.dart            # Backend API
├── features/
│   ├── auth/
│   │   ├── auth_provider.dart      # Riverpod providers
│   │   ├── login_page.dart         # Login UI
│   │   └── signup_page.dart        # Signup UI
│   ├── profile/
│   │   ├── profile_model.dart      # Data models
│   │   └── profile_repository.dart # CRUD operations
│   ├── dashboard/
│   │   └── dashboard_page.dart     # Updated with year selector
│   ├── reflections/
│   │   └── ... (existing, needs Firestore migration)
│   ├── cpd/
│   │   └── ... (existing, needs Firestore migration)
│   └── export/
│       └── ... (existing, needs API integration)
├── main.dart                        # Firebase init
├── router.dart                      # Auth guards
└── app.dart                         # Main app widget
```

