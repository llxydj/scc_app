# Quick Start Guide

## 🚀 Fastest Way to Get Started

### Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 2: Configure Firebase
```bash
flutterfire configure
```
This will:
- Detect your Firebase projects
- Generate `lib/firebase_options.dart` automatically
- Configure Android and iOS

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Run the App
```bash
flutter run
```

---

## 📋 What You Need Before Starting

1. **Firebase Account**: Sign up at https://console.firebase.google.com
2. **Flutter SDK**: Version 3.24+ installed
3. **Android Studio** or **Xcode** (for iOS)

---

## ⚠️ If Firebase is Not Configured

The app will still run but with limited functionality:
- ✅ Local database (SQLite) will work
- ✅ Offline features will work
- ❌ Cloud sync won't work
- ❌ Push notifications won't work
- ❌ Teacher authentication won't work (Email/Password requires Firebase)

---

## 🔧 Manual Firebase Setup (Alternative)

If `flutterfire configure` doesn't work, follow the detailed guide in **SETUP_GUIDE.md**

---

## ✅ Verify Configuration

After setup, check:
1. `lib/firebase_options.dart` exists
2. `android/app/google-services.json` exists (Android)
3. `ios/Runner/GoogleService-Info.plist` exists (iOS)
4. App runs without Firebase errors

---

**Need detailed instructions?** See **SETUP_GUIDE.md** or **CONFIGURATION_CHECKLIST.md**

