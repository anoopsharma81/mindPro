# 🚀 App Store Launch Plan for Metanoia

**Complete guide to launching Metanoia on the Apple App Store**

---

## 📋 Overview

This plan covers everything needed to submit Metanoia to the App Store, from prerequisites to post-launch monitoring. Estimated timeline: **2-4 weeks** from start to approval.

---

## ✅ Phase 1: Prerequisites & Setup (Week 1, Days 1-2)

### 1.1 Apple Developer Account
- [ ] **Enroll in Apple Developer Program** ($99/year)
  - Visit: https://developer.apple.com/programs/
  - Approval: Usually 24-48 hours
  - Required: Valid Apple ID, payment method, legal entity info
  - **Status**: Check if already enrolled

### 1.2 App Store Connect Access
- [ ] **Verify access to App Store Connect**
  - Visit: https://appstoreconnect.apple.com
  - Sign in with Apple Developer account
  - Ensure you have "App Manager" or "Admin" role

### 1.3 Bundle Identifier
- [ ] **Finalize Bundle ID**
  - Current: `com.metanoia.flutter.v2` (check in Xcode)
  - Recommended: `com.yourname.metanoia` or `uk.nhs.metanoia`
  - **Important**: Must be unique and match App Store Connect
  - **Action**: Update in Xcode if needed

### 1.4 App Version
- [ ] **Verify version number**
  - Current: `1.0.0+1` (from `pubspec.yaml`)
  - Format: `VERSION+BUILD_NUMBER`
  - For App Store: First submission should be `1.0.0+1`

---

## ✅ Phase 2: App Store Listing Preparation (Week 1, Days 2-4)

### 2.1 App Information

#### Basic Details
- [ ] **App Name**: Metanoia
- [ ] **Subtitle** (optional): "NHS Appraisal Assistant"
- [ ] **Primary Language**: English (UK)
- [ ] **Category**: 
  - Primary: **Medical**
  - Secondary: **Productivity** (optional)
- [ ] **Content Rights**: 
  - [ ] I have the rights to use all content
  - [ ] App contains third-party content (OpenAI, Firebase)
  - [ ] App uses encryption (HTTPS/TLS)

#### App Description
- [ ] **Description** (up to 4,000 characters):
  ```
  Metanoia is an AI-powered NHS appraisal assistant designed to help doctors streamline their annual appraisal process through intelligent reflective practice and CPD tracking.

  KEY FEATURES:

  📝 Structured Reflections
  Create reflections using the "What? So What? Now What?" framework. Automatically map to GMC Good Medical Practice domains (1-4) and get AI-powered improvements.

  🎤 Voice Notes
  Record and transcribe reflections on-the-go. Perfect for busy clinicians who want to capture thoughts quickly.

  📸 Document Extraction
  Snap photos of certificates, notes, or documents and extract structured reflections automatically using AI.

  🎓 CPD Tracking
  Track continuing professional development activities with automatic categorization by type and GMC domains. Monitor hours and generate impact statements.

  🔒 Privacy Protection
  Built-in PHI (Protected Health Information) detection warns you about potential patient identifiers, ensuring NHS Information Governance compliance.

  🧠 AI-Powered Analysis
  Clinical reasoning framework with cognitive bias detection. Self-play improvement helps you refine your reflections iteratively.

  📊 Export & Appraisal Preparation
  Generate appraisal-ready documents organized by year. Export in multiple formats (DOCX, PDF, Markdown).

  SECURITY & PRIVACY:
  • Encrypted data storage (UK/EU region)
  • GDPR compliant
  • NHS Information Governance ready
  • No patient data stored
  • You control your data - export or delete anytime

  PERFECT FOR:
  • NHS doctors preparing for annual appraisal
  • Medical professionals tracking CPD activities
  • Clinicians practicing reflective medicine
  • Healthcare professionals seeking structured learning documentation

  Transform learning into understanding and reflection with Metanoia.
  ```

- [ ] **Keywords** (100 characters max):
  ```
  NHS,appraisal,doctor,reflection,CPD,medical,GMC,portfolio,clinical,reflective practice
  ```

- [ ] **Promotional Text** (170 characters, can be updated without review):
  ```
  New: Enhanced AI analysis and improved export features. Start your appraisal journey today!
  ```

- [ ] **Support URL**: 
  - [ ] Create support page or use email: `support@yourdomain.com`
  - [ ] **Action**: Set up support email or web page

