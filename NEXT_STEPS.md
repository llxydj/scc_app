# Next Steps After Firebase Configuration

## ✅ What's Done

- ✅ Firebase project selected: `belonio-56617 (Belonio)`
- ✅ All platforms configured (Android, iOS, macOS, Web, Windows)
- ✅ `lib/firebase_options.dart` generated
- ✅ Android app registered: `com.example.scc_app`
- ✅ iOS app registered: `com.example.sccApp`
- ✅ Configuration files downloaded and placed

## 🔥 Step 1: Enable Firebase Services

Go to Firebase Console and enable the required services:

### 1.1 Enable Authentication

1. Go to: https://console.firebase.google.com/project/belonio-56617/authentication
2. Click **"Get started"** (if first time)
3. Go to **"Sign-in method"** tab
4. Enable **"Email/Password"**:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Click "Save"

### 1.2 Create Firestore Database

1. Go to: https://console.firebase.google.com/project/belonio-56617/firestore
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select a location (choose closest to your users)
5. Click **"Enable"**

**⚠️ Important:** Test mode allows read/write for 30 days. For production, set up proper security rules.

### 1.3 Enable Cloud Storage

1. Go to: https://console.firebase.google.com/project/belonio-56617/storage
2. Click **"Get started"**
3. Choose **"Start in test mode"** (for development)
4. Select same location as Firestore
5. Click **"Done"**

### 1.4 Cloud Messaging (FCM)

- Already enabled automatically ✅
- No additional setup needed

### 1.5 Analytics

- Already enabled automatically ✅
- No additional setup needed

---

## 🧪 Step 2: Test the App

### 2.1 Install Dependencies

```bash
flutter pub get
```

### 2.2 Run the App

```bash
flutter run
```

### 2.3 Check for Errors

Look for these in the console:
- ✅ "Firebase initialized successfully"
- ❌ Any Firebase errors (should be none)

---

## ✅ Step 3: Verify Configuration Files

Check that these files exist:

### Android
- ✅ `android/app/google-services.json` (should exist)

### iOS
- ✅ `ios/Runner/GoogleService-Info.plist` (should exist)

### Flutter
- ✅ `lib/firebase_options.dart` (should exist)

---

## 🎯 Step 4: Test Key Features

### 4.1 Test Teacher Login (Requires Firebase Auth)

1. Open the app
2. Select "Teacher" role
3. Try to create an account with email/password
4. Check Firebase Console → Authentication → Users
5. You should see the new user

### 4.2 Test Student Login (Local - No Firebase needed)

1. Select "Student" role
2. Create account with username and PIN
3. Should work offline

### 4.3 Test Quiz Creation

1. Login as teacher
2. Create a quiz question
3. Check Firebase Console → Firestore Database
4. You should see data in `quiz_questions` collection

### 4.4 Test Data Sync

1. Create some data offline
2. Go online
3. Data should sync to Firestore automatically

---

## 🔒 Step 5: Set Up Security Rules (Important!)

### Firestore Security Rules

Go to: https://console.firebase.google.com/project/belonio-56617/firestore/rules

Replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Quiz questions - authenticated users can read, teachers can write
    match /quiz_questions/{questionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'teacher';
    }
    
    // Student progress - students can write their own, teachers can read all
    match /student_progress/{progressId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.user_id == request.auth.uid;
    }
    
    // Default: deny all
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Click **"Publish"**

### Storage Security Rules

Go to: https://console.firebase.google.com/project/belonio-56617/storage/rules

Replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Authenticated users can upload, read their own files
    match /{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Teachers can upload to shared folders
    match /shared/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'teacher';
    }
  }
}
```

Click **"Publish"**

---

## 📱 Step 6: Build for Production (When Ready)

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

---

## ✅ Verification Checklist

- [ ] Firebase Authentication enabled (Email/Password)
- [ ] Firestore Database created
- [ ] Cloud Storage enabled
- [ ] `lib/firebase_options.dart` exists
- [ ] `android/app/google-services.json` exists
- [ ] `ios/Runner/GoogleService-Info.plist` exists
- [ ] App runs without Firebase errors
- [ ] Teacher login works
- [ ] Student login works
- [ ] Data syncs to Firestore
- [ ] Security rules configured

---

## 🎉 You're All Set!

Your app is now fully configured with Firebase. You can:

- ✅ Create teacher accounts
- ✅ Sync data to cloud
- ✅ Use push notifications
- ✅ Track analytics
- ✅ Store files in cloud

---

## 🆘 Troubleshooting

### "Firebase initialization error"
→ Check that `lib/firebase_options.dart` exists and is correct

### "Authentication failed"
→ Make sure Email/Password is enabled in Firebase Console

### "Permission denied" in Firestore
→ Check security rules are published

### "Storage permission denied"
→ Check Storage security rules

---

## 📚 Additional Resources

- Firebase Console: https://console.firebase.google.com/project/belonio-56617
- FlutterFire Docs: https://firebase.flutter.dev/
- Firestore Rules: https://firebase.google.com/docs/firestore/security/get-started


