# iOS TestFlight Setup Guide for Pilot Users

## 🎯 Getting Your iPhone App to Pilot Users

This guide walks you through distributing your Metanoia app to iPhone pilot users using Apple TestFlight.

---

## ⏱️ Quick Overview

- **Time needed**: 1-2 hours (first time)
- **Cost**: $99/year for Apple Developer Program (if not already enrolled)
- **Pilot user limit**: Up to 10,000 testers (more than enough!)
- **Test period**: 90 days per build

---

## 📋 Prerequisites

### 1. Apple Developer Account
- [ ] **Enroll** at: https://developer.apple.com/programs/
  - Cost: $99/year
  - Approval: Usually 24-48 hours
  - Required: Valid Apple ID, payment method

### 2. Your Mac Setup
- [ ] Xcode installed (you already have this)
- [ ] Xcode command line tools(already have it)
- [ ] Your Apple ID signed in to Xcode

---

## 🚀 Step-by-Step Setup

### Step 1: Prepare Your App for TestFlight (30 minutes)

#### 1.1 Update App Information
Open `ios/Runner/Info.plist` and verify:
```xml
<key>CFBundleDisplayName</key>
<string>Metanoia</string>
<key>CFBundleIdentifier</key>
<string>com.yourcompany.metanoia</string>
```

#### 1.2 Set App Version
Update `pubspec.yaml`:
```yaml
version: 1.0.0+1
```
The format is `VERSION+BUILD_NUMBER`

#### 1.3 Add Privacy Descriptions
Verify these are in `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Metanoia needs camera access to add photos to your reflections</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Metanoia needs photo library access to add photos to your reflections</string>
```

---

### Step 2: Create App in App Store Connect (15 minutes)

#### 2.1 Go to App Store Connect
- Visit: https://appstoreconnect.apple.com
- Sign in with your Apple Developer account

#### 2.2 Create New App
1. Click **"My Apps"**
2. Click **"+"** → **"New App"**
3. Fill in details:
   - **Platform**: iOS
   - **Name**: Metanoia
   - **Primary Language**: English (UK or US)
   - **Bundle ID**: Select/create `com.yourcompany.metanoia`
   - **SKU**: `metanoia-001` (any unique identifier)
   - **User Access**: Full Access

#### 2.3 Add App Information
Go to **App Information** tab:
- **Category**: Medical
- **Content Rights**: Check appropriate boxes for NHS/medical data
- **Privacy Policy URL**: (prepare this or use placeholder)

---

### Step 3: Build and Archive Your App (20 minutes)

#### 3.1 Clean Build
```bash
cd /Users/anup/code/Medflutter/metanoia_flutter
flutter clean
flutter pub get
```

#### 3.2 Build iOS Release
```bash
flutter build ios --release
```

#### 3.3 Open in Xcode
```bash
open ios/Runner.xcworkspace
```

#### 3.4 Configure Signing in Xcode
1. In Xcode, select **Runner** in the project navigator
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Check **"Automatically manage signing"**
5. Select your **Team** (your Apple Developer account)
6. Verify **Bundle Identifier** matches App Store Connect

#### 3.5 Archive the App
1. In Xcode menu: **Product** → **Destination** → **Any iOS Device**
2. In Xcode menu: **Product** → **Archive**
3. Wait 2-5 minutes for the archive to complete
4. The **Organizer** window will open automatically

---

### Step 4: Upload to TestFlight (10 minutes)

#### 4.1 Distribute the Archive
In the Xcode Organizer window:
1. Select your archive
2. Click **"Distribute App"**
3. Select **"App Store Connect"**
4. Click **"Next"**
5. Select **"Upload"**
6. Keep default options:
   - ✅ Include bitcode for iOS content
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number (Xcode will auto-increment)
7. Click **"Next"**
8. Review automatic signing
9. Click **"Upload"**

#### 4.2 Wait for Processing
- Upload: 2-5 minutes
- Processing in App Store Connect: 10-30 minutes
- You'll receive email when ready

---

### Step 5: Configure TestFlight (15 minutes)

#### 5.1 Go to TestFlight Tab
In App Store Connect:
1. Select your **Metanoia** app
2. Click **"TestFlight"** tab
3. Wait for build to appear (check email)