- [ ] **Marketing URL** (optional):
  - [ ] Create landing page: `https://metanoia.app` or similar
  - [ ] **Action**: Set up marketing website

### 2.2 Privacy Policy

- [ ] **Privacy Policy URL** (REQUIRED):
  - Current: Privacy policy exists in-app but needs hosted URL
  - **Options**:
    1. **Firebase Hosting** (Recommended - 15 min):
       - Create `web/privacy-policy.html`
       - Deploy to Firebase Hosting
       - URL: `https://metanoia-a3035.web.app/privacy-policy.html`
    2. **GitHub Pages** (Free - 20 min):
       - Create repository with privacy policy
       - Enable GitHub Pages
       - URL: `https://yourusername.github.io/metanoia-privacy-policy/`
    3. **Simple Web Page** (10 min):
       - Create HTML page with privacy policy content
       - Host on any web server
  
  - **Content**: Use content from `lib/features/settings/privacy_policy_page.dart`
  - **Action**: Create and deploy privacy policy URL

### 2.3 App Icon & Screenshots

#### App Icon
- [ ] **App Icon** (1024x1024px, PNG, no transparency):
  - [ ] Design app icon
  - [ ] Must not include transparency
  - [ ] Must not include rounded corners (Apple adds them)
  - **Action**: Create or update app icon

#### Screenshots (Required for each device size)

**iPhone 6.7" Display (iPhone 14 Pro Max, 15 Pro Max, etc.)**
- [ ] Screenshot 1: Dashboard/Home screen
- [ ] Screenshot 2: Creating a reflection
- [ ] Screenshot 3: CPD tracking view
- [ ] Screenshot 4: Export feature
- [ ] Screenshot 5: AI analysis/improvement (optional)

**iPhone 6.5" Display (iPhone 11 Pro Max, XS Max, etc.)**
- [ ] Same screenshots as above (can reuse if same aspect ratio)

**iPhone 5.5" Display (iPhone 8 Plus, etc.)**
- [ ] Same screenshots (can reuse)

**iPad Pro 12.9" (if supporting iPad)**
- [ ] Screenshots for iPad (if applicable)

**Screenshot Guidelines**:
- Must be actual app screenshots (no mockups)
- Can add text overlays describing features
- Must show real functionality
- No placeholder text
- **Action**: Take screenshots from running app

#### App Preview Video (Optional but Recommended)
- [ ] **Video** (30 seconds max):
  - [ ] Record screen showing key features
  - [ ] Add voiceover or text overlays
  - [ ] Show: Sign up → Create reflection → Add CPD → Export
  - **Action**: Create app preview video

### 2.4 Age Rating

- [ ] **Complete Age Rating Questionnaire**:
  - Medical/Treatment Information: **Yes** (Medical app)
  - Unrestricted Web Access: **No**
  - User Generated Content: **Yes** (Reflections, CPD entries)
  - Location Sharing: **No**
  - Expected Rating: **4+** (Everyone)

---

## ✅ Phase 3: Technical Preparation (Week 1, Days 3-5)

### 3.1 Build Configuration

- [ ] **Update `pubspec.yaml` version** (if needed):
  ```yaml
  version: 1.0.0+1
  ```

- [ ] **Verify iOS configuration**:
  - [ ] Check `ios/Runner/Info.plist`:
    - [ ] App Display Name: "Metanoia"
    - [ ] Bundle Identifier: Matches App Store Connect
    - [ ] Version: 1.0.0
    - [ ] Build: 1
    - [ ] Privacy descriptions present (Camera, Photo Library, Microphone, etc.)

- [ ] **Verify Firebase configuration**:
  - [ ] `ios/Runner/GoogleService-Info.plist` is present and correct
  - [ ] Firebase project is set up correctly

### 3.2 Code Signing

- [ ] **Configure in Xcode**:
  - [ ] Open `ios/Runner.xcworkspace`
  - [ ] Select Runner target
  - [ ] Go to Signing & Capabilities
  - [ ] Select your Apple Developer Team
  - [ ] Verify "Automatically manage signing" is checked
  - [ ] Bundle Identifier matches App Store Connect

### 3.3 Build Release Version

- [ ] **Clean and build**:
  ```bash
  flutter clean
  flutter pub get
  flutter build ios --release
  ```

