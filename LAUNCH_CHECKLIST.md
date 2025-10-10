# 🚀 Metanoia Launch Checklist

Complete guide to launching your NHS appraisal assistant pilot.

---

## ✅ Phase 1: Pre-Launch (TODAY - 1 Hour)

### Technical Setup
- [ ] **Deploy Firestore security rules** (5 min)
  - Go to: https://console.firebase.google.com/project/metanoia-a3035/firestore/rules
  - Copy from `firestore.rules`
  - Click "Publish"

- [ ] **Test complete user journey** (30 min)
  ```bash
  ~/code/flutter/bin/flutter run -d 375EEFCC-E77C-4201-9F52-EF2CFECAF690
  ```
  - [ ] Sign up new account
  - [ ] Complete onboarding
  - [ ] Configure year
  - [ ] Create reflection with GMC domains
  - [ ] Test PHI warning (try "Mr John Smith")
  - [ ] Add CPD entry
  - [ ] Filter CPD by domain
  - [ ] Export markdown
  - [ ] Edit profile
  - [ ] Check settings/privacy
  - [ ] Test delete functions
  - [ ] Verify empty states

- [ ] **Verify all tests pass** (5 min)
  ```bash
  ~/code/flutter/bin/flutter test
  ```
  Expected: 59 tests passing

- [ ] **Build release versions** (15 min)
  ```bash
  # iOS
  ~/code/flutter/bin/flutter build ipa --release
  
  # Android
  ~/code/flutter/bin/flutter build apk --release
  
  # Web
  ~/code/flutter/bin/flutter build web --release
  ```

### Documentation Ready
- [x] User guide created (`USER_GUIDE.md`)
- [x] Quick start created (`QUICK_START.md`)
- [x] Email template created (`PILOT_INVITATION_EMAIL.md`)
- [x] Feedback form created (`PILOT_FEEDBACK_FORM.md`)

---

## ✅ Phase 2: Prepare Materials (DAY 1 - 3 Hours)

### Create Demo Video (1.5 hours)
- [ ] **Script prepared** (use outline below)
- [ ] **Screen recording** (iPhone/simulator)
- [ ] **Voiceover recorded** (or subtitles added)
- [ ] **Video edited** (3-5 minutes max)
- [ ] **Uploaded** (YouTube/Vimeo/Google Drive)
- [ ] **Link tested** (accessible without login)

**Demo Video Outline**:
1. **Intro** (30s): Problem statement
2. **Sign up** (20s): Show account creation
3. **Create reflection** (60s): What/So What/Now What + domains
4. **PHI warning** (20s): Demonstrate safety feature
5. **CPD tracking** (30s): Add entry, show filters/totals
6. **Export** (30s): Generate MAG-format file
7. **Outro** (30s): Call to action

### Prepare Distribution (1 hour)
- [ ] **iOS TestFlight**:
  - [ ] Upload build to App Store Connect
  - [ ] Create TestFlight group "Pilot Users"
  - [ ] Generate invitation link
  
- [ ] **Android**:
  - [ ] Upload APK to Google Drive/Dropbox
  - [ ] Make shareable link (or Firebase App Distribution)
  
- [ ] **Web**:
  - [ ] Deploy to Firebase Hosting
  - [ ] Test URL works on mobile

### Create Support Resources (30 min)
- [ ] **Set up support email**: metanoia-support@yourdomain.com
- [ ] **Create FAQ doc** (based on USER_GUIDE.md common questions)
- [ ] **Prepare response templates** for common issues:
  - Password reset
  - Data sync issues
  - Export problems
  - Feature requests

---

## ✅ Phase 3: Recruit Pilot Users (DAY 2-3 - 2 Hours)

### Identify Candidates (30 min)
Target: 5-10 enthusiastic early adopters

**Ideal pilot users**:
- [ ] NHS doctors (consultants, GPs, trainees)
- [ ] Comfortable with technology
- [ ] Willing to provide detailed feedback
- [ ] Appraisal coming up in 3-6 months (ideal timing)
- [ ] From different specialties (for diverse feedback)

**Your list**:
1. _____________________________ (Specialty: _____)
2. _____________________________ (Specialty: _____)
3. _____________________________ (Specialty: _____)
4. _____________________________ (Specialty: _____)
5. _____________________________ (Specialty: _____)
6. _____________________________ (Specialty: _____)
7. _____________________________ (Specialty: _____)
8. _____________________________ (Specialty: _____)
9. _____________________________ (Specialty: _____)
10. ____________________________ (Specialty: _____)

