# Install Firebase CLI

## Problem
FlutterFire CLI requires the official Firebase CLI to be installed first.

## Solution: Install Firebase CLI

### Option 1: Using npm (Recommended)

**Prerequisites:** Node.js must be installed

1. **Check if Node.js is installed:**
   ```bash
   node --version
   npm --version
   ```

2. **If Node.js is NOT installed:**
   - Download from: https://nodejs.org/
   - Install the LTS version
   - Restart your terminal after installation

3. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

4. **Verify installation:**
   ```bash
   firebase --version
   ```

5. **Login to Firebase:**
   ```bash
   firebase login
   ```
   This will open a browser window for authentication.

6. **Now run FlutterFire configure:**
   ```bash
   flutterfire configure
   ```

---

### Option 2: Using Standalone Binary (No Node.js needed)

1. **Download Firebase CLI:**
   - Go to: https://github.com/firebase/firebase-tools/releases
   - Download the latest `firebase-tools-win.exe` for Windows

2. **Rename and move:**
   - Rename to `firebase.exe`
   - Move to a folder on your PATH (e.g., `C:\Windows\System32`)
   - Or add the folder to PATH

3. **Verify:**
   ```bash
   firebase --version
   ```

4. **Login:**
   ```bash
   firebase login
   ```

5. **Run FlutterFire configure:**
   ```bash
   flutterfire configure
   ```

---

### Option 3: Using Chocolatey (Windows Package Manager)

If you have Chocolatey installed:

```bash
choco install firebase-cli
```

Then:
```bash
firebase login
flutterfire configure
```

---

## After Installing Firebase CLI

1. **Login to Firebase:**
   ```bash
   firebase login
   ```

2. **Run FlutterFire configure:**
   ```bash
   flutterfire configure
   ```

3. **Select or create a project:**
   - If you have existing projects, select one
   - If not, choose "yes" to create a new project

---

## Creating a New Firebase Project

If you choose "yes" to create a new project, you'll be asked:

1. **Project name:** Enter a name (e.g., `scc-learning-app`)
2. **Project ID:** Auto-generated (or you can customize)
3. **Select platforms:** Choose Android and/or iOS
4. **Package name (Android):** `com.example.scc_app`
5. **Bundle ID (iOS):** `com.example.sccApp`

FlutterFire will then:
- Create the Firebase project
- Generate `lib/firebase_options.dart`
- Download and place configuration files
- Configure everything automatically

---

## Quick Steps Summary

```bash
# 1. Install Firebase CLI (if Node.js is installed)
npm install -g firebase-tools

# 2. Login to Firebase
firebase login

# 3. Configure FlutterFire
flutterfire configure
```

---

## Troubleshooting

### "npm is not recognized"
→ Install Node.js from https://nodejs.org/

### "firebase login fails"
→ Make sure you have a Google account and internet connection

### "No projects found"
→ Choose "yes" to create a new project, or create one manually at https://console.firebase.google.com

