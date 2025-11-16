# cleanup_docs.ps1
# Organiza la estructura de documentacion

Write-Host ""
Write-Host "=== Organizando documentacion ===" -ForegroundColor Cyan

# Crear carpetas si no existen
if (-not (Test-Path "scripts")) {
    New-Item -ItemType Directory -Path "scripts" | Out-Null
    Write-Host "OK: Creada carpeta: scripts/" -ForegroundColor Green
}

# Mover scripts a scripts/
$scriptsToMove = @(
    "07_WATCHER.ps1",
    "07_WATCHER_POLLING.ps1",
    "08_PARSER.ps1",
    "session_tracker.ps1",
    "profile_helpers.ps1",
    "update_docs.ps1"
)

foreach ($script in $scriptsToMove) {
    if (Test-Path $script) {
        $newName = $script
        
        # Renombrar los numerados
        if ($script -eq "07_WATCHER.ps1") { $newName = "watcher.ps1" }
        if ($script -eq "07_WATCHER_POLLING.ps1") { $newName = "watcher_polling.ps1" }
        if ($script -eq "08_PARSER.ps1") { $newName = "parser.ps1" }
        if ($script -eq "profile_helpers.ps1") { $newName = "helpers.ps1" }
        
        Move-Item -Path $script -Destination "scripts\$newName" -Force
        Write-Host "OK: Movido: $script -> scripts/$newName" -ForegroundColor Green
    }
}

# Mover archivos a logs/
$logsToMove = @(
    "session_state.json",
    "REGIS_MOV_ARCHIVOS.txt"
)

foreach ($log in $logsToMove) {
    if (Test-Path $log) {
        Move-Item -Path $log -Destination "logs\$log" -Force
        Write-Host "OK: Movido: $log -> logs/" -ForegroundColor Green
    }
}

# Eliminar duplicados
$toDelete = @(
    "update_docs.sh",
    "10_SESSION_TRACKER.md"
)

foreach ($file in $toDelete) {
    if (Test-Path $file) {
        Remove-Item -Path $file -Force
        Write-Host "DELETED: $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Estructura final ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Archivos documentacion:"
Get-ChildItem -Filter "*.md" | ForEach-Object { Write-Host "  $_" }
Write-Host ""
Write-Host "meta.json"

Write-Host ""
Write-Host "Carpetas:"
Get-ChildItem -Directory | ForEach-Object { Write-Host "  $_/" }

Write-Host ""
Write-Host "OK: Organizacion completa!" -ForegroundColor Green
Write-Host ""
