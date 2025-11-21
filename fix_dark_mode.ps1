# PowerShell script to safely replace hardcoded colors with theme-aware colors
# This script fixes dark mode text visibility issues

$files = @(
    "lib\screens\health_screen.dart",
    "lib\screens\history_screen.dart",
    "lib\screens\personal_info_screen.dart",
    "lib\screens\add_health_profile_screen.dart",
    "lib\screens\add_med_screen.dart",
    "lib\screens\dashboard_screen.dart",
    "lib\screens\manage_med_screen.dart",
    "lib\screens\med_info_screen.dart"
)

foreach ($file in $files) {
    $filePath = Join-Path $PSScriptRoot $file
    if (Test- Path $filePath) {
        Write-Host "Processing: $file"
        
        # Read content
        $content = Get-Content $filePath -Raw
        
        # Backup original
        Copy-Item $filePath "$filePath.backup"
        
        # Replace colors - TEXT COLORS (most important for visibility!)
        $content = $content -replace 'color: kPrimaryTextColor', 'color: Theme.of(context).colorScheme.onSurface'
        $content = $content -replace 'color: kSecondaryTextColor', 'color: Theme.of(context).colorScheme.onSurfaceVariant'
        
        # Replace colors - BACKGROUND COLORS
        $content = $content -replace 'backgroundColor: kBackgroundColor', 'backgroundColor: Theme.of(context).colorScheme.surface'
        $content = $content -replace 'color: kBackgroundColor', 'color: Theme.of(context).colorScheme.surface'
        
        # Replace colors - CARD COLORS
        $content = $content -replace 'color: kCardColor', 'color: Theme.of(context).colorScheme.surfaceContainerHighest'
        
        # Save
        Set-Content $filePath $content -NoNewline
        
        Write-Host "  ✓ Completed: $file"
    } else {
        Write-Host "  ✗ Not found: $file"
    }
}

Write-Host "`nDone! Backups saved with .backup extension"
Write-Host "Run 'flutter analyze' to check for errors"
