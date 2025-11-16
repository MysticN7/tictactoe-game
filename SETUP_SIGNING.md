# Setting Up Release Signing for Google Play

## Problem
Your AAB is being signed in debug mode because GitHub Actions doesn't have access to your release signing keys.

## Solution: Add Signing Keys to GitHub Secrets

### Step 1: Generate a Keystore (if you don't have one)

If you already have a keystore, skip to Step 2.

Run this command in your terminal (replace with your details):

```bash
keytool -genkey -v -keystore tictactoe-release-key.jks -alias tictactoe-key -keyalg RSA -keysize 2048 -validity 10000
```

**Important:** Save the keystore file and remember:
- Keystore password
- Key alias (e.g., `tictactoe-key`)
- Key password

### Step 2: Encode Keystore to Base64

**On Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("tictactoe-release-key.jks")) | Out-File -Encoding ASCII keystore-base64.txt
```

**On Mac/Linux:**
```bash
base64 -i tictactoe-release-key.jks -o keystore-base64.txt
```

Copy the entire contents of `keystore-base64.txt` (it's one long line).

### Step 3: Add GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add these 4 secrets:

   - **Name:** `KEYSTORE_BASE64`
     - **Value:** Paste the entire base64 string from Step 2
   
   - **Name:** `KEYSTORE_PASSWORD`
     - **Value:** Your keystore password
   
   - **Name:** `KEY_ALIAS`
     - **Value:** Your key alias (e.g., `tictactoe-key`)
   
   - **Name:** `KEY_PASSWORD`
     - **Value:** Your key password

### Step 4: Re-run GitHub Actions

1. Go to **Actions** tab in your repository
2. Click **Build APK** workflow
3. Click **Run workflow** → **Run workflow**

The AAB will now be properly signed in release mode!

## Alternative: Build Locally

If you prefer to build locally instead of using GitHub Actions:

1. Create `android/key.properties`:
```
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=../tictactoe-release-key.jks
```

2. Place your `tictactoe-release-key.jks` file in the `android` directory

3. Build the AAB:
```bash
flutter build appbundle --release
```

The AAB will be at: `build/app/outputs/bundle/release/app-release.aab`

## Security Notes

- ⚠️ **NEVER commit your keystore file or key.properties to Git**
- ✅ The keystore is already in `.gitignore`
- ✅ GitHub Secrets are encrypted and secure
- ✅ Only use GitHub Secrets for CI/CD builds