- [ ] **Archive in Xcode**:
  - [ ] Open `ios/Runner.xcworkspace`
  - [ ] Product → Destination → Any iOS Device
  - [ ] Product → Archive
  - [ ] Wait for archive to complete (2-5 minutes)

### 3.4 Validate Build

- [ ] **Validate before upload**:
  - [ ] In Xcode Organizer, select archive
  - [ ] Click "Validate App"
  - [ ] Fix any issues found
  - [ ] Common issues:
    - Missing privacy descriptions
    - Invalid bundle identifier
    - Code signing errors
    - Missing required icons

---

## ✅ Phase 4: App Store Connect Setup (Week 1, Days 4-5)

### 4.1 Create App Record

- [ ] **Create new app in App Store Connect**:
  1. Go to https://appstoreconnect.apple.com
  2. Click "My Apps" → "+" → "New App"
  3. Fill in:
     - **Platform**: iOS
     - **Name**: Metanoia
     - **Primary Language**: English (UK)
     - **Bundle ID**: Select/create your bundle identifier
     - **SKU**: `metanoia-001` (any unique identifier)
     - **User Access**: Full Access

### 4.2 App Information

- [ ] **Complete App Information tab**:
  - [ ] Category: Medical
  - [ ] Privacy Policy URL: (from Phase 2.2)
  - [ ] Support URL: (from Phase 2.1)
  - [ ] Marketing URL: (optional, from Phase 2.1)
  - [ ] Age Rating: Complete questionnaire

### 4.3 Pricing and Availability

- [ ] **Set pricing**:
  - [ ] Price: **Free** (or set paid price)
  - [ ] Availability: All countries (or select specific)

### 4.4 App Privacy

- [ ] **Complete App Privacy section**:
  - [ ] Data Types Collected:
    - [ ] Name (Account Information)
    - [ ] Email Address (Account Information)
    - [ ] User Content (Reflections, CPD entries)
    - [ ] Device ID (if using analytics)
  - [ ] Data Usage:
    - [ ] App Functionality
    - [ ] Analytics (if enabled)
  - [ ] Data Linked to User: Yes
  - [ ] Tracking: No (unless using advertising)
  - [ ] Data Used to Track: No

---

## ✅ Phase 5: Upload Build (Week 1, Day 5)

### 5.1 Upload to App Store Connect

- [ ] **Distribute archive**:
  1. In Xcode Organizer, select your archive
  2. Click "Distribute App"
  3. Select "App Store Connect"
  4. Click "Next"
  5. Select "Upload"
  6. Keep default options:
     - ✅ Include bitcode for iOS content
     - ✅ Upload your app's symbols
     - ✅ Manage Version and Build Number
  7. Click "Next"
  8. Review signing
  9. Click "Upload"
  10. Wait for upload (2-5 minutes)

### 5.2 Wait for Processing

- [ ] **Processing time**: 10-30 minutes typically
- [ ] **Check status**:
  - Go to App Store Connect → Your App → TestFlight
  - Build will appear when processing is complete
  - You'll receive email notification
- [ ] **If processing fails**: Check email for details and fix issues

---

## ✅ Phase 6: Complete App Store Listing (Week 2, Days 1-2)

### 6.1 Version Information

- [ ] **Add version details**:
  - [ ] Version: 1.0.0
  - [ ] What's New in This Version:
    ```
    Welcome to Metanoia! The AI-powered NHS appraisal assistant.

    Features:
    • Create structured reflections using "What? So What? Now What?" framework
    • Track CPD activities with automatic GMC domain mapping
    • Record voice notes and transcribe on-the-go
    • Extract reflections from photos and documents using AI
    • Built-in PHI detection for NHS Information Governance compliance
    • Export appraisal-ready documents
    • Secure, encrypted cloud storage

    Start your appraisal journey today!
    ```

### 6.2 Screenshots

- [ ] **Upload screenshots**:
  - [ ] Upload for each required device size
  - [ ] Minimum 3 screenshots required
  - [ ] Maximum 10 screenshots
  - [ ] Order: Most important features first

### 6.3 App Preview (Optional)

- [ ] **Upload app preview video** (if created):
  - [ ] 30 seconds max
  - [ ] Shows key features
  - [ ] High quality

### 6.4 Review Information