### Send Invitations (1 hour)
- [ ] Customize email template for each recipient
- [ ] Send invitations
- [ ] Track responses in spreadsheet:
  - Name
  - Email
  - Specialty
  - Invited date
  - Response (Yes/No/Pending)
  - Onboarded date
  - Platform (iOS/Android/Web)

### Follow Up (30 min)
- [ ] Gentle reminder after 2 days
- [ ] Personal call to key contacts
- [ ] Ask for referrals from interested users

---

## ✅ Phase 4: Onboard Pilot Users (DAY 4-7 - Ongoing)

### For Each User (15 min each)
- [ ] Send personalized welcome email with:
  - [ ] Download link (TestFlight/APK/Web URL)
  - [ ] QUICK_START.md attached
  - [ ] Demo video link
  - [ ] Your direct contact info
  - [ ] Feedback form link

- [ ] Confirm installation:
  - [ ] Reply to their "installed" message
  - [ ] Offer 15-min onboarding call if needed
  - [ ] Set expectation: "Try 1-2 reflections this week"

- [ ] Add to pilot tracking spreadsheet:
  - Name
  - Email
  - Platform
  - Install date
  - First reflection date
  - Feedback submitted (Week 2 / Week 4)
  - Issues reported
  - Overall satisfaction (1-5)

### Week 1 Support
- [ ] Send welcome email immediately after signup
- [ ] Check in after 2 days: "How's it going?"
- [ ] Offer help with first reflection
- [ ] Be responsive to questions (< 4 hour response time)

---

## ✅ Phase 5: Monitor & Support (WEEK 1-4 - Daily)

### Daily Tasks (15 min/day)
- [ ] Check Firebase console for new users
- [ ] Review error logs (if Sentry enabled)
- [ ] Respond to support emails
- [ ] Monitor pilot user progress
- [ ] Note feature requests

### Weekly Tasks (1 hour/week)
- [ ] **Week 1**: Send check-in email to all users
- [ ] **Week 2**: Send feedback form #1 (initial impressions)
- [ ] **Week 3**: Send usage tips and best practices
- [ ] **Week 4**: Send feedback form #2 (detailed feedback)

### Track Metrics
- [ ] Number of active users (daily/weekly)
- [ ] Reflections created per user (avg)
- [ ] CPD entries created per user (avg)
- [ ] Export usage (how many, how often)
- [ ] Support tickets / issues reported
- [ ] Feature requests
- [ ] User satisfaction (from surveys)

**Create simple tracking spreadsheet**:
| Metric | Week 1 | Week 2 | Week 3 | Week 4 |
|--------|--------|--------|--------|--------|
| Active users | | | | |
| Total reflections | | | | |
| Total CPD | | | | |
| Exports | | | | |
| Issues reported | | | | |
| Avg satisfaction | | | | |

---

## ✅ Phase 6: Collect Feedback (WEEK 2 & 4 - 2 Hours)

### Week 2 Survey (30 min to send)
- [ ] Send PILOT_FEEDBACK_FORM.md (Week 2 version)
- [ ] Offer incentive: "First 5 responses get £10 Amazon voucher"
- [ ] Follow up with non-responders after 3 days
- [ ] Target: 80% response rate

### Week 4 Survey (30 min to send)
- [ ] Send PILOT_FEEDBACK_FORM.md (Week 4 version)
- [ ] Include "What's changed" summary
- [ ] Ask about continued use
- [ ] Target: 80% response rate

### Analyze Feedback (1 hour)
- [ ] Compile all responses
- [ ] Identify common themes:
  - What's working well?
  - What's frustrating?
  - What's missing?
  - What would they change?
- [ ] Prioritize fixes/features:
  - **P0**: Blocking issues (fix immediately)
  - **P1**: Major pain points (fix this week)
  - **P2**: Nice to have (fix next sprint)
  - **P3**: Future enhancements

---

## ✅ Phase 7: Iterate (WEEK 3-6 - Ongoing)

### Based on Feedback
- [ ] Fix critical bugs (P0) within 24 hours
- [ ] Implement top-requested features (P1) within 1 week
- [ ] Improve confusing UI/UX
- [ ] Add missing documentation
- [ ] Refine onboarding if users are confused

