# GitHub Actions Setup Guide

## ✅ Benefits
- **100% FREE** for public repositories
- **FREE** for private repos (2,000 minutes/month)
- **Faster** than local builds (cloud servers are powerful)
- **Automatic** - builds on every push
- **No PC crashes** - runs in the cloud

## 🚀 Quick Setup (5 minutes)

### Step 1: Create GitHub Account
1. Go to https://github.com
2. Sign up (free)

### Step 2: Create a New Repository
1. Click the **"+"** button → **"New repository"**
2. Name it: `tictactoe-game` (or any name)
3. Choose **Public** (free unlimited builds)
4. **DO NOT** check "Initialize with README"
5. Click **"Create repository"**

### Step 3: Upload Your Project
1. Open PowerShell in your project folder: `C:\tictactoe_game`
2. Run these commands:

```powershell
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/tictactoe-game.git
git push -u origin main
```

(Replace `YOUR_USERNAME` with your GitHub username)

### Step 4: Build Your APK
1. Go to your repository on GitHub
2. Click the **"Actions"** tab
3. You'll see "Build APK" workflow
4. Click **"Run workflow"** → **"Run workflow"** button
5. Wait 5-10 minutes
6. Click on the completed workflow run
7. Scroll down to **"Artifacts"**
8. Download **"release-apk"** - that's your APK! 📱

## 🎯 Automatic Builds
Every time you push code, it automatically builds a new APK!

## 📱 Alternative: Codemagic (Even Easier)
1. Go to https://codemagic.io
2. Sign up with GitHub
3. Click **"Add application"**
4. Select your repository
5. Click **"Start new build"**
6. Download APK when done!

---

**Note:** The workflow file is already created at `.github/workflows/build_apk.yml`