- [ ] **Complete review information**:
  - [ ] **Contact Information**:
    - First Name: [Your name]
    - Last Name: [Your last name]
    - Phone: [Your phone]
    - Email: [Your email]
  
  - [ ] **Demo Account** (if app requires login):
    - Username: [Test account email]
    - Password: [Test account password]
    - Notes: "This is a test account for App Review. All features are available."
  
  - [ ] **Notes** (optional):
    ```
    Metanoia is an NHS appraisal assistant for doctors. 
    Key features to test:
    1. Sign up with email or Google Sign-In
    2. Create a reflection using the structured form
    3. Add a CPD entry
    4. Test the export feature
    
    The app uses Firebase for backend services and OpenAI for AI features.
    All data is stored securely in Firebase.
    ```

### 6.5 Version Release

- [ ] **Set release options**:
  - [ ] **Automatic Release**: Release immediately after approval
  - [ ] **Manual Release**: Release manually after approval
  - [ ] **Scheduled Release**: Release on specific date
  
  - **Recommendation**: Start with **Manual Release** for first version

---

## ✅ Phase 7: Submit for Review (Week 2, Day 2)

### 7.1 Final Checklist Before Submission

- [ ] All required fields completed
- [ ] Privacy Policy URL is accessible
- [ ] Support URL is accessible
- [ ] Screenshots uploaded for all required sizes
- [ ] App description is complete
- [ ] Keywords are set
- [ ] Age rating is complete
- [ ] App Privacy is complete
- [ ] Build is uploaded and processed
- [ ] Version information is complete
- [ ] Review information is complete
- [ ] Demo account provided (if needed)

### 7.2 Submit

- [ ] **Click "Submit for Review"**:
  1. Go to App Store Connect → Your App
  2. Click "Submit for Review" button (top right)
  3. Review all information
  4. Confirm submission
  5. Status changes to "Waiting for Review"

### 7.3 Review Timeline

- [ ] **Expected review time**: 24-48 hours typically
- [ ] **Status updates**:
  - Waiting for Review
  - In Review
  - Pending Developer Release (if manual release)
  - Ready for Sale (if automatic release)
  - Rejected (if issues found)

---

## ✅ Phase 8: Handle Review (Week 2, Days 3-5)

### 8.1 If Approved

- [ ] **Celebrate!** 🎉
- [ ] **Release app**:
  - If manual release: Click "Release This Version"
  - If automatic: App goes live automatically
- [ ] **Monitor launch**:
  - Check App Store listing
  - Monitor downloads
  - Watch for user reviews
  - Monitor crash reports

### 8.2 If Rejected

- [ ] **Read rejection email carefully**:
  - Apple provides specific reasons
  - Common issues:
    - Missing privacy policy URL
    - Incomplete app information
    - App crashes during review
    - Missing functionality
    - Guideline violations

- [ ] **Fix issues**:
  - Address all rejection reasons
  - Update app if needed
  - Update App Store listing if needed

- [ ] **Resubmit**:
  - Upload new build if app was updated
  - Update App Store Connect information
  - Add notes explaining fixes
  - Resubmit for review

### 8.3 Common Rejection Reasons & Solutions

| Issue | Solution |
|-------|----------|
| **Missing Privacy Policy URL** | Host privacy policy and add URL |
| **App Crashes** | Test on clean device, fix crashes, upload new build |
| **Incomplete Information** | Complete all required fields in App Store Connect |
| **Guideline Violations** | Review App Store Review Guidelines, fix violations |
| **Missing Demo Account** | Provide test account credentials |
| **Broken Functionality** | Test all features, fix bugs |

---

## ✅ Phase 9: Post-Launch (Week 3+)

### 9.1 Monitor & Respond

- [ ] **App Store Connect Analytics**:
  - [ ] Monitor downloads
  - [ ] Track user ratings
  - [ ] Read user reviews
  - [ ] Respond to reviews (especially negative ones)

- [ ] **Crash Reports**:
  - [ ] Monitor Firebase Crashlytics (if enabled)
  - [ ] Fix critical crashes quickly
  - [ ] Update app if needed

- [ ] **User Feedback**:
  - [ ] Monitor support email
  - [ ] Track feature requests
  - [ ] Plan updates based on feedback

### 9.2 Marketing & Promotion

- [ ] **Announce launch**:
  - [ ] Social media posts
  - [ ] Email to pilot users
  - [ ] Blog post or press release
  - [ ] NHS forums/communities

- [ ] **App Store Optimization (ASO)**:
  - [ ] Monitor keyword performance
  - [ ] Update keywords if needed
  - [ ] A/B test screenshots
  - [ ] Update promotional text regularly

