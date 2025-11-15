# Simple Upload to GitHub Guide

## Step 1: Install Git (if you don't have it)
1. Download from: https://git-scm.com/download/win
2. Install with default settings
3. Restart your terminal/PowerShell
## Step 2: Create GitHub Repository
1. Go to https://github.com
2. Click **"+"** → **"New repository"**
3. Name: `tictactoe-game`
4. Choose **Public**
5. **DO NOT** check "Initialize with README"
6. Click **"Create repository"**

## Step 3: Copy These Commands
Open PowerShell in your project folder (`C:\tictactoe_game`) and run these **ONE BY ONE**:

```powershell
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/tictactoe-game.git
git push -u origin main
```

**IMPORTANT:** Replace `YOUR_USERNAME` with your actual GitHub username!

## Step 4: Enter GitHub Credentials
When prompted:
- **Username:** Your GitHub username
- **Password:** Use a **Personal Access Token** (not your password)

### How to create Personal Access Token:
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token"
3. Name it: "My App"
4. Check "repo" permission
5. Click "Generate token"
6. **COPY THE TOKEN** (you won't see it again!)
7. Use this token as your password when pushing

## That's it! Your files are now on GitHub! 🎉

