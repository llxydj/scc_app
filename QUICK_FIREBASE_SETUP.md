# Quick Firebase CLI Setup

## Current Situation
- ✅ FlutterFire CLI is installed
- ✅ Flutter is working
- ❌ Firebase CLI is NOT installed (required by FlutterFire)

## Solution: Install Firebase CLI

### Step 1: Install Node.js (Required for Firebase CLI)

1. **Download Node.js:**
   - Go to: https://nodejs.org/
   - Download the **LTS version** (recommended)
   - Run the installer

2. **Verify installation:**
   - Close and reopen your terminal
   - Run: `node --version`
   - Run: `npm --version`
   - Both should show version numbers

### Step 2: Install Firebase CLI

After Node.js is installed:

```bash
npm install -g firebase-tools
```

### Step 3: Login to Firebase

```bash
firebase login
```

This will:
- Open a browser window
- Ask you to sign in with your Google account
- Grant permissions to Firebase CLI

### Step 4: Run FlutterFire Configure

```bash
cd C:\Users\bsist\Downloads\scc_app
flutterfire configure
```

Now it should:
- Show your Firebase projects (or let you create one)
- Generate `lib/firebase_options.dart`
- Configure Android and iOS automatically

---

## Alternative: Create Project First (If You Don't Have One)

If you don't have a Firebase project yet:

1. **Go to Firebase Console:**
   - Visit: https://console.firebase.google.com
   - Sign in with your Google account
   - Click "Add project"
   - Follow the wizard to create a project

2. **Then run:**
   ```bash
   flutterfire configure
   ```
   - It will detect your new project
   - Select it and configure

---

## Complete Command Sequence

```bash
# 1. Install Node.js (if not installed)
# Download from https://nodejs.org/

# 2. Install Firebase CLI
npm install -g firebase-tools

# 3. Login
firebase login

# 4. Configure FlutterFire
cd C:\Users\bsist\Downloads\scc_app
flutterfire configure
```

---

## What Happens During `flutterfire configure`

1. **Lists your Firebase projects**
2. **Asks you to select one** (or create new)
3. **Asks which platforms** (Android, iOS, Web)
4. **For Android:**
   - Uses package name: `com.example.scc_app`
   - Downloads `google-services.json`
   - Places it in `android/app/`
5. **For iOS:**
   - Uses bundle ID: `com.example.sccApp`
   - Downloads `GoogleService-Info.plist`
   - Places it in `ios/Runner/`
6. **Generates `lib/firebase_options.dart`**
7. **Done!** ✅

---

## If You Choose "Yes" to Create New Project

When prompted "Would you like to create a new Firebase project? (y/n) › yes":

1. **Enter project name:** e.g., `scc-learning-app`
2. **Project ID:** Auto-generated (or customize)
3. **Select platforms:** Choose Android and/or iOS
4. **Android package name:** `com.example.scc_app`
5. **iOS bundle ID:** `com.example.sccApp`

FlutterFire will create everything automatically!

---

## Next Steps After Configuration

1. **Enable Firebase Services:**
   - Go to Firebase Console
   - Enable Authentication (Email/Password)
   - Create Firestore Database
   - Enable Cloud Storage

2. **Test the app:**
   ```bash
   flutter run
   ```

3. **Check for errors:**
   - Should see "Firebase initialized successfully" in logs
   - No Firebase errors

---

## Need Help?

- **Node.js installation:** https://nodejs.org/
- **Firebase CLI docs:** https://firebase.google.com/docs/cli
- **FlutterFire docs:** https://firebase.flutter.dev/

