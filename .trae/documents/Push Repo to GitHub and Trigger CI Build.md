## Pre‑flight
- Ensure `.github/workflows/build_apk.yml` exists (it does) so pushes trigger APK/AAB builds
- Use repository name `tictactoe-game` and your GitHub username

## Create GitHub Repository
- Visit GitHub → New repository → Name: `tictactoe-game` → Public → Do not initialize with README

## Push Local Code (PowerShell in `C:\tictactoe_game`)
- `git init`
- `git add .`
- `git commit -m "Initial commit: tournament mode, fixes, branding"`
- `git branch -M main`
- `git remote add origin https://github.com/YOUR_USERNAME/tictactoe-game.git`
- `git push -u origin main`
- When prompted: use a Personal Access Token as the password (`repo` scope)

## Trigger GitHub Actions
- Open repo → Actions → "Build APK" workflow will auto-run on `main`
- Or click "Run workflow" to start manually

## Download Artifacts
- Open the completed run → Artifacts:
  - `release-apk`: `build/app/outputs/flutter-apk/app-release.apk`
  - `release-aab`: `build/app/outputs/bundle/release/app-release.aab` (preferred for Play Store)

## Optional: Signed Release from CI
- If you want CI-signed builds: provide keystore and secrets; I’ll add secure signing steps later