# Recipeasy v1.4.0 Release Notes

**Release Date**: TBD
**Build Number**: 2
**iOS Requirement**: 18.0+

---

## 🎉 What's New

### AI Provider Selection
Choose between OpenAI and Apple Intelligence for recipe generation:
- **OpenAI**: Reliable cloud-based generation using gpt-4o-mini (currently active)
- **Apple Intelligence**: On-device, privacy-focused AI coming in iOS 26.0+ (future-ready)
- Seamless switching in Settings
- Same great recipe quality from both providers

### Enhanced Data Protection
Your recipes are now safer than ever:
- Implemented versioned schema to prevent data loss during app updates
- No more crashes when updating the app
- Automatic migration preserves all your existing recipes
- Future-proof architecture for smooth updates

### UI Refinements
Polished interface throughout the app:
- Better card visibility in light mode with subtle shadows and borders
- Cleaner settings page with improved layout
- Fixed background inconsistencies
- Improved visual hierarchy and consistency

---

## 🔧 Technical Improvements

### Data Persistence
- Migrated to versioned SwiftData schema (RecipeSchemaV2)
- Automatic migration from unversioned to versioned schema
- Robust error recovery during migration
- Prevents "duplicate checksums" errors
- Future-proof for V3, V4 schema changes

### AI Architecture
- New modular `AIProvider` protocol
- Separated OpenAI logic into `OpenAIProvider`
- Added `AppleIntelligenceProvider` with Foundation Models support
- Conditional compilation for iOS 26+ features
- All generation types support both providers (recipes, PDFs, websites)

### Code Quality
- Fixed all build errors related to schema migration
- Added proper availability checks for iOS 26 features
- Improved error handling across all AI providers
- Better separation of concerns

---

## 🐛 Bug Fixes

- Fixed crashes during app updates due to schema changes
- Fixed data loss when updating from previous versions
- Resolved "duplicate version checksums" error
- Fixed settings page background inconsistency
- Fixed recipe card visibility in light mode
- Fixed AI disclaimer text background mismatch

---

## 📱 App Store Release Notes

**Recommended Short Description** (4000 character limit):

What's New in Version 1.4.0:

AI PROVIDER SELECTION
Choose your preferred AI service! Switch between OpenAI and the upcoming Apple Intelligence (iOS 26+) for recipe generation. Apple Intelligence offers on-device, privacy-focused AI with no internet connection required.

ENHANCED DATA PROTECTION
We've completely overhauled our data storage system to ensure your recipes are safe during app updates. No more crashes or lost recipes when updating!

UI IMPROVEMENTS
• Better recipe card visibility in light mode
• Cleaner settings interface
• Improved visual consistency throughout the app

UNDER THE HOOD
• Modernized data architecture for improved reliability
• Faster app performance
• Better error handling
• Future-ready for upcoming iOS features

Thank you for using Recipeasy! We're committed to making it the best recipe app for your needs.

---

## 🔐 Privacy & Security

- API keys stored securely in device keychain
- Apple Intelligence processes all data on-device (iOS 26+)
- No data sent to third parties except when using OpenAI provider
- Users have full control over which AI service to use

---

## 🎯 Target Audience

- Current Recipeasy users (update)
- Users concerned about data privacy
- Users looking for AI-powered recipe generation
- iOS 18.0+ devices

---

## ⚙️ System Requirements

**Minimum**: iOS 18.0
**Recommended**: iOS 18.0+
**Apple Intelligence**: iOS 26.0+ (coming June 2025)

**Compatible Devices**:
- iPhone XS and later
- iPad Pro (all models)
- iPad Air (3rd generation and later)
- iPad (6th generation and later)
- iPad mini (5th generation and later)

---

## 📦 What's Included

### New Files
- `RecipeSchemaV1.swift` - Legacy schema reference
- `RecipeSchemaV2.swift` - Current versioned schema
- `RecipeMigrationPlan.swift` - Migration framework (for future V3+)
- `AIProvider.swift` - AI provider protocol
- `OpenAIProvider.swift` - OpenAI implementation
- `AppleIntelligenceProvider.swift` - Apple Intelligence implementation

### Modified Files
- `recipeasyApp.swift` - Versioned schema, What's New v1.4.0
- `Recipe.swift` - Type aliases for V2 schema
- `Category.swift` - Type alias for V2 schema
- `SettingsView.swift` - AI provider selection, version 1.4.0
- `GenerateRecipeView.swift` - Provider switching
- `PDFImportView.swift` - Provider switching
- `ImportRecipeView.swift` - Provider switching
- `RecipeCardView.swift` - Light mode improvements
- `PDFRecipeService.swift` - Uses AIProvider
- `ParseWebRecipeService.swift` - Uses AIProvider
- `project.pbxproj` - Version 1.4.0, Build 2

---

## 🧪 Testing Performed

### Data Migration
- ✅ Fresh install works correctly
- ✅ Update from v1.3.0 preserves all data
- ✅ No crashes on first launch after update
- ✅ All recipes, categories, and history preserved

### AI Generation
- ✅ OpenAI provider generates recipes correctly
- ✅ PDF import works with OpenAI
- ✅ Website import works with OpenAI
- ✅ Apple Intelligence shows as unavailable (iOS 26 not available yet)
- ✅ Switching providers in settings works

### UI/UX
- ✅ Cards visible in light mode
- ✅ Settings page looks clean
- ✅ What's New sheet displays correctly
- ✅ All screens tested in light and dark mode

---

## 🚨 Known Issues

### Apple Intelligence
- Requires iOS 26.0+ (not yet publicly available)
- Foundation Models framework not included in current Xcode
- Will be available after iOS 26 public release (expected June 2025)

### Workarounds
- Use OpenAI provider for now (default)
- Update to Apple Intelligence when iOS 26 is released

---

## 📈 Metrics to Track

After release, monitor:
- Crash rate (should decrease significantly)
- Update adoption rate
- User retention after update
- AI provider preference (OpenAI vs future Apple Intelligence)
- App Store reviews mentioning data safety

---

## 🔮 Future Roadmap

### v1.5.0 (Planned)
- Apple Intelligence activation when iOS 26 launches
- Tool calling for ingredient substitutions
- Nutrition data integration
- Recipe recommendations

### v2.0.0 (Future)
- iCloud sync
- Recipe sharing with friends
- Meal planning features
- Grocery list integration

---

## 📝 Developer Notes

### Migration Strategy
The app uses a simplified migration approach:
1. Users on unversioned schema → auto-migrate to V2 (version 1.0.0)
2. No V1 schema needed (was causing duplicate checksums)
3. Future V3 will migrate from V2 → V3 using RecipeMigrationPlan

### AI Provider Pattern
New providers can be added by:
1. Creating class conforming to `AIProvider` protocol
2. Adding to `AIProviderType` enum
3. Updating all generation views to use new provider
4. No changes needed to existing providers

### Build Configuration
- Development: Uses Development.xcconfig
- Release: Uses Release.xcconfig
- API keys managed via xcconfig files
- Deployment target: iOS 18.0

---

**Prepared by**: Claude Code
**Date**: 2026-02-12
**Version**: 1.4.0
