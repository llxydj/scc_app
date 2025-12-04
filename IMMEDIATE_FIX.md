# Immediate Fix for FlutterFire Configuration

## Current Situation
- ✅ FlutterFire CLI is installed
- ❌ `dart` command not found (not on PATH)
- ❌ `flutterfire` command not found (not on PATH)
- ❌ `flutter` command not found (not on PATH)

## Quick Solutions

### Option 1: Add Flutter to PATH (Recommended)

**Step 1: Find Flutter Installation**

Flutter might be installed but not on PATH. Check these common locations:
- `C:\src\flutter\bin`
- `C:\flutter\bin`
- `C:\Users\bsist\flutter\bin`
- `C:\Program Files\flutter\bin`

**Or search for it:**
1. Open File Explorer
2. Go to C: drive
3. Search for `flutter.exe`
4. Note the folder path (e.g., `C:\src\flutter\bin`)

**Step 2: Add to PATH**

1. Press `Win + X` and select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", select "Path" and click "Edit"
5. Click "New" and add your Flutter bin path (e.g., `C:\src\flutter\bin`)
6. Click "New" again and add: `C:\Users\bsist\AppData\Local\Pub\Cache\bin`
7. Click "OK" on all dialogs
8. **Close and reopen your terminal**

**Step 3: Test**

```bash
flutter --version
dart --version
```

---

### Option 2: Use Full Paths (Temporary Workaround)

If Flutter is installed at `C:\src\flutter\bin`, you can use:

```bash
C:\src\flutter\bin\flutter.bat pub global run flutterfire_cli:flutterfire configure
```

Replace `C:\src\flutter\bin` with your actual Flutter path.

---

### Option 3: Install Flutter (If Not Installed)

If Flutter is not installed:

1. **Download Flutter:**
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Download the Flutter SDK zip file

2. **Extract:**
   - Extract to `C:\src\flutter` (or any location you prefer)
   - **DO NOT** extract to a path with spaces or special characters

3. **Add to PATH:**
   - Follow Step 2 from Option 1 above
   - Add `C:\src\flutter\bin` to PATH

4. **Verify:**
   ```bash
   flutter doctor
   ```

---

## After Adding to PATH

Once Flutter is on PATH, you can run:

```bash
flutterfire configure
```

This will:
1. Show your Firebase projects
2. Let you select one
3. Generate `lib/firebase_options.dart`
4. Configure Android and iOS

---

## Manual Firebase Setup (Alternative)

If you can't get FlutterFire CLI working, you can set up Firebase manually:

1. **Create Firebase Project:**
   - Go to https://console.firebase.google.com
   - Create a new project

2. **Add Android App:**
   - Package name: `com.example.scc_app`
   - Download `google-services.json`
   - Place in `android/app/google-services.json`

3. **Add iOS App:**
   - Bundle ID: `com.example.sccApp`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/GoogleService-Info.plist`

4. **Create `lib/firebase_options.dart` manually:**
   - See `lib/firebase_options.dart.template` for structure
   - Get API keys from Firebase Console → Project Settings

---

## Need Help?

1. Check if Flutter is installed: Search for `flutter.exe` in File Explorer
2. If found: Add its `bin` folder to PATH
3. If not found: Install Flutter first
4. Then run `flutterfire configure`

