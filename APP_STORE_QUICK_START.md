# 🚀 App Store Launch - Quick Start Guide

**Get your app on the App Store in 2-3 weeks**

---

## ⚡ Immediate Next Steps (Today)

### 1. Verify Prerequisites (15 minutes)
- [ ] **Apple Developer Account**: Check if enrolled ($99/year)
  - Visit: https://developer.apple.com/programs/
  - If not enrolled, start enrollment (24-48 hour approval)
- [ ] **App Store Connect Access**: 
  - Visit: https://appstoreconnect.apple.com
  - Sign in and verify access
- [ ] **Bundle ID**: Current is `com.metanoia.flutter.v2`
  - Decide if you want to keep this or change it
  - Must match what you create in App Store Connect

### 2. Create Privacy Policy URL (30 minutes) ⚠️ REQUIRED

**Option A: Firebase Hosting (Recommended)**
```bash
# 1. Create privacy policy HTML file
# Create web/privacy-policy.html with content from lib/features/settings/privacy_policy_page.dart

# 2. Deploy to Firebase
firebase deploy --only hosting
```

**Option B: Quick GitHub Pages (20 minutes)**
1. Create new GitHub repository: `metanoia-privacy-policy`
2. Create `index.html` with privacy policy content
3. Enable GitHub Pages in repository settings
4. URL: `https://yourusername.github.io/metanoia-privacy-policy/`

**Option C: Simple Web Page (10 minutes)**
- Create HTML page with privacy policy
- Host on any web server you have access to

**⚠️ This is REQUIRED - App Store will reject without it!**

### 3. Set Up Support Contact (10 minutes)
- [ ] **Support Email**: Set up `support@yourdomain.com` or use existing email
- [ ] **Support URL** (optional but recommended):
  - Create simple support page or use email link: `mailto:support@yourdomain.com`

---

## 📸 This Week: Prepare Visual Assets

### Screenshots Needed (2-3 hours)

**Required for iPhone 6.7" Display** (iPhone 14 Pro Max, 15 Pro Max):
- [ ] Screenshot 1: Dashboard/Home screen
- [ ] Screenshot 2: Creating a reflection (showing form)
- [ ] Screenshot 3: CPD tracking list
- [ ] Screenshot 4: Export feature
- [ ] Screenshot 5: AI analysis/improvement (optional)

**How to Take Screenshots:**
1. Run app on iPhone or simulator
2. Navigate to each screen
3. Take screenshot: iPhone (Side button + Volume up) or Simulator (Cmd + S)
4. Screenshots are saved to Photos (iPhone) or Desktop (Simulator)
5. Edit if needed (add text overlays describing features)

**Screenshot Guidelines:**
- Must be actual app screenshots (no mockups)
- Can add text overlays describing features
- Must show real functionality
- Minimum 3 screenshots required
- Maximum 10 screenshots

### App Icon (1-2 hours)
- [ ] **Design 1024x1024px icon**
  - PNG format
  - No transparency
  - No rounded corners (Apple adds them)
  - Must represent your app clearly

---

## 🏗️ Next Week: Build & Submit

### Day 1-2: Complete App Store Connect Setup
1. Create app in App Store Connect
2. Fill in all app information (see full plan)
3. Upload screenshots
4. Complete age rating questionnaire
5. Set up app privacy disclosure

### Day 3-4: Build & Upload
1. Build release version:
   ```bash
   flutter clean
   flutter pub get
   flutter build ios --release
   ```
2. Archive in Xcode:
   - Open `ios/Runner.xcworkspace`
   - Product → Archive
3. Upload to App Store Connect
4. Wait for processing (10-30 minutes)

### Day 5: Submit for Review
1. Complete version information
2. Add "What's New" text
3. Provide review notes
4. Click "Submit for Review"

### Day 6-10: Wait for Review
- Apple typically reviews in 24-48 hours
- Respond to any feedback quickly
- If approved, release app!

---

## 📋 Critical Checklist Before Submission

**These MUST be completed:**

- [ ] ✅ Privacy Policy URL (hosted, accessible)
- [ ] ✅ Support URL or email
- [ ] ✅ Screenshots (minimum 3 for each device size)
- [ ] ✅ App Icon (1024x1024px)
- [ ] ✅ App description (complete)
- [ ] ✅ Age rating (completed questionnaire)
- [ ] ✅ App Privacy (data collection disclosure)
- [ ] ✅ Valid build (uploaded and processed)
- [ ] ✅ Demo account (if app requires login)

---

## 🎯 Current Status

**What You Have:**
- ✅ App running on iOS
- ✅ Version: 1.0.0+1
- ✅ Bundle ID: `com.metanoia.flutter.v2`
- ✅ Privacy policy content (in-app)
- ✅ Firebase configured
- ✅ All features working

**What You Need:**
- ⚠️ Privacy Policy URL (hosted)
- ⚠️ Support contact
- ⚠️ Screenshots
- ⚠️ App icon (if not already designed)
- ⚠️ App Store Connect account setup
- ⚠️ App description and keywords

---

## 📚 Full Documentation

For complete details, see:
- **`APP_STORE_LAUNCH_PLAN.md`** - Complete step-by-step guide
- **`IOS_TESTFLIGHT_SETUP.md`** - TestFlight beta testing (optional first step)
- **`LAUNCH_CHECKLIST.md`** - General launch checklist

---

## ⏱️ Timeline

| Task | Time | Priority |
|------|------|----------|
| Privacy Policy URL | 30 min | 🔴 Critical |
| Support Contact | 10 min | 🔴 Critical |
| Screenshots | 2-3 hours | 🟡 High |
| App Icon | 1-2 hours | 🟡 High |
| App Store Connect Setup | 2-3 hours | 🟡 High |
| Build & Upload | 1-2 hours | 🟡 High |
| Submit for Review | 30 min | 🟡 High |
| **Total** | **1-2 days active work** | |

**Review Time**: 24-48 hours (Apple's side)

---

## 🚨 Common Pitfalls to Avoid

1. **Missing Privacy Policy URL** → Immediate rejection
2. **Incomplete App Information** → Delayed review
3. **App Crashes During Review** → Rejection
4. **Missing Screenshots** → Cannot submit
5. **Wrong Bundle ID** → Must match App Store Connect
6. **No Demo Account** → If app requires login, provide test credentials

---

## 💡 Pro Tips

1. **Start with Privacy Policy** - It's required and easy to create
2. **Take Screenshots Early** - You can update them later
3. **Test on Clean Device** - Before submitting, test on fresh install
4. **Read Review Guidelines** - Avoid common rejection reasons
5. **Be Patient** - Review can take 24-48 hours

---

## 🎊 You're Ready!

**Start with these 3 things TODAY:**
1. ✅ Verify Apple Developer account
2. ✅ Create Privacy Policy URL (30 min)
3. ✅ Set up support contact (10 min)

**Then this week:**
4. ✅ Take screenshots (2-3 hours)
5. ✅ Design/update app icon (1-2 hours)

**Next week:**
6. ✅ Complete App Store Connect setup
7. ✅ Build and upload
8. ✅ Submit for review

**In 2-3 weeks:**
9. 🎉 Your app is live on the App Store!

---

**Need help?** See the full plan in `APP_STORE_LAUNCH_PLAN.md`




