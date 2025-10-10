# Firestore Security Rules Deployment Guide

## Step 1: Deploy Security Rules

### Option A: Via Firebase Console (Recommended for now)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **metanoia-a3035**
3. Navigate to **Firestore Database** → **Rules** tab
4. Copy the contents from `firestore.rules` file in this repo
5. Paste into the rules editor
6. Click **Publish**

### Option B: Via Firebase CLI (For production)

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in the project (one-time)
firebase init firestore
# Select: Use an existing project → metanoia-a3035
# Firestore rules file: firestore.rules (already created)
# Firestore indexes file: firestore.indexes.json

# Deploy the rules
firebase deploy --only firestore:rules
```

---

## Step 2: Verify Security Rules

### Test Cases

1. **Unauthenticated Access** (should FAIL)
   ```
   Try to read /profiles/any-uid without auth
   Expected: Permission denied
   ```

2. **Own Profile Access** (should SUCCEED)
   ```
   Authenticated user reads /profiles/{their-uid}
   Expected: Data returned
   ```

3. **Other User Profile Access** (should FAIL)
   ```
   Authenticated user reads /profiles/{other-uid}
   Expected: Permission denied
   ```

4. **Year-Scoped Data** (should SUCCEED)
   ```
   User creates reflection at /profiles/{uid}/years/2025/reflections/{rid}
   Expected: Success
   ```

5. **Cross-User Data Access** (should FAIL)
   ```
   User A tries to read User B's reflections
   Expected: Permission denied
   ```

---

## Current Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is the owner
    function isOwner(uid) { 
      return request.auth != null && request.auth.uid == uid; 
    }
    
    // User profiles - only the owner can access
    match /profiles/{uid} {
      allow read, update, delete: if isOwner(uid);
      allow create: if request.auth != null && request.auth.uid == uid;
      
      // Year configurations - scoped to user
      match /years/{year} {
        allow read, write: if isOwner(uid);
        
        // Reflections - scoped to user and year
        match /reflections/{rid} { 
          allow read, write: if isOwner(uid); 
        }
        
        // CPD entries - scoped to user and year
        match /cpd/{cid} { 
          allow read, write: if isOwner(uid); 
        }
      }
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## Data Structure

```
firestore/
└── profiles/
    └── {uid}/                          # User ID from Firebase Auth
        ├── displayName: string
        ├── gmcNumber: string
        ├── defaultYear: string
        ├── createdAt: timestamp
        └── updatedAt: timestamp
        
        └── years/
            └── {year}/                 # e.g., "2025"
                ├── specialty: string
                ├── org: string
                ├── appraiserName: string
                ├── appraiserRole: string
                ├── appraisalDate: timestamp
                └── location: string
                
                ├── reflections/
                │   └── {rid}/          # Reflection ID (UUID)
                │       ├── id: string
                │       ├── title: string
                │       ├── what: string
                │       ├── soWhat: string
                │       ├── nowWhat: string
                │       ├── tags: array
                │       ├── createdAt: timestamp
                │       ├── updatedAt: timestamp
                │       └── linkedCpdIds: array
                │
                └── cpd/
                    └── {cid}/          # CPD ID (UUID)
                        ├── id: string
                        ├── type: string
                        ├── title: string
                        ├── hours: number
                        ├── date: timestamp
                        ├── notes: string
                        └── linkedReflectionIds: array
```

---

## Testing with Firebase Emulator (Optional)

For local testing without affecting production data:

```bash
# Install Firebase emulator
npm install -g firebase-tools

# Start emulators
firebase emulators:start

# Update lib/core/env.dart to point to emulator
# In dev mode: use localhost:8080 for Firestore
```

---

## Monitoring Access Patterns

1. **Firestore Usage**
   - Go to Firebase Console → Firestore Database → Usage tab
   - Monitor: Reads, Writes, Deletes
   - Set up billing alerts

2. **Security Rules Logs**
   - Go to Firestore → Rules → Logs
   - Review denied requests
   - Investigate suspicious patterns

---

## Compliance Notes

- ✅ Per-user data isolation enforced
- ✅ No cross-user data access possible
- ✅ Authentication required for all operations
- ✅ Year-based data scoping for portfolio management
- ⚠️ No automatic data retention/deletion (implement in Phase 4)
- ⚠️ No audit logging yet (implement in Phase 4)

---

## Next Steps

After deploying rules:

1. ✅ Run the app
2. ✅ Sign up a new account
3. ✅ Create a reflection → verify it appears in Firestore Console
4. ✅ Create a CPD entry → verify it appears in Firestore Console
5. ✅ Switch years → verify data is year-scoped
6. ✅ Sign out and sign in with different account → verify data isolation

---

**Status**: Rules file created ✅ | Deployment pending ⏳

