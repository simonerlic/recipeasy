# Recipeasy v1.4.0 Deployment Checklist

**Target Release Date**: Tonight (2026-02-12)
**Version**: 1.4.0 (Build 2)

---

## ✅ Pre-Release Checklist

### Code & Build
- [ ] All code changes committed to git
- [ ] No compiler warnings
- [ ] No runtime warnings in console
- [ ] Build succeeds in Release configuration
- [ ] Archive succeeds without errors
- [ ] All unit tests pass (if any)

### Version Numbers
- [x] MARKETING_VERSION updated to 1.4.0
- [x] CURRENT_PROJECT_VERSION updated to 2
- [x] SettingsView shows "Version 1.4.0"
- [x] What's New added for version 1.4.0

### Testing on Device
- [ ] Test on iOS 18.0 device (minimum supported)
- [ ] Test on iOS 18.x device (current release)
- [ ] Test in Light Mode
- [ ] Test in Dark Mode
- [ ] Test on iPhone (various sizes if possible)
- [ ] Test on iPad (if supported)

### Feature Testing
- [ ] **Fresh Install**:
  - [ ] App launches successfully
  - [ ] Create a recipe manually
  - [ ] Generate recipe with AI (OpenAI)
  - [ ] Import recipe from PDF
  - [ ] Import recipe from website
  - [ ] All features work correctly

- [ ] **Update from v1.3.0**:
  - [ ] Install v1.3.0 from TestFlight/App Store
  - [ ] Create test recipes, categories, attempts
  - [ ] Update to v1.4.0 build
  - [ ] App launches without crash
  - [ ] What's New sheet appears
  - [ ] All existing data is preserved
  - [ ] All features still work

- [ ] **AI Provider Selection**:
  - [ ] Settings shows both OpenAI and Apple Intelligence
  - [ ] Default is OpenAI
  - [ ] Apple Intelligence shows "requires iOS 26.0" message
  - [ ] Can switch between providers
  - [ ] Selection persists after app restart

- [ ] **Data Persistence**:
  - [ ] Create recipe, close app, reopen - recipe still there
  - [ ] Edit recipe, close app, reopen - changes saved
  - [ ] Delete recipe, close app, reopen - recipe deleted
  - [ ] Categories persist correctly

- [ ] **UI Improvements**:
  - [ ] Recipe cards visible in light mode (shadow + border)
  - [ ] Settings page has clean layout
  - [ ] AI disclaimer text looks correct
  - [ ] No visual glitches

### Subscription & IAP
- [ ] Subscription status checks correctly
- [ ] OpenAI API key can be entered
- [ ] Subscription flow works (if testing in sandbox)

### Edge Cases
- [ ] Works with no internet connection (except AI generation)
- [ ] Handles invalid OpenAI API key gracefully
- [ ] Handles network errors gracefully
- [ ] App doesn't crash when backgrounded during generation

---

## 📦 App Store Preparation

### App Store Connect
- [ ] Login to App Store Connect
- [ ] Navigate to Recipeasy app
- [ ] Create new version (1.4.0)

### Screenshots
- [ ] Update screenshots if UI changed significantly
- [ ] Ensure screenshots show new AI Provider selection (optional)
- [ ] Screenshots for all required device sizes

### App Information
- [ ] **What's New in This Version**:
```
AI Provider Selection • Choose between OpenAI and Apple Intelligence
Enhanced Data Protection • No more crashes or data loss during updates
UI Refinements • Better visibility and cleaner interface

We've completely rebuilt our data system to keep your recipes safe! Plus, get ready for Apple Intelligence support coming in iOS 26.
```

- [ ] **Description** (update if needed):
  - Mention AI provider choice
  - Highlight data safety improvements

- [ ] **Keywords** (add if relevant):
  - Current + "AI", "on-device", "privacy", "Apple Intelligence"

- [ ] **Support URL**: Still valid
- [ ] **Privacy Policy URL**: Still valid

### Metadata
- [ ] Version: 1.4.0
- [ ] Build: 2
- [ ] Copyright year: 2025 or 2026
- [ ] Age rating: Still appropriate
- [ ] Category: Food & Drink

### Privacy
- [ ] Privacy nutrition label still accurate
- [ ] Data collection practices haven't changed
- [ ] Third-party SDK disclosures (OpenAI) accurate

---

## 🚀 Xcode Archive & Upload

### Archive
1. [ ] Select "Any iOS Device" as target
2. [ ] Product → Archive
3. [ ] Wait for archive to complete
4. [ ] Archive appears in Organizer

### Validation
5. [ ] Click "Validate App"
6. [ ] Select appropriate team/account
7. [ ] Choose "App Store Connect" distribution
8. [ ] Wait for validation
9. [ ] Resolve any validation errors/warnings
10. [ ] Validation succeeds ✅

### Upload
11. [ ] Click "Distribute App"
12. [ ] Choose "App Store Connect"
13. [ ] Select upload method (Upload / Export)
14. [ ] Choose "Upload"
15. [ ] Wait for upload to complete
16. [ ] Confirmation: "Upload Successful"

---

## 📱 TestFlight (Recommended Before Submission)

### Internal Testing
- [ ] Upload appears in App Store Connect
- [ ] Build processing completes (can take 5-30 minutes)
- [ ] Add build to TestFlight
- [ ] Test with internal testers
- [ ] Verify migration from v1.3.0 works
- [ ] Check for any last-minute issues

