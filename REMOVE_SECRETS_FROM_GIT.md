# 🔒 How to Remove Exposed Secrets from Git History

## ⚠️ CRITICAL: Your API Keys Are Exposed!

Your Firebase API keys have been committed to GitHub. Even if you delete them now, they remain in Git history. Follow these steps to completely remove them.

---

## Step 1: Rotate Your Firebase API Keys (IMPORTANT!)

**Before removing from Git, you MUST rotate your API keys in Firebase Console:**

1. Go to: https://console.firebase.google.com/project/belonio-56617/settings/general
2. Scroll to "Your apps" section
3. For each app (Web, Android, iOS):
   - Click on the app
   - Go to "Settings" → "General"
   - Click "Regenerate API key" or create a new app
   - **Save the new keys** (you'll need them for your `.env` file)

**Why?** Even after removing from Git, anyone who cloned your repo before you fix it will have the old keys.

---

## Step 2: Remove Secrets from Git History

### Option A: Using git filter-branch (Recommended for small repos)

```bash
# Remove firebase_options.dart from all commits
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch lib/firebase_options.dart" \
  --prune-empty --tag-name-filter cat -- --all

# Remove GoogleService-Info.plist from all commits
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch ios/Runner/GoogleService-Info.plist" \
  --prune-empty --tag-name-filter cat -- --all

# Remove google-services.json from all commits
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch android/app/google-services.json" \
  --prune-empty --tag-name-filter cat -- --all

# Force push to overwrite remote history
git push origin --force --all
git push origin --force --tags
```

### Option B: Using BFG Repo-Cleaner (Faster, recommended for large repos)

1. **Download BFG**: https://rtyley.github.io/bfg-repo-cleaner/

2. **Create a file with keys to remove** (`keys-to-remove.txt`):
```
YOUR_WEB_API_KEY_HERE
YOUR_ANDROID_API_KEY_HERE
YOUR_IOS_API_KEY_HERE
```
Replace these placeholders with your actual exposed API keys.

3. **Run BFG**:
```bash
# Clone a fresh copy of your repo
git clone --mirror https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Run BFG to remove the keys
java -jar bfg.jar --replace-text keys-to-remove.txt YOUR_REPO.git

# Clean up
cd YOUR_REPO.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Push the cleaned history
git push --force
```

### Option C: Nuclear Option - Start Fresh (If repo is new/small)

If your repository is new and doesn't have important history:

```bash
# Remove .git folder
rm -rf .git

# Initialize new repo
git init
git add .
git commit -m "Initial commit - secure version"

# Force push to new branch
git branch -M main
git remote add origin YOUR_REPO_URL
git push -u origin main --force
```

---

## Step 3: Update Your Local Files

After removing from Git history, make sure your local files are updated:

1. **Delete the hardcoded files** (they're now in .gitignore):
```bash
# These are now gitignored and will use .env instead
# You can delete them or keep them as fallback
```

2. **Update your `.env` file** with the NEW rotated API keys from Step 1

3. **Verify `.gitignore` includes**:
   - `.env`
   - `lib/firebase_options.dart`
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

---

## Step 4: Verify Secrets Are Removed

```bash
# Search Git history for exposed keys
git log --all --full-history --source -- "lib/firebase_options.dart"
git log --all --full-history --source -- "ios/Runner/GoogleService-Info.plist"
git log --all --full-history --source -- "android/app/google-services.json"

# Search for API keys in history (replace with your actual keys)
git log -p -S "YOUR_WEB_API_KEY" --all
git log -p -S "YOUR_ANDROID_API_KEY" --all
git log -p -S "YOUR_IOS_API_KEY" --all
```

If these commands return nothing, the secrets are removed.

---

## Step 5: Update GitHub Secret Scanning

1. Go to your GitHub repository
2. Go to **Settings** → **Security** → **Secret scanning**
3. If alerts still show, click **"Dismiss"** and mark as **"Revoked"**
4. After rotating keys, the alerts should clear

---

## Step 6: Notify Collaborators

If others have cloned your repo:

```bash
# They need to:
git fetch origin
git reset --hard origin/main
# Or re-clone the repository
```

---

## ✅ Checklist

- [ ] Rotated all Firebase API keys in Firebase Console
- [ ] Updated `.env` file with new keys
- [ ] Removed secrets from Git history
- [ ] Verified `.gitignore` is correct
- [ ] Force pushed cleaned history to GitHub
- [ ] Verified no secrets remain in Git history
- [ ] Dismissed GitHub security alerts
- [ ] Notified team members to re-clone

---

## 🛡️ Prevention for Future

1. **Always check `.gitignore`** before committing
2. **Use pre-commit hooks** to scan for secrets:
   ```bash
   pip install detect-secrets
   detect-secrets scan > .secrets.baseline
   ```
3. **Use GitHub Secret Scanning** (already enabled)
4. **Never commit**:
   - `.env` files
   - `firebase_options.dart`
   - `google-services.json`
   - `GoogleService-Info.plist`
   - Any file with API keys

---

## 📚 Additional Resources

- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
- [Firebase: Regenerate API Keys](https://console.firebase.google.com/project/belonio-56617/settings/general)

---

## ⚠️ Important Notes

1. **Force pushing rewrites history** - coordinate with your team
2. **Rotate keys FIRST** - old keys are already exposed
3. **Backup your repo** before running filter-branch
4. **Test your app** after rotating keys to ensure everything works

