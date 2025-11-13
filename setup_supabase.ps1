#!/usr/bin/env pwsh
# ============================================================================
# MEDIMINDER SUPABASE SETUP SCRIPT - Auto Setup
# ============================================================================
# Script này sẽ tự động setup Supabase credentials cho bạn
# Cách chạy: powershell -ExecutionPolicy Bypass -File setup_supabase.ps1
# ============================================================================

Write-Host "
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║  🚀 MediMinder Supabase Setup Script                          ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

# ============================================================================
# STEP 1: Check if .env exists
# ============================================================================
Write-Host "
📋 STEP 1: Checking .env file...
" -ForegroundColor Yellow

$envPath = "lib\.env"
$envExamplePath = "lib\.env.example"

if (Test-Path $envPath) {
    Write-Host "✅ File $envPath already exists" -ForegroundColor Green
    
    # Read current content
    $content = Get-Content $envPath -Raw
    if ($content -match "YOUR_SUPABASE_URL" -or $content -match "YOUR_SUPABASE_ANON_KEY") {
        Write-Host "⚠️  File exists but contains placeholder values" -ForegroundColor Yellow
        Write-Host "You need to edit the file manually with real credentials" -ForegroundColor Yellow
    } else {
        Write-Host "✅ File contains credentials" -ForegroundColor Green
    }
} else {
    Write-Host "❌ File $envPath does not exist" -ForegroundColor Red
    
    if (Test-Path $envExamplePath) {
        Write-Host "📄 Copying from $envExamplePath..." -ForegroundColor Yellow
        Copy-Item $envExamplePath $envPath
        Write-Host "✅ File $envPath created" -ForegroundColor Green
    } else {
        Write-Host "❌ $envExamplePath also not found!" -ForegroundColor Red
        Write-Host "Please create lib\.env manually" -ForegroundColor Red
        exit 1
    }
}

# ============================================================================
# STEP 2: Ask for credentials
# ============================================================================
Write-Host "
📝 STEP 2: Enter Supabase Credentials
" -ForegroundColor Yellow

Write-Host "
Get credentials from: https://app.supabase.com/projects > Settings > API

" -ForegroundColor Cyan

$url = Read-Host "📌 Enter SUPABASE_URL (or press Enter to skip)"
$key = Read-Host "📌 Enter SUPABASE_ANON_KEY (or press Enter to skip)"

# ============================================================================
# STEP 3: Update .env file if credentials provided
# ============================================================================
if ($url -and $key) {
    Write-Host "
✍️  STEP 3: Updating .env file...
" -ForegroundColor Yellow
    
    $content = @"
SUPABASE_URL=$url
SUPABASE_ANON_KEY=$key
"@
    
    Set-Content -Path $envPath -Value $content
    Write-Host "✅ .env file updated successfully" -ForegroundColor Green
    
    # Verify
    Write-Host "
📋 Verifying credentials:
" -ForegroundColor Yellow
    
    $verifyContent = Get-Content $envPath
    Write-Host $verifyContent -ForegroundColor Cyan
} else {
    Write-Host "
⚠️  Skipping credential update
" -ForegroundColor Yellow
    Write-Host "You can edit $envPath manually later" -ForegroundColor Yellow
}

# ============================================================================
# STEP 4: Run flutter pub get
# ============================================================================
Write-Host "
📦 STEP 4: Running flutter pub get...
" -ForegroundColor Yellow

flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ flutter pub get completed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ flutter pub get failed" -ForegroundColor Red
    exit 1
}

# ============================================================================
# STEP 5: Verify .env loaded
# ============================================================================
Write-Host "
✨ STEP 5: Verification
" -ForegroundColor Yellow

Write-Host "
Files created/verified:
" -ForegroundColor Cyan

if (Test-Path $envPath) {
    Write-Host "  ✅ $envPath" -ForegroundColor Green
} else {
    Write-Host "  ❌ $envPath" -ForegroundColor Red
}

if (Test-Path "pubspec.yaml") {
    $pubspecContent = Get-Content "pubspec.yaml" -Raw
    if ($pubspecContent -match "flutter_dotenv") {
        Write-Host "  ✅ flutter_dotenv in pubspec.yaml" -ForegroundColor Green
    } else {
        Write-Host "  ❌ flutter_dotenv NOT in pubspec.yaml" -ForegroundColor Red
    }
}

if (Test-Path "lib/main.dart") {
    $mainContent = Get-Content "lib/main.dart" -Raw
    if ($mainContent -match "dotenv.load" -or $mainContent -match "await dotenv") {
        Write-Host "  ✅ dotenv.load in main.dart" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  dotenv.load might not be in main.dart" -ForegroundColor Yellow
    }
}

# ============================================================================
# STEP 6: Summary & Next Steps
# ============================================================================
Write-Host "
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║  ✅ Setup Complete!                                           ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
" -ForegroundColor Green

Write-Host "
📝 NEXT STEPS:

1. If you skipped entering credentials:
   → Edit: lib\.env
   → Add: SUPABASE_URL=https://...
   → Add: SUPABASE_ANON_KEY=...
   
2. Verify .gitignore includes:
   → .env
   → lib/.env
   
3. Run app:
   → flutter run
   
4. Check console:
   → ✅ Environment variables loaded successfully
   → ✅ Supabase initialized successfully
   
5. If error occurs:
   → Check: FIX_NOTINITIALIZED_ERROR.md
   → Check: SUPABASE_SETUP_GUIDE.md

" -ForegroundColor Cyan

Write-Host "
📚 Documentation:
   → SUPABASE_QUICK_START.md - Quick reference
   → SUPABASE_SETUP_GUIDE.md - Full guide
   → FIX_NOTINITIALIZED_ERROR.md - Error troubleshooting
   → SECURITY_CREDENTIALS.md - Security best practices

" -ForegroundColor Cyan

Write-Host "
🎉 Ready to code!
" -ForegroundColor Green