### External Testing (Optional)
- [ ] Add to external testing group
- [ ] Get feedback from beta testers
- [ ] Address any critical issues

---

## 🎯 App Store Submission

### Submit for Review
1. [ ] Navigate to version 1.4.0 in App Store Connect
2. [ ] Select the uploaded build (Build 2)
3. [ ] Fill in "What's New in This Version"
4. [ ] Review all metadata
5. [ ] Add build to submission
6. [ ] Review App Store Information
7. [ ] Review Pricing & Availability
8. [ ] **Submit for Review**

### Review Information
- [ ] Contact info is current
- [ ] Demo account (if needed) is valid
- [ ] Review notes mention:
  - "This update focuses on data stability and AI provider flexibility"
  - "Apple Intelligence requires iOS 26.0+ (coming June 2025)"
  - "Default provider is OpenAI for current iOS versions"

---

## 🔍 Post-Submission Monitoring

### During Review (1-2 days typically)
- [ ] Monitor App Store Connect for status updates
- [ ] Respond to any review questions within 24 hours
- [ ] Keep phone/email accessible for App Review contact

### After Approval
- [ ] Verify app appears in App Store with v1.4.0
- [ ] Download from App Store to verify
- [ ] Test update flow from v1.3.0 (if possible)
- [ ] Monitor reviews for issues
- [ ] Monitor crash reports in App Store Connect

### First 24 Hours
- [ ] Check crash rate (should be lower than v1.3.0)
- [ ] Monitor user reviews
- [ ] Check for unexpected issues
- [ ] Respond to user feedback
- [ ] Monitor Analytics for adoption rate

### First Week
- [ ] Daily crash report checks
- [ ] Respond to all reviews
- [ ] Track update adoption percentage
- [ ] Note any recurring issues
- [ ] Prepare hotfix if critical issues found

---

## 🆘 Rollback Plan (If Needed)

### If Critical Issues Found
1. Don't panic - existing users on v1.3.0 are fine
2. Identify the issue and severity
3. Options:
   - **Minor issue**: Address in v1.4.1 patch
   - **Major issue**: Pull app from sale, submit hotfix
   - **Critical crash**: Expedited review for v1.4.1

### Hotfix Process
1. Create branch from v1.4.0 tag
2. Fix critical issue
3. Increment build to 3 (keep version 1.4.0)
4. Test thoroughly
5. Submit with "Expedited Review" request
6. Explain the critical issue in review notes

---

## 📋 Pre-Flight Final Checks

**Right before submission, verify**:

### Critical Items
- [ ] ✅ App builds successfully
- [ ] ✅ No crashes on launch
- [ ] ✅ What's New appears for v1.4.0
- [ ] ✅ Migration from v1.3.0 works
- [ ] ✅ All existing data preserved
- [ ] ✅ OpenAI generation works
- [ ] ✅ Settings show correct version
- [ ] ✅ No private API usage
- [ ] ✅ No hardcoded test data

### Nice to Have
- [ ] Screenshots updated
- [ ] App description mentions new features
- [ ] TestFlight testing completed
- [ ] Team members notified of release

---

## 📝 Post-Release Communication

### Notify Users (Optional)
- [ ] Social media post about update
- [ ] Email to subscribers (if applicable)
- [ ] Update website (if applicable)

### Internal Team
- [ ] Notify team of successful release
- [ ] Share release notes
- [ ] Celebrate the launch! 🎉

---

## 🔐 Security Checklist

- [x] API keys in xcconfig (not hardcoded)
- [x] No sensitive data in git
- [x] No debug logging in production
- [x] User data encrypted in SwiftData
- [x] Network calls use HTTPS
- [x] OpenAI API key stored securely

---

## 📊 Success Metrics

Track these after release:

**Week 1**:
- Crash-free rate > 99.5%
- Update adoption > 50%
- App Store rating maintained or improved
- No 1-star reviews mentioning data loss

**Week 2-4**:
- Continued stable crash rate
- Update adoption > 80%
- Positive reviews mentioning stability
- No major bugs reported

---

## 🎉 Launch Criteria

**Ready to launch when**:
- ✅ All testing complete
- ✅ No critical bugs
- ✅ TestFlight validation passed
- ✅ Archive uploaded successfully
- ✅ What's New and metadata complete
- ✅ Team approves release

---

## 🚫 Do Not Release If

- ❌ App crashes on launch
- ❌ Migration doesn't preserve data
- ❌ Major feature is broken
- ❌ Build warnings about App Store compliance
- ❌ Privacy policy needs update
- ❌ Critical security issue found

---

## 📞 Emergency Contacts

**App Store Review Issues**: App Store Connect support
**Technical Issues**: [Your support email]
**Emergency Hotfix**: [Your phone number]

---

**Good luck with the release! 🚀**

---

## ⏰ Estimated Timeline

- **Archive & Upload**: 15-30 minutes
- **Build Processing**: 5-30 minutes
- **TestFlight Testing**: 1-2 hours (optional but recommended)
- **App Store Submission**: 10 minutes
- **Review Time**: 1-2 days typically
- **Total**: 1-3 days from now to App Store

**For tonight**: You can complete Archive, Upload, and TestFlight testing. Submit for review can happen after TestFlight validation.

---

**Last Updated**: 2026-02-12
**Prepared By**: Claude Code
**Status**: Ready for Deployment ✅
