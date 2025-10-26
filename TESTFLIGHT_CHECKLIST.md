# TestFlight Preparation Checklist

## ✅ Completed (Automated)

- [x] **App Display Name**: Changed to "Metanoia" (was "Metanoia Flutter")
- [x] **App Version**: Set to 1.0.0+1 (ready for first TestFlight release)
- [x] **Privacy Descriptions**: All required permissions configured
  - Camera usage: "We need access to your camera to scan CPD certificates..."
  - Photo library: "We need access to your photo library to import CPD certificates..."
  - Photo library add: "We need permission to save exported documents..."
- [x] **App Description**: Updated to "NHS appraisal made easier - guided reflections and CPD tracking for doctors"

---

## 🔧 Next Steps (In Xcode)

### Step 1: Update Bundle Identifier (5 minutes)

**Current**: `com.example.metanoiaFlutter`
**Recommended**: `com.yourname.metanoia` or `uk.nhs.metanoia`

You'll change this when you open Xcode and configure signing (Step 3.4 in the guide).

**Examples**:
- `com.yourlastname.metanoia`
- `uk.co.yourcompany.metanoia`
- `uk.nhs.trust.metanoia`

**Note**: Must match the Bundle ID you create in App Store Connect!

---

### Step 2: Clean and Build (10 minutes)

Run these commands:

```bash
cd /Users/anup/code/Medflutter/metanoia_flutter
flutter clean
flutter pub get
flutter build ios --release
```

**Expected output**: "Built ios/Runner.app"

---

### Step 3: Configure Signing in Xcode (10 minutes)

1. Open workspace:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select **Runner** in project navigator (left sidebar)

3. Select **Runner** target

4. Go to **Signing & Capabilities** tab

5. Check **"Automatically manage signing"**

6. Select your **Team** (Apple Developer account)

7. Update **Bundle Identifier** to your chosen one (e.g., `com.yourname.metanoia`)

8. Verify no errors appear

---

### Step 4: Archive and Upload (15 minutes)

1. **Select destination**: Product → Destination → **Any iOS Device**

2. **Archive**: Product → **Archive**
   - Takes 2-5 minutes
   - Don't use your Mac during this time

3. **Distribute**: 
   - Organizer opens automatically
   - Click **"Distribute App"**
   - Select **"App Store Connect"**
   - Select **"Upload"**
   - Keep all default options
   - Click **"Upload"**

4. **Wait for processing**: 10-30 minutes
   - You'll receive email when ready

---

## 📱 App Information Summary

**For App Store Connect creation:**

| Field | Value |
|-------|-------|
| **App Name** | Metanoia |
| **Bundle ID** | `com.yourname.metanoia` (you'll create this) |
| **SKU** | `metanoia-001` |
| **Primary Language** | English (UK) |
| **Category** | Medical |
| **Privacy Policy** | (You'll need to provide URL) |

---

## 🎯 Privacy Policy Quick Setup

You need a privacy policy URL for TestFlight. Here are quick options:

### Option 1: Host on GitHub Pages (Free, 15 minutes)
1. Create a new repository: `metanoia-privacy-policy`
2. Create `index.html` with your privacy policy
3. Enable GitHub Pages
4. URL: `https://yourusername.github.io/metanoia-privacy-policy/`

### Option 2: Simple Google Doc (5 minutes)
1. Create Google Doc with privacy policy
2. Set sharing to "Anyone with the link"
3. Use that URL

### Option 3: Host on Firebase Hosting (10 minutes)
Since you're already using Firebase:
1. Create `privacy-policy.html`
2. Deploy to Firebase Hosting
3. URL: `https://metanoia-a3035.web.app/privacy-policy.html`

**Minimum Privacy Policy Contents**:
```
What data we collect: Email, reflections, CPD records
How we use it: Store securely in Firebase, never shared
User rights: Delete account, export data
Contact: your.email@example.com
```

---

## ⚠️ Common Issues

### "No matching provisioning profiles"
**Fix**: Uncheck and re-check "Automatically manage signing"

### "Bundle identifier already in use"
**Fix**: Choose a different bundle identifier

### "Your Apple ID doesn't have access"
**Fix**: Make sure you've enrolled in Apple Developer Program ($99/year)

### "Archive is processing forever"
**Fix**: Usually takes 15-30 minutes, check App Store Connect

---

## 🚀 Quick Commands Reference

**Build iOS release**:
```bash
flutter build ios --release
```

**Open in Xcode**:
```bash
open ios/Runner.xcworkspace
```

**Check for issues**:
```bash
flutter doctor -v
```

**Run tests**:
```bash
flutter test
```

---

## 📊 What Happens Next

### After Upload:
1. ⏳ **Processing** (10-30 min): Apple processes your build
2. ✅ **Ready for Testing**: Build appears in TestFlight
3. 📝 **Add Test Info**: Describe what to test
4. 👥 **Invite Users**: Add testers by email
5. 📧 **Users Get Email**: They install TestFlight and your app

### Timeline:
- **Day 1 (Today)**: Build and upload
- **Day 1 (Tonight)**: Processing complete, configure TestFlight
- **Day 2**: Invite pilot users
- **Day 2-3**: Users install and start testing
- **Week 1**: Support, feedback, iterate

---

## 📞 Need Help?

**Full guide**: See `IOS_TESTFLIGHT_SETUP.md`

**Quick questions**:
- Bundle ID format: All lowercase, dots separate components
- Signing: Choose your personal team (Apple Developer account)
- Archive fails: Clean build folder (Product → Clean Build Folder)

---

## 🎊 Ready to Build!

Everything is prepared. Now:

1. Run the build commands above
2. Open Xcode
3. Configure signing
4. Archive and upload

**You're about 30 minutes away from your first TestFlight build!** 🚀

---

## Next Document

After uploading, see:
- `IOS_TESTFLIGHT_SETUP.md` - Step 5: Configure TestFlight
- `PILOT_INVITATION_EMAIL.md` - Email template for users
- `QUICK_START.md` - Send to pilot users

**Good luck! 🎉**





