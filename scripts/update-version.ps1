# Update version script
# Read version from typst.toml and update version numbers in README and template files

param(
    [string]$TomlPath = "..\typst.toml"
)

# Check if typst.toml file exists
if (-not (Test-Path $TomlPath)) {
    Write-Error "Error: Cannot find $TomlPath file"
    exit 1
}

# Read version from typst.toml
$tomlContent = Get-Content $TomlPath -Raw
if ($tomlContent -match 'version\s*=\s*"([^"]+)"') {
    $version = $Matches[1]
    Write-Host "Read version from typst.toml: $version" -ForegroundColor Green
} else {
    Write-Error "Error: Cannot extract version from $TomlPath"
    exit 1
}

# Define files to update
$filesToUpdate = @(
    @{
        Path = "..\README.md"
        Pattern = '(@preview/modern-buaa-thesis:)[\d\.]+'
        Replacement = "`${1}$version"
    },
    @{
        Path = "..\README-zh.md"
        Pattern = '(@preview/modern-buaa-thesis:)[\d\.]+'
        Replacement = "`${1}$version"
    },
    @{
        Path = "..\template\thesis.typ"
        Pattern = '(@preview/modern-buaa-thesis:)[\d\.]+'
        Replacement = "`${1}$version"
    }
)

$updateCount = 0
$errorCount = 0

# Update each file
foreach ($file in $filesToUpdate) {
    $filePath = $file.Path

    if (-not (Test-Path $filePath)) {
        Write-Warning "Warning: Cannot find file $filePath, skipping"
        $errorCount++
        continue
    }

    # Read file content
    $content = Get-Content $filePath -Raw -Encoding UTF8

    # Check if pattern is found
    if ($content -match $file.Pattern) {
        # Perform replacement
        $newContent = $content -replace $file.Pattern, $file.Replacement

        # Write back to file
        $newContent | Set-Content $filePath -Encoding UTF8 -NoNewline

        Write-Host "Updated $filePath" -ForegroundColor Cyan
        $updateCount++
    } else {
        Write-Warning "Warning: Version pattern not found in $filePath, skipping"
        $errorCount++
    }
}

# Output summary
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "Update completed!" -ForegroundColor Green
Write-Host "Successfully updated: $updateCount file(s)" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "Skipped/Failed: $errorCount file(s)" -ForegroundColor Yellow
}
Write-Host "Current version: $version" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Yellow
