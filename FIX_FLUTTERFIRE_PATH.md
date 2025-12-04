# Fix FlutterFire CLI Path Issue

## Problem
After installing FlutterFire CLI, you get:
```
'flutterfire' is not recognized as an internal or external command
```

This happens because the Pub cache bin directory is not on your Windows PATH.

## Solution Options

### Option 1: Use Full Command (Quick Fix - No PATH changes needed)

Instead of `flutterfire configure`, use:

```bash
dart pub global run flutterfire_cli:flutterfire configure
```

This works immediately without changing your PATH.

---

### Option 2: Add to PATH (Permanent Fix)

#### Step 1: Find Your Pub Cache Path
The path is: `C:\Users\bsist\AppData\Local\Pub\Cache\bin`

#### Step 2: Add to Windows PATH

**Method A: Using System Properties (Recommended)**

1. Press `Win + R` to open Run dialog
2. Type: `sysdm.cpl` and press Enter
3. Click the **"Advanced"** tab
4. Click **"Environment Variables"** button
5. Under **"User variables"**, find and select **"Path"**
6. Click **"Edit"**
7. Click **"New"**
8. Add: `C:\Users\bsist\AppData\Local\Pub\Cache\bin`
9. Click **"OK"** on all dialogs
10. **Close and reopen your terminal/command prompt**

**Method B: Using Command Line (Quick)**

1. Open PowerShell as Administrator
2. Run:
   ```powershell
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Users\bsist\AppData\Local\Pub\Cache\bin", "User")
   ```
3. Close and reopen your terminal

**Method C: Using Settings App (Windows 10/11)**

1. Press `Win + I` to open Settings
2. Search for "environment variables"
3. Click "Edit the system environment variables"
4. Click "Environment Variables"
5. Under "User variables", select "Path" and click "Edit"
6. Click "New" and add: `C:\Users\bsist\AppData\Local\Pub\Cache\bin`
7. Click "OK" on all dialogs
8. Close and reopen your terminal

#### Step 3: Verify

Close and reopen your terminal, then run:
```bash
flutterfire --version
```

You should see the version number.

---

### Option 3: Use Full Path Directly

You can also run the command using the full path:

```bash
C:\Users\bsist\AppData\Local\Pub\Cache\bin\flutterfire.bat configure
```

---

## Recommended: Use Option 1 for Now

For immediate use, just run:

```bash
dart pub global run flutterfire_cli:flutterfire configure
```

This will work right away without any PATH configuration.

---

## After Fixing PATH

Once PATH is configured, you can use the simpler command:

```bash
flutterfire configure
```

This will:
1. Detect your Firebase projects
2. Let you select a project
3. Generate `lib/firebase_options.dart`
4. Configure Android and iOS automatically