### Communicate Changes
- [ ] Send "What's New" email after each update
- [ ] Include in-app changelog
- [ ] Thank users for their feedback
- [ ] Show how their input shaped the product

### Version Releases
- [ ] v1.0.1: Bug fixes from week 1-2
- [ ] v1.0.2: Top feature requests from week 2-3
- [ ] v1.1.0: Major improvements from week 3-4
- [ ] v1.2.0: Polish for wider rollout

---

## ✅ Phase 8: Expand Pilot (WEEK 5+ - 1 Hour)

### Success Criteria Met?
- [ ] 5+ active users using regularly (weekly)
- [ ] Average satisfaction ≥ 4/5
- [ ] Major bugs resolved
- [ ] Positive qualitative feedback
- [ ] Users would recommend to colleagues

### If Yes, Expand:
- [ ] Invite 10 more users (referrals from existing users)
- [ ] Prepare for broader launch (App Store/Play Store)
- [ ] Consider institutional partnerships (NHS trusts)
- [ ] Plan marketing/communications strategy

### If No, Iterate More:
- [ ] Address major concerns
- [ ] Conduct user interviews (1-on-1)
- [ ] Pivot features if needed
- [ ] Continue with small group until satisfied

---

## ✅ Phase 9: Plan Production Launch (WEEK 8+ - 2-4 Weeks)

### App Store Preparation
- [ ] **iOS App Store**:
  - [ ] Create app listing (description, screenshots)
  - [ ] Submit for review
  - [ ] Prepare marketing materials
  
- [ ] **Google Play Store**:
  - [ ] Create store listing
  - [ ] Submit for review
  - [ ] Prepare marketing materials
  
- [ ] **Web**:
  - [ ] Set up custom domain (www.metanoia.app)
  - [ ] SEO optimization
  - [ ] Analytics setup

### Business Planning
- [ ] Finalize pricing model:
  - [ ] Free tier (limited features?)
  - [ ] Paid tier (£5-20/month?)
  - [ ] Institutional licensing?
  
- [ ] Set up payment processing (Stripe/Paddle)
- [ ] Create terms of service
- [ ] Review and update privacy policy
- [ ] Consider NHS trust partnerships

### Marketing
- [ ] Create landing page
- [ ] Write blog post / case study
- [ ] Reach out to NHS publications (BMJ, Pulse)
- [ ] Post in NHS forums (Doctors.net.uk)
- [ ] Social media (Twitter/LinkedIn for NHS doctors)

---

## 🎯 Success Metrics

### Pilot Success (Week 4)
- [ ] 8+ active users (out of 10 invited)
- [ ] 40+ reflections created (4+ per user)
- [ ] 30+ CPD entries (3+ per user)
- [ ] 20+ exports generated (2+ per user)
- [ ] 4+ / 5 average satisfaction
- [ ] 80%+ would recommend
- [ ] Zero critical bugs outstanding

### Production Success (Month 3)
- [ ] 50+ active users
- [ ] 300+ reflections created
- [ ] 200+ CPD entries
- [ ] 100+ exports generated
- [ ] 4.5+ / 5 average satisfaction
- [ ] 90%+ would recommend
- [ ] Featured in NHS publication

---

## 📞 Support Contacts

### For Pilot Users
- **Email**: metanoia-support@yourdomain.com
- **Phone**: [Your number]
- **Response time**: < 4 hours (weekdays)

### For Technical Issues
- **Firebase Console**: https://console.firebase.google.com/project/metanoia-a3035
- **Sentry** (if enabled): [Your Sentry URL]
- **GitHub Issues**: https://github.com/yourusername/metanoia_flutter/issues

---

## 🎊 Launch Day!

When you're ready to launch:

1. ✅ Deploy security rules
2. ✅ Test complete journey
3. ✅ Send first invitation emails
4. 🎉 **LAUNCH!**

---

## 📝 Templates Summary

You now have:
- ✅ `USER_GUIDE.md` - Comprehensive 1-page guide
- ✅ `QUICK_START.md` - 5-minute quick reference
- ✅ `PILOT_INVITATION_EMAIL.md` - Recruitment email
- ✅ `PILOT_FEEDBACK_FORM.md` - Survey template
- ✅ `LAUNCH_CHECKLIST.md` - This file!

---

**Everything you need to launch is ready. Now go make it happen! 🚀**


