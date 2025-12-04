# Windows PATH Setup Guide

## Problem
Both `dart` and `flutterfire` commands are not recognized because they're not on your PATH.

## Solution: Add Flutter and Dart to PATH

### Step 1: Find Your Flutter Installation

Flutter is usually installed in one of these locations:
- `C:\src\flutter\bin`
- `C:\flutter\bin`
- `C:\Users\YourName\flutter\bin`
- Or wherever you installed Flutter

**To find it:**
1. Open File Explorer
2. Search for `flutter.exe` on your C: drive
3. Note the path (e.g., `C:\src\flutter\bin`)

### Step 2: Add Flutter to PATH

**Method A: Using System Properties (Recommended)**

1. Press `Win + R` to open Run dialog
2. Type: `sysdm.cpl` and press Enter
3. Click the **"Advanced"** tab
4. Click **"Environment Variables"** button
5. Under **"User variables"**, find and select **"Path"**
6. Click **"Edit"**
7. Click **"New"** and add your Flutter bin path (e.g., `C:\src\flutter\bin`)
8. Click **"New"** again and add: `C:\Users\bsist\AppData\Local\Pub\Cache\bin`
9. Click **"OK"** on all dialogs
10. **IMPORTANT: Close and reopen your terminal/command prompt**

**Method B: Using PowerShell (Quick)**

1. Open PowerShell as Administrator
2. Run (replace `C:\src\flutter\bin` with your actual Flutter path):
   ```powershell
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin;C:\Users\bsist\AppData\Local\Pub\Cache\bin", "User")
   ```
3. Close and reopen your terminal

### Step 3: Verify

Close and reopen your terminal, then test:

```bash
flutter --version
dart --version
flutterfire --version
```

All three should work now.

---

## Alternative: Use Flutter Command

If Flutter is installed but not on PATH, you can use:

```bash
flutter pub global run flutterfire_cli:flutterfire configure
```

This uses Flutter's bundled Dart.

---

## Quick Check: Is Flutter Installed?

Try running:
```bash
where flutter
```

If it shows a path, Flutter is installed but not on PATH.
If it says "not found", you need to install Flutter first.

---

## If Flutter is Not Installed

1. Download Flutter from: https://flutter.dev/docs/get-started/install/windows
2. Extract to a location like `C:\src\flutter`
3. Follow Step 2 above to add to PATH
4. Run `flutter doctor` to verify installation