#### 5.2 Add Test Information
When build is processed:
1. Click on your build number (e.g., "1.0.0 (1)")
2. Add **"Test Details"**:
   - **What to Test**: Brief description of what pilot users should focus on
   - **Description**: 
   ```
   Metanoia helps NHS doctors prepare for appraisals through guided reflections and CPD tracking. Test all features including:
   - Creating reflections
   - Adding CPD entries
   - Exporting your portfolio
   ```

#### 5.3 Add Beta App Information (Required for external testing)
1. Go to **"App Information"** in TestFlight
2. Fill in:
   - **Beta App Description**: 
   ```
   Metanoia helps NHS doctors prepare for appraisals through:
   - Guided reflections
   - CPD tracking
   - Portfolio export
   - Offline support
   ```
   - **Feedback Email**: your.email@example.com
   - **Privacy Policy URL**: (prepare this)

#### 5.4 Submit for Beta Review (External Testing Only)
If you want to test with external users (not just added to your team):
1. Click **"Submit for Review"**
2. Answer compliance questions:
   - **Encryption**: Yes (standard HTTPS)
   - **ITAR**: No
   - **Content Rights**: Appropriate selections
3. Wait 24-48 hours for Apple review

**Note**: For Internal Testing (Team members), no review needed!

---

### Step 6: Invite Pilot Users (10 minutes)

#### Option A: Internal Testing (No Apple Review, Faster)
**Best for**: Quick start with up to 100 testers who are in your Apple Developer team

1. In TestFlight tab, click **"Internal Testing"**
2. Create a new group (e.g., "Pilot Group 1")
3. Add testers by email:
   - They must be added to your team in **"Users and Access"** first
   - Role: **App Manager** or **Developer**
4. Click **"Add"** and select your build

#### Option B: External Testing (Requires Apple Review)
**Best for**: Testing with any users (not on your team)

1. In TestFlight tab, click **"External Testing"**
2. Create a new group (e.g., "NHS Pilot Users")
3. Click **"+"** to add testers
4. Enter email addresses of your pilot users
5. Enable the build for this group
6. Testers will receive invitation email

---

### Step 7: User Instructions (Send to Pilots)

**Email Template to Send Pilot Users:**

```
Subject: You're Invited to Test Metanoia (NHS Appraisal App)

Hi [Name],

Thanks for agreeing to test Metanoia! Here's how to get started:

📱 STEP 1: Install TestFlight
1. Download "TestFlight" from the App Store (free)
2. It's Apple's official app for testing beta apps

📲 STEP 2: Accept Invitation
1. Check your email for the TestFlight invitation
2. Tap "View in TestFlight" or "Start Testing"
3. This will open the TestFlight app

⬇️ STEP 3: Install Metanoia
1. In TestFlight, tap "Install"
2. Wait for the app to download
3. Tap "Open" to launch Metanoia

🎯 STEP 4: Set Up & Start Using
1. Sign up with your email
2. Follow the onboarding guide
3. Start creating your first reflection!

📖 Quick Start Guide: [Attach QUICK_START.md]

💬 FEEDBACK
Please send me feedback anytime:
- Email: your.email@example.com
- In-app: Use "Send Beta Feedback" in TestFlight

IMPORTANT: This is a beta test, so please report any issues you encounter!

Thanks for helping make Metanoia better for NHS doctors!

Best,
[Your Name]
```

---

## 🔄 Updating Your App (For Future Builds)

When you fix bugs or add features:

### Quick Update Process (30 minutes)
```bash
# 1. Update version in pubspec.yaml
# version: 1.0.0+2  (increment build number)

# 2. Clean and build
cd /Users/anup/code/Medflutter/metanoia_flutter
flutter clean
flutter build ios --release

# 3. Open in Xcode
open ios/Runner.xcworkspace

# 4. Archive and upload (same as Step 4 above)
# Product → Archive → Distribute

# 5. Process and add to TestFlight
# (Same as Step 5)
```

**Pro Tip**: You can have multiple builds active in TestFlight. Users can be on different versions.

---

## 📊 Monitoring Your Pilot

### TestFlight Analytics
In App Store Connect → TestFlight:
- **Sessions**: How many times users opened the app
- **Crashes**: Critical issues you need to fix
- **Installs**: How many users installed
- **Tester count**: Active vs. invited

### User Feedback
Users can send feedback directly through TestFlight:
1. Screenshot
2. Tap the image to add comments
3. "Send Beta Feedback"
4. You receive email notification

---

## ⚠️ Common Issues & Solutions

