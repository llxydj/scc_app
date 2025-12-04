# Configuration & Setup Guide

This guide will help you configure all necessary API keys, Firebase, and other services required for the app to work properly.

## 🔥 Firebase Configuration (REQUIRED)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard:
   - Enter project name: `scc-learning-app` (or your preferred name)
   - Enable Google Analytics (optional but recommended)
   - Select or create Analytics account

### Step 2: Add Android App to Firebase

1. In Firebase Console, click "Add app" → Android
2. Register your app:
   - **Android package name**: `com.example.scc_app` (check `android/app/build.gradle` for actual package name)
   - **App nickname**: `SCC App Android` (optional)
   - **Debug signing certificate SHA-1**: (optional for now)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### Step 3: Add iOS App to Firebase

1. In Firebase Console, click "Add app" → iOS
2. Register your app:
   - **iOS bundle ID**: `com.example.sccApp` (check `ios/Runner.xcodeproj` for actual bundle ID)
   - **App nickname**: `SCC App iOS` (optional)
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

### Step 4: Enable Firebase Services

In Firebase Console, enable the following services:

#### Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable:
   - ✅ **Email/Password** (for teachers)
   - ✅ **Anonymous** (optional, for guest access)

#### Firestore Database
1. Go to **Firestore Database**
2. Click "Create database"
3. Start in **test mode** (for development)
4. Select a location (choose closest to your users)
5. Click "Enable"

#### Cloud Storage
1. Go to **Storage**
2. Click "Get started"
3. Start in **test mode** (for development)
4. Select same location as Firestore
5. Click "Done"

#### Cloud Messaging (FCM)
1. Go to **Cloud Messaging**
2. No additional setup needed (automatically enabled)

#### Analytics
1. Go to **Analytics**
2. Analytics is automatically enabled when you create the project

### Step 5: Generate Firebase Configuration Files

**Option A: Using FlutterFire CLI (Recommended)**

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Run configuration:
   ```bash
   flutterfire configure
   ```
   
   This will:
   - Detect your Firebase projects
   - Generate `lib/firebase_options.dart`
   - Configure Android and iOS automatically

3. Update `main.dart` to use the generated options:
   ```dart
   import 'firebase_options.dart';
   
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

**Option B: Manual Configuration**

If you prefer manual setup, you'll need to create `lib/firebase_options.dart` manually. See the template below.

### Step 6: Update Android Configuration

1. Open `android/build.gradle`:
   ```gradle
   buildscript {
       dependencies {
           // Add this line
           classpath 'com.google.gms:google-services:4.4.0'
       }
   }
   ```

2. Open `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.android.application'
   apply plugin: 'kotlin-android'
   // Add this line at the bottom
   apply plugin: 'com.google.gms.google-services'
   ```

### Step 7: Update iOS Configuration

1. Open `ios/Runner.xcodeproj` in Xcode
2. Ensure `GoogleService-Info.plist` is added to the project
3. In `ios/Podfile`, ensure platform is iOS 12.0+:
   ```ruby
   platform :ios, '12.0'
   ```

4. Run:
   ```bash
   cd ios
   pod install
   cd ..
   ```

## 🔐 Environment Variables (Optional)

For sensitive configuration, you can use environment variables:

1. Create `.env` file in root directory:
   ```
   FIREBASE_API_KEY=your_api_key_here
   FIREBASE_PROJECT_ID=your_project_id
   ```

2. Add to `.gitignore`:
   ```
   .env
   ```

## 📱 Platform-Specific Configuration

### Android

1. **Minimum SDK**: Ensure `android/app/build.gradle` has:
   ```gradle
   minSdkVersion 21
   ```

2. **Permissions**: Check `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
   ```

### iOS

1. **Minimum iOS Version**: Ensure `ios/Podfile` has:
   ```ruby
   platform :ios, '12.0'
   ```

2. **Info.plist**: Add required permissions in `ios/Runner/Info.plist`:
   ```xml
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need access to your photos to upload quiz images</string>
   ```

## 🧪 Testing Configuration

### Test Firebase Connection

1. Run the app:
   ```bash
   flutter run
   ```

2. Check logs for Firebase initialization:
   - Should see: "Firebase initialized successfully"
   - If you see errors, check your configuration files

### Test Authentication

1. Try creating a teacher account
2. Check Firebase Console → Authentication → Users
3. You should see the new user

### Test Firestore

1. Create some quiz questions
2. Check Firebase Console → Firestore Database
3. You should see data in `quiz_questions` collection

## 🚨 Common Issues & Solutions

### Issue: "Firebase initialization error"

**Solution:**
- Ensure `firebase_options.dart` exists
- Check that `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Verify package name/bundle ID matches Firebase project

### Issue: "MissingPluginException"

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "Google Services plugin not found"

**Solution:**
- Check `android/build.gradle` has Google Services classpath
- Check `android/app/build.gradle` applies the plugin

### Issue: iOS build fails

**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

## ✅ Configuration Checklist

- [ ] Firebase project created
- [ ] Android app added to Firebase
- [ ] iOS app added to Firebase
- [ ] `google-services.json` downloaded and placed correctly
- [ ] `GoogleService-Info.plist` downloaded and placed correctly
- [ ] `firebase_options.dart` generated (via FlutterFire CLI)
- [ ] Firebase Authentication enabled (Email/Password)
- [ ] Firestore Database created
- [ ] Cloud Storage enabled
- [ ] Android `build.gradle` files updated
- [ ] iOS pods installed
- [ ] App runs without Firebase errors
- [ ] Authentication works
- [ ] Data syncs to Firestore

## 📚 Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

## 🔒 Security Notes

1. **Never commit** `google-services.json` or `GoogleService-Info.plist` to public repositories
2. Use Firebase Security Rules to protect your data
3. Set up proper Firestore rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

4. Set up Storage rules:
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

---

**Need Help?** Check the Firebase documentation or contact the development team.

