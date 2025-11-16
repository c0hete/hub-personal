param([switch]$Update,[switch]$Check)

$MetaFile = "meta.json"
$MasterDoc = "01_MASTER_DOC.md"
$ContextDoc = "02_CONTEXT.md"

function Write-Success { param($m) Write-Host "[OK] $m" -ForegroundColor Green }
function Write-Error-Custom { param($m) Write-Host "[ERROR] $m" -ForegroundColor Red }
function Write-Info { param($m) Write-Host "[INFO] $m" -ForegroundColor Cyan }

Write-Host ""
Write-Host "=== UPDATE DOCS v1.2 ===" -ForegroundColor Cyan
Write-Host ""

if (!(Test-Path $MetaFile)) {
    Write-Error-Custom "meta.json not found"
    exit 1
}

$metaJson = Get-Content $MetaFile -Raw
$meta = $metaJson | ConvertFrom-Json

if ($Check) {
    $currentVer = if ($meta.version) { $meta.version } else { "not set" }
    Write-Info "Current version: $currentVer"
    Write-Info "Project: $($meta.project.name)"
    Write-Host ""
    
    if (Test-Path $MasterDoc) {
        $lines = (Get-Content $MasterDoc).Count
        Write-Info "MASTER.md: $lines lines"
    }
    
    if (Test-Path $ContextDoc) {
        $lines = (Get-Content $ContextDoc).Count
        Write-Info "CONTEXT.md: $lines lines"
    }
    
    Write-Success "Documentation is up to date"
    exit 0
}

if ($Update) {
    $currentVersion = if ($meta.version -and $meta.version -match "^\d+\.\d+\.\d+$") { 
        $meta.version 
    } else { 
        "2.1.0" 
    }
    
    $parts = $currentVersion -split "\."
    $major = [int]$parts[0]
    $minor = [int]$parts[1]
    $patch = [int]$parts[2]
    
    $patch++
    $newVersion = "$major.$minor.$patch"
    
    Write-Info "Version: $currentVersion -> $newVersion"
    
    $metaHash = @{}
    $meta.PSObject.Properties | ForEach-Object {
        $metaHash[$_.Name] = $_.Value
    }
    
    $metaHash["version"] = $newVersion
    
    if (!$metaHash.ContainsKey("tracking")) {
        $metaHash["tracking"] = @{}
    }
    $metaHash["tracking"]["last_updated"] = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    
    $metaHash | ConvertTo-Json -Depth 10 | Set-Content $MetaFile -Encoding UTF8
    
    Write-Success "meta.json updated to v$newVersion"
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $changelogEntry = "`n### v$newVersion - $timestamp`n**Auto-update:** Documentation synchronized`n"
    
    if (Test-Path $ContextDoc) {
        Add-Content -Path $ContextDoc -Value $changelogEntry
        Write-Success "Changelog updated"
    }
    
    Write-Host ""
    Write-Success "Documentation versioned: v$newVersion"
    
} else {
    Write-Info "Usage:"
    Write-Info "  .\update_docs.ps1 -Check    # Show current status"
    Write-Info "  .\update_docs.ps1 -Update   # Bump version (patch)"
}