### Issue: "No matching provisioning profiles found"
**Solution**:
1. In Xcode: Runner → Signing & Capabilities
2. Uncheck "Automatically manage signing"
3. Re-check "Automatically manage signing"
4. Select your team again

### Issue: "Your account already exists"
**Solution**: 
- You're using an Apple ID that's already in TestFlight
- Use a different email or remove from previous tests

### Issue: Build processing takes forever
**Solution**: 
- Usually 15-30 minutes
- Check status in App Store Connect
- If > 1 hour, contact Apple Support

### Issue: Crashlytics/Sentry not working in TestFlight
**Solution**: 
- Upload debug symbols (dSYM)
- In Xcode Organizer: Right-click archive → Show in Finder
- Upload the dSYMs to your crash reporting service

### Issue: App rejected from Beta Review
**Solution**:
- Read rejection email carefully
- Common reasons: Missing privacy policy, incomplete test info
- Fix and resubmit
- Or use Internal Testing (no review needed)

---

## 💡 Pro Tips

### Start with Internal Testing
- No Apple review needed
- Faster turnaround
- Add colleagues/friends to your team
- Test 5-10 users first
- Then move to External Testing

### Version Management
```
Major.Minor.Patch+BuildNumber
1.0.0+1   → Initial release
1.0.0+2   → Bug fix (same version, new build)
1.0.1+3   → Small update (new version)
1.1.0+4   → New features
```

### Communication
- Send weekly updates to pilot users
- Tell them what's fixed/improved
- Encourage feedback
- Be responsive (< 24 hours)

### Crash Management
- Set up Crashlytics or Sentry
- Monitor daily in first week
- Fix crashes immediately
- Users are forgiving if you're responsive

---

## 📅 Typical Timeline

### Day 1: Setup
- Morning: Apple Developer enrollment (if needed)
- Afternoon: Create app in App Store Connect
- Evening: Build and upload first version

### Day 2-3: Review (External Testing)
- Wait for Apple Beta Review
- Use this time to prepare materials
- Test internally meanwhile

### Day 3-4: Launch
- Add pilot users
- Send invitation emails
- Users install via TestFlight

### Week 1: Support
- Monitor daily
- Respond to feedback
- Fix critical bugs

### Week 2+: Iterate
- Weekly updates
- New features based on feedback
- Maintain communication

---

## 🎯 Quick Start Checklist

**Today**:
- [ ] Enroll in Apple Developer Program (if not already)
- [ ] Create app in App Store Connect
- [ ] Build and archive in Xcode
- [ ] Upload to TestFlight

**Tomorrow**:
- [ ] Configure TestFlight
- [ ] Add test information
- [ ] Submit for review (external) or skip (internal)

**Day 3**:
- [ ] Invite 3-5 pilot users
- [ ] Send installation instructions
- [ ] Provide Quick Start guide

**Week 1**:
- [ ] Monitor usage and feedback
- [ ] Fix critical issues
- [ ] Upload update if needed

---

## 📞 Getting Help

### Apple Resources
- **TestFlight Guide**: https://developer.apple.com/testflight/
- **App Store Connect**: https://help.apple.com/app-store-connect/
- **Developer Support**: https://developer.apple.com/contact/

### Your Documentation
- User guide: `USER_GUIDE.md`
- Quick start: `QUICK_START.md`
- Launch plan: `LAUNCH_CHECKLIST.md`

---

## 🎊 You're Ready!

**TestFlight makes beta testing easy:**
✅ Up to 10,000 testers
✅ Easy installation for users
✅ Built-in feedback tools
✅ Crash reporting
✅ Version management
✅ Professional distribution

**Follow this guide and you'll have pilot users testing within 1-2 days!**

---

## 🚀 Next Steps

1. **Right now**: Start Apple Developer enrollment
2. **In 1 hour**: Build and upload your first version
3. **Tomorrow**: Invite your first pilot users
4. **This week**: Get 5 users testing

**The sooner you start, the sooner you get valuable feedback!**

---

## 📝 Alternative: Quick Internal Test (Skip Apple Review)

**Fastest Path (No External Review)**:

1. Add 5 colleagues to your Apple Developer team:
   - App Store Connect → Users and Access → "+"
   - Role: App Manager (can test)
   
2. Use Internal Testing group
   - Add them to internal test group
   - They get instant access (no review!)

3. Test for 1 week with this small group

4. Then expand to External Testing with more users

**This lets you start testing TODAY with your close colleagues!**

---

**Good luck with your pilot launch! 🎉**

