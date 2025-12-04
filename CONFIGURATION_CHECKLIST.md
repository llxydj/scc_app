# Configuration Checklist

Use this checklist to ensure all required configuration is complete before running the app.

## 🔥 Firebase Setup

- [ ] Firebase project created at https://console.firebase.google.com
- [ ] Android app registered in Firebase Console
- [ ] iOS app registered in Firebase Console (if building for iOS)
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] `GoogleService-Info.plist` downloaded and placed in `ios/Runner/` (iOS only)
- [ ] FlutterFire CLI installed: `dart pub global activate flutterfire_cli`
- [ ] Firebase configuration generated: `flutterfire configure`
- [ ] `lib/firebase_options.dart` file exists (auto-generated)

## 🔐 Firebase Services Enabled

- [ ] **Authentication** enabled with Email/Password provider
- [ ] **Firestore Database** created (start in test mode for development)
- [ ] **Cloud Storage** enabled (start in test mode for development)
- [ ] **Cloud Messaging (FCM)** enabled (automatic)
- [ ] **Analytics** enabled (automatic)

## 📱 Android Configuration

- [ ] `android/build.gradle` includes Google Services classpath:
  ```gradle
  classpath 'com.google.gms:google-services:4.4.0'
  ```
- [ ] `android/app/build.gradle` applies Google Services plugin:
  ```gradle
  apply plugin: 'com.google.gms.google-services'
  ```
- [ ] Minimum SDK version is 21 or higher
- [ ] Package name matches Firebase Android app configuration

## 🍎 iOS Configuration (if building for iOS)

- [ ] `ios/Podfile` has platform iOS 12.0 or higher
- [ ] Pods installed: `cd ios && pod install`
- [ ] Bundle ID matches Firebase iOS app configuration
- [ ] `GoogleService-Info.plist` added to Xcode project

## 🧪 Testing

- [ ] Run `flutter pub get` successfully
- [ ] Run `flutter clean` and rebuild
- [ ] App launches without Firebase errors
- [ ] Can create teacher account (Email/Password auth)
- [ ] Can create student account (Username/PIN)
- [ ] Data syncs to Firestore when online
- [ ] Push notifications work (if testing FCM)

## 🔒 Security (Before Production)

- [ ] Firestore Security Rules configured
- [ ] Storage Security Rules configured
- [ ] Sensitive files added to `.gitignore`:
  - `google-services.json`
  - `GoogleService-Info.plist`
  - `firebase_options.dart` (optional, can be regenerated)
- [ ] API keys not hardcoded in source code

## 📦 Dependencies

- [ ] All packages installed: `flutter pub get`
- [ ] No dependency conflicts
- [ ] Flutter SDK version compatible (3.24+)

## 🚀 Build Configuration

- [ ] Android signing key configured (for release builds)
- [ ] iOS provisioning profiles configured (for iOS release)
- [ ] App icons and splash screens added
- [ ] App name and version updated in `pubspec.yaml`

## ✅ Final Verification

- [ ] App runs in debug mode
- [ ] App runs in release mode (Android)
- [ ] All features work:
  - [ ] Student login
  - [ ] Teacher login
  - [ ] Quiz taking
  - [ ] Content creation
  - [ ] File upload
  - [ ] Progress tracking
  - [ ] Badge unlocking
  - [ ] Offline mode
  - [ ] Online sync

---

**Quick Start Command:**
```bash
# 1. Install FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Configure Firebase
flutterfire configure

# 3. Get dependencies
flutter pub get

# 4. Run the app
flutter run
```

**If you encounter issues, refer to SETUP_GUIDE.md for detailed instructions.**

