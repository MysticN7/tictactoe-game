# GitHub Secrets Setup Helper
# This script will display all the values you need to add to GitHub Secrets

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  GITHUB SECRETS SETUP HELPER" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Read the base64 keystore
$keystoreBase64 = Get-Content "keystore-base64.txt" -Raw

Write-Host "STEP 1: Go to your GitHub repository" -ForegroundColor Green
Write-Host "  → Settings → Secrets and variables → Actions" -ForegroundColor White
Write-Host "  → Click 'New repository secret'" -ForegroundColor White
Write-Host ""

Write-Host "STEP 2: Add these 4 secrets:" -ForegroundColor Green
Write-Host ""

# Secret 1
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Secret #1:" -ForegroundColor Yellow
Write-Host "  Name: KEYSTORE_BASE64" -ForegroundColor White
Write-Host "  Value: (See below - it's a long string)" -ForegroundColor White
Write-Host ""
Write-Host "Copy this entire value (it's one long line):" -ForegroundColor Yellow
Write-Host $keystoreBase64 -ForegroundColor Gray
Write-Host ""
Write-Host "Press any key to continue to next secret..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Secret 2
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Secret #2:" -ForegroundColor Yellow
Write-Host "  Name: KEYSTORE_PASSWORD" -ForegroundColor White
Write-Host "  Value: tictactoe2024" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to continue to next secret..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Secret 3
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Secret #3:" -ForegroundColor Yellow
Write-Host "  Name: KEY_ALIAS" -ForegroundColor White
Write-Host "  Value: tictactoe-key" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to continue to next secret..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Secret 4
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Secret #4:" -ForegroundColor Yellow
Write-Host "  Name: KEY_PASSWORD" -ForegroundColor White
Write-Host "  Value: tictactoe2024" -ForegroundColor Green
Write-Host ""

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  NEXT STEPS:" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. After adding all 4 secrets, go to Actions tab" -ForegroundColor White
Write-Host "2. Click 'Build APK' workflow" -ForegroundColor White
Write-Host "3. Click 'Run workflow' → 'Run workflow'" -ForegroundColor White
Write-Host "4. Wait for the build to complete" -ForegroundColor White
Write-Host "5. Download the AAB from Artifacts" -ForegroundColor White
Write-Host ""
Write-Host "Your AAB will be properly signed in release mode! ✅" -ForegroundColor Green
Write-Host ""

