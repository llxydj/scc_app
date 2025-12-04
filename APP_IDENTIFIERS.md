# App Identifiers

## 📱 Android Package Name

**Package Name:** `com.example.scc_app`

**Location:** `android/app/build.gradle.kts`
```kotlin
applicationId = "com.example.scc_app"
```

**Also found in:**
- `android/app/build.gradle.kts` (line 26)
- `android/app/src/main/kotlin/com/example/scc_app/MainActivity.kt`
- `android/app/google-services.json` (if configured)

---

## 🍎 iOS Bundle ID

**Bundle ID:** `com.example.sccApp`

**Location:** `ios/Runner.xcodeproj/project.pbxproj`
```
PRODUCT_BUNDLE_IDENTIFIER = com.example.sccApp;
```

**Also found in:**
- `ios/Runner.xcodeproj/project.pbxproj` (multiple locations)
- `ios/Runner/Info.plist` (references `$(PRODUCT_BUNDLE_IDENTIFIER)`)

---

## ⚠️ Important Notes

### For Firebase Configuration:

When setting up Firebase, you **MUST** use these exact identifiers:

1. **Android App in Firebase Console:**
   - Package name: `com.example.scc_app`
   - Download `google-services.json` and place in `android/app/`

2. **iOS App in Firebase Console:**
   - Bundle ID: `com.example.sccApp`
   - Download `GoogleService-Info.plist` and place in `ios/Runner/`

### ⚠️ Note: These are Default/Example Identifiers

These identifiers use `com.example` which is typically used for development/testing. 

**For production, you should change them to your own unique identifiers:**

- **Android:** Change to something like `com.yourcompany.sccapp` or `com.yourschool.sccapp`
- **iOS:** Change to match (e.g., `com.yourcompany.sccapp`)

**To change them:**

1. **Android:**
   - Edit `android/app/build.gradle.kts`
   - Change `applicationId = "com.example.scc_app"` to your desired package name
   - Update package name in `MainActivity.kt` file path and package declaration

2. **iOS:**
   - Open `ios/Runner.xcodeproj` in Xcode
   - Select the Runner target
   - Go to "Signing & Capabilities" tab
   - Change "Bundle Identifier" to your desired bundle ID
   - Or edit `ios/Runner.xcodeproj/project.pbxproj` directly (not recommended)

---

## 📋 Quick Reference

| Platform | Identifier | File Location |
|----------|-----------|---------------|
| **Android** | `com.example.scc_app` | `android/app/build.gradle.kts` |
| **iOS** | `com.example.sccApp` | `ios/Runner.xcodeproj/project.pbxproj` |

---

## 🔄 After Changing Identifiers

If you change these identifiers:

1. **Update Firebase Console:**
   - Update the package name/bundle ID in your Firebase project
   - Re-download configuration files
   - Replace `google-services.json` and `GoogleService-Info.plist`

2. **Clean and Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **For iOS:**
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```

