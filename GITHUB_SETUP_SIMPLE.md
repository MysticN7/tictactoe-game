# 🚀 Quick GitHub Secrets Setup (3 Minutes)

## What You Need to Do

I've already generated everything for you! You just need to add 4 secrets to GitHub.

---

## Step-by-Step (Super Simple)

### 1. Open GitHub Secrets Page
- Go to: `https://github.com/YOUR_USERNAME/tictactoe-game/settings/secrets/actions`
- Or: Your Repo → **Settings** → **Secrets and variables** → **Actions**

### 2. Add 4 Secrets (Click "New repository secret" for each)

#### Secret 1: KEYSTORE_BASE64
- **Name:** `KEYSTORE_BASE64`
- **Value:** Open `keystore-base64.txt` and copy the ENTIRE content (it's one long line)

#### Secret 2: KEYSTORE_PASSWORD
- **Name:** `KEYSTORE_PASSWORD`
- **Value:** `tictactoe2024`

#### Secret 3: KEY_ALIAS
- **Name:** `KEY_ALIAS`
- **Value:** `tictactoe-key`

#### Secret 4: KEY_PASSWORD
- **Name:** `KEY_PASSWORD`
- **Value:** `tictactoe2024`

---

## That's It! 🎉

### Now Build Your Release:

1. Go to **Actions** tab in your GitHub repo
2. Click **"Build APK"** workflow
3. Click **"Run workflow"** → **"Run workflow"**
4. Wait 2-3 minutes for the build
5. Download the **release-aab** artifact

**Your AAB will be properly signed and ready for Google Play!** ✅

---

## Or Use the Helper Script

Run this in PowerShell (it will show you all values step by step):

```powershell
.\setup-github-secrets.ps1
```

---

## Troubleshooting

**If build still shows debug signing:**
- Make sure all 4 secrets are added correctly
- Check that KEYSTORE_BASE64 has the entire content (no line breaks)
- Re-run the workflow after adding secrets

**Need help?** Check `KEYSTORE_CREDENTIALS.txt` for all the details.

