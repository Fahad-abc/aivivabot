# ============================================================
# FILE: create_aivivabot.ps1
# FOR: Android Studio + Flutter
# PROJECT: AI VivaBot (aivivabot)
#
# HOW TO RUN IN ANDROID STUDIO:
#
# METHOD 1 (Terminal inside Android Studio):
#   1. Open Terminal tab in Android Studio (bottom left)
#   2. Make sure you're in aivivabot folder
#   3. Run: ./create_aivivabot.ps1
#
# METHOD 2 (PowerShell outside Android Studio):
#   1. Navigate to aivivabot folder
#   2. Right-click → "Open in Terminal"
#   3. Run: ./create_aivivabot.ps1
# ============================================================

Write-Host "`n🤖 AI VivaBot - Project Structure Generator" -ForegroundColor Magenta
Write-Host "============================================`n" -ForegroundColor Magenta

# Get current directory (should be your aivivabot project)
$projectRoot = Get-Location
Write-Host "📁 Project Location: $projectRoot`n" -ForegroundColor Cyan

# Check if pubspec.yaml exists (to confirm we're in right folder)
if (-not (Test-Path "$projectRoot\pubspec.yaml")) {
    Write-Host "❌ ERROR: pubspec.yaml not found!" -ForegroundColor Red
    Write-Host "   Make sure you are in your aivivabot project folder" -ForegroundColor Yellow
    Write-Host "   Current location: $projectRoot" -ForegroundColor Yellow
    Write-Host "`n   Press any key to exit..." -ForegroundColor Red
    Read-Host
    exit
}

Write-Host "✅ Found pubspec.yaml - Correct folder confirmed`n" -ForegroundColor Green

# Create all folders
$folders = @(
    "lib\screens\onboarding",
    "lib\screens\auth",
    "lib\screens\dashboard",
    "lib\screens\examiner",
    "lib\screens\document",
    "lib\screens\viva",
    "lib\screens\report",
    "lib\screens\settings",
    "lib\screens\help",
    "lib\widgets\common",
    "lib\widgets\dashboard",
    "lib\widgets\viva",
    "lib\widgets\report",
    "lib\models",
    "lib\services\api",
    "lib\services\local",
    "lib\services\auth",
    "lib\services\speech",
    "lib\providers",
    "lib\utils",
    "lib\theme",
    "assets\animations",
    "assets\icons",
    "assets\fonts",
    "assets\audio"
)

Write-Host "📂 Creating folders..." -ForegroundColor Yellow
foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path "$projectRoot\$folder" | Out-Null
    Write-Host "   ✅ $folder" -ForegroundColor Green
}

# Create all screen files
$screens = @(
    "lib\screens\onboarding\onboarding_screen.dart",
    "lib\screens\auth\login_screen.dart",
    "lib\screens\auth\profile_setup_screen.dart",
    "lib\screens\dashboard\dashboard_screen.dart",
    "lib\screens\examiner\examiner_selection_screen.dart",
    "lib\screens\document\fyp_document_upload_screen.dart",
    "lib\screens\viva\viva_session_screen.dart",
    "lib\screens\viva\pause_menu_screen.dart",
    "lib\screens\viva\session_complete_screen.dart",
    "lib\screens\report\detailed_report_screen.dart",
    "lib\screens\report\weak_areas_analysis_screen.dart",
    "lib\screens\report\progress_over_time_screen.dart",
    "lib\screens\settings\settings_screen.dart",
    "lib\screens\help\help_tutorial_screen.dart"
)

Write-Host "`n📄 Creating screen files..." -ForegroundColor Yellow
foreach ($screen in $screens) {
    New-Item -ItemType File -Force -Path "$projectRoot\$screen" | Out-Null
    Write-Host "   ✅ $screen" -ForegroundColor Green
}

# Create main core files
$mainFiles = @(
    "lib\main.dart",
    "lib\app.dart",
    "lib\routes.dart",
    "lib\theme\app_theme.dart",
    "lib\theme\colors.dart",
    "lib\theme\typography.dart",
    "lib\utils\constants.dart",
    "lib\utils\helpers.dart",
    "lib\models\user_model.dart",
    "lib\models\question_model.dart",
    "lib\models\session_model.dart",
    "lib\models\report_model.dart",
    "lib\providers\auth_provider.dart",
    "lib\providers\session_provider.dart",
    "lib\providers\report_provider.dart",
    "lib\providers\settings_provider.dart",
    "lib\services\api\gemini_service.dart",
    "lib\services\api\openrouter_service.dart",
    "lib\services\local\database_service.dart",
    "lib\services\local\storage_service.dart",
    "lib\services\auth\auth_service.dart",
    "lib\services\speech\speech_to_text_service.dart",
    "lib\services\speech\text_to_speech_service.dart"
)

Write-Host "`n📄 Creating core files..." -ForegroundColor Yellow
foreach ($file in $mainFiles) {
    New-Item -ItemType File -Force -Path "$projectRoot\$file" | Out-Null
    Write-Host "   ✅ $file" -ForegroundColor Green
}

# Create basic widget files
$widgets = @(
    "lib\widgets\common\gradient_button.dart",
    "lib\widgets\common\glass_card.dart",
    "lib\widgets\common\animated_counter.dart",
    "lib\widgets\dashboard\stat_card.dart",
    "lib\widgets\dashboard\recent_session_card.dart",
    "lib\widgets\viva\ai_avatar.dart",
    "lib\widgets\viva\waveform_visualizer.dart",
    "lib\widgets\viva\recording_button.dart",
    "lib\widgets\report\question_expandable_card.dart",
    "lib\widgets\report\score_chip.dart"
)

Write-Host "`n📄 Creating widget files..." -ForegroundColor Yellow
foreach ($widget in $widgets) {
    New-Item -ItemType File -Force -Path "$projectRoot\$widget" | Out-Null
    Write-Host "   ✅ $widget" -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "🎉 AI VivaBot structure created successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Magenta

Write-Host "`n📊 SUMMARY:" -ForegroundColor Cyan
Write-Host "   📁 $($folders.Count) folders created" -ForegroundColor White
Write-Host "   📄 $($screens.Count) screen files created" -ForegroundColor White
Write-Host "   📄 $($mainFiles.Count) core files created" -ForegroundColor White
Write-Host "   📄 $($widgets.Count) widget files created" -ForegroundColor White
Write-Host "   📁 14 TOTAL SCREENS" -ForegroundColor Yellow

Write-Host "`n💡 NEXT STEPS (in Android Studio):" -ForegroundColor Yellow
Write-Host "   1. Click 'File' → 'Sync Project with Gradle Files'" -ForegroundColor White
Write-Host "   2. Or run: flutter pub get" -ForegroundColor White
Write-Host "   3. Then run: flutter run`n" -ForegroundColor White

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
Read-Host