### 9.3 Updates

- [ ] **Plan version updates**:
  - [ ] v1.0.1: Bug fixes
  - [ ] v1.0.2: User-requested features
  - [ ] v1.1.0: Major improvements

- [ ] **Update process**:
  - Increment version in `pubspec.yaml`
  - Build and upload new version
  - Update "What's New" text
  - Submit for review

---

## 📊 Timeline Summary

| Phase | Duration | Days |
|-------|----------|------|
| **Phase 1: Prerequisites** | 1-2 days | Days 1-2 |
| **Phase 2: Listing Prep** | 2-3 days | Days 2-4 |
| **Phase 3: Technical Prep** | 2-3 days | Days 3-5 |
| **Phase 4: App Store Connect** | 1-2 days | Days 4-5 |
| **Phase 5: Upload Build** | 1 day | Day 5 |
| **Phase 6: Complete Listing** | 1-2 days | Days 6-7 |
| **Phase 7: Submit** | 1 day | Day 7 |
| **Phase 8: Review** | 1-3 days | Days 8-10 |
| **Phase 9: Post-Launch** | Ongoing | Week 3+ |

**Total Estimated Time**: 2-3 weeks from start to approval

---

## 🎯 Quick Start Checklist

**Today (Day 1)**:
- [ ] Verify Apple Developer account enrollment
- [ ] Access App Store Connect
- [ ] Finalize bundle identifier
- [ ] Start creating privacy policy URL

**This Week (Days 1-5)**:
- [ ] Complete all App Store listing information
- [ ] Take screenshots
- [ ] Create privacy policy URL
- [ ] Build and upload app
- [ ] Complete App Store Connect setup

**Next Week (Days 6-10)**:
- [ ] Submit for review
- [ ] Respond to any review feedback
- [ ] Launch app!

---

## 📝 Required Resources

### Documents Needed:
- [ ] Privacy Policy (hosted URL)
- [ ] Support contact information
- [ ] Marketing website (optional)
- [ ] App screenshots (all sizes)
- [ ] App preview video (optional)

### Technical Requirements:
- [ ] Apple Developer account ($99/year)
- [ ] Xcode installed and updated
- [ ] Flutter environment set up
- [ ] Firebase project configured
- [ ] Test devices for screenshots

### Content Needed:
- [ ] App description (4,000 chars)
- [ ] Keywords (100 chars)
- [ ] "What's New" text (4,000 chars)
- [ ] Review notes (optional)
- [ ] Demo account credentials (if needed)

---

## 🚨 Critical Requirements

**These MUST be completed before submission:**

1. ✅ **Privacy Policy URL** - Must be accessible, public URL
2. ✅ **Support URL** - Must be accessible
3. ✅ **Screenshots** - Minimum 3 for each device size
4. ✅ **App Icon** - 1024x1024px, no transparency
5. ✅ **Age Rating** - Complete questionnaire
6. ✅ **App Privacy** - Complete data collection disclosure
7. ✅ **Valid Build** - Must pass validation
8. ✅ **Demo Account** - If app requires login

---

## 💡 Pro Tips

1. **Start Early**: Begin preparing materials while app is in development
2. **Test Thoroughly**: Test on clean device before submission
3. **Read Guidelines**: Review App Store Review Guidelines
4. **Be Responsive**: Respond to review feedback quickly
5. **Monitor Reviews**: Respond to user reviews, especially negative ones
6. **Plan Updates**: Have v1.0.1 ready for quick bug fixes
7. **ASO Matters**: Invest time in keywords and screenshots
8. **Privacy First**: Be transparent about data collection

---

## 📞 Getting Help

### Apple Resources:
- **App Store Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **App Store Connect Help**: https://help.apple.com/app-store-connect/
- **Developer Support**: https://developer.apple.com/contact/

### Your Documentation:
- TestFlight Setup: `IOS_TESTFLIGHT_SETUP.md`
- Launch Checklist: `LAUNCH_CHECKLIST.md`
- User Guide: `USER_GUIDE.md`

---

## 🎊 Success Criteria

**Launch is successful when:**
- ✅ App is approved and live on App Store
- ✅ Users can download and install
- ✅ No critical crashes in first week
- ✅ Positive initial reviews (4+ stars)
- ✅ Support system is ready
- ✅ Analytics are tracking

---

**You're ready to launch! Follow this plan step-by-step and your app will be on the App Store in 2-3 weeks! 🚀**

