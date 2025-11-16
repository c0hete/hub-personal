# File: 07_WATCHER.ps1
# Purpose: File system watcher - Auto-detect file changes and trigger parser
# Version: 1.0.0
# Protocol: 06_METADATA_PROTOCOL.md v1.0.0

<#
.SYNOPSIS
    Observador de archivos - Detecta cambios y ejecuta parser automáticamente

.DESCRIPTION
    Monitorea carpetas del proyecto en busca de cambios en archivos.
    Cuando detecta un guardado, ejecuta 08_PARSER.ps1 automáticamente
    para procesar bloques @meta y actualizar MASTER.md.

.PARAMETER Path
    Ruta a monitorear (por defecto: directorio actual)

.PARAMETER Recursive
    Monitorear subcarpetas recursivamente

.PARAMETER Debounce
    Tiempo de espera (ms) antes de procesar (evita múltiples guardados)

.PARAMETER Extensions
    Extensiones de archivo a monitorear (separadas por coma)

.EXAMPLE
    .\07_WATCHER.ps1
    Monitorea directorio actual con configuración por defecto

.EXAMPLE
    .\07_WATCHER.ps1 -Path "C:/Projects/hub-personal" -Recursive
    Monitorea proyecto completo recursivamente

.EXAMPLE
    .\07_WATCHER.ps1 -Debounce 2000 -Extensions ".php,.vue,.js"
    Monitorea solo PHP, Vue y JS con 2 segundos de debounce
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Path = ".",
    
    [Parameter(Mandatory=$false)]
    [switch]$Recursive,
    
    [Parameter(Mandatory=$false)]
    [int]$Debounce = 1000,
    
    [Parameter(Mandatory=$false)]
    [string]$Extensions = ".php,.vue,.js,.jsx,.ts,.tsx,.blade.php,.sql"
)

# === CONFIGURACIÓN ===

$Script:Config = @{
    ParserScript = "08_PARSER.ps1"
    LogFile = "watcher.log"
    ExcludePaths = @(
        "node_modules",
        "vendor",
        ".git",
        "storage",
        "bootstrap/cache",
        "public/build"
    )
}

# Hash table para debounce (evitar múltiples ejecuciones)
$Script:PendingFiles = @{}
$Script:ProcessedCount = 0
$Script:ErrorCount = 0

# === FUNCIONES DE SALIDA ===

function Write-Success { param([string]$Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Error-Custom { param([string]$Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Warning-Custom { param([string]$Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Info { param([string]$Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }

# === LOGGING ===

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    Add-Content -Path $Script:Config.LogFile -Value $logEntry -ErrorAction SilentlyContinue
}

# === VALIDACIONES ===

function Test-Configuration {
    # Verificar que existe el parser
    if (!(Test-Path $Script:Config.ParserScript)) {
        Write-Error-Custom "Parser no encontrado: $($Script:Config.ParserScript)"
        Write-Host "Por favor asegúrate de que 08_PARSER.ps1 esté en el mismo directorio."
        return $false
    }
    
    # Verificar path a monitorear
    if (!(Test-Path $Path)) {
        Write-Error-Custom "Ruta no encontrada: $Path"
        return $false
    }
    
    return $true
}

# === FILTROS ===

function Test-ShouldProcess {
    param([string]$FilePath)
    
    # Verificar extensión
    $extension = [System.IO.Path]::GetExtension($FilePath)
    $allowedExtensions = $Extensions -split ',' | ForEach-Object { $_.Trim() }
    
    if ($extension -notin $allowedExtensions) {
        return $false
    }
    
    # Excluir rutas específicas
    foreach ($excludePath in $Script:Config.ExcludePaths) {
        if ($FilePath -like "*$excludePath*") {
            Write-Log "Archivo excluido: $FilePath (matched: $excludePath)" "DEBUG"
            return $false
        }
    }
    
    return $true
}

# === PROCESAR ARCHIVO ===

function Invoke-ProcessFile {
    param([string]$FilePath)
    
    # Verificar si debe procesarse
    if (!(Test-ShouldProcess -FilePath $FilePath)) {
        return
    }
    
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Info "Procesando: $FilePath"
    Write-Log "Processing file: $FilePath" "INFO"
    
    try {
        # Ejecutar parser
        $result = & ".\$($Script:Config.ParserScript)" -File $FilePath 2>&1
        
        # Mostrar resultado
        Write-Host $result
        
        $Script:ProcessedCount++
        Write-Success "Archivo procesado exitosamente"
        Write-Log "File processed successfully: $FilePath" "INFO"
        
    } catch {
        $Script:ErrorCount++
        Write-Error-Custom "Error procesando archivo: $_"
        Write-Log "Error processing file: $FilePath - $_" "ERROR"
    }
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
}

# === DEBOUNCE HANDLER ===

function Register-FileChange {
    param([string]$FilePath)
    
    # Cancelar timer existente si hay uno
    if ($Script:PendingFiles.ContainsKey($FilePath)) {
        $Script:PendingFiles[$FilePath].Dispose()
    }
    
    # Crear nuevo timer
    $timer = New-Object System.Timers.Timer
    $timer.Interval = $Debounce
    $timer.AutoReset = $false
    
    # Cuando el timer expira, procesar archivo
    $action = {
        param($source, $e)
        
        $file = $source.Tag
        Invoke-ProcessFile -FilePath $file
        
        # Limpiar timer
        $Script:PendingFiles.Remove($file)
        $source.Dispose()
    }
    
    Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action $action | Out-Null
    
    $timer.Tag = $FilePath
    $Script:PendingFiles[$FilePath] = $timer
    
    $timer.Start()
    
    Write-Host "⏱️  Archivo detectado (esperando $Debounce ms): $FilePath" -ForegroundColor DarkGray
    Write-Log "File change registered: $FilePath" "DEBUG"
}

# === EVENT HANDLERS ===

$onChanged = {
    param($source, $e)
    
    $filePath = $e.FullPath
    
    # Solo procesar eventos de cambio (no creación/eliminación)
    if ($e.ChangeType -eq 'Changed') {
        Register-FileChange -FilePath $filePath
    }
}

$onRenamed = {
    param($source, $e)
    
    Write-Log "File renamed: $($e.OldFullPath) → $($e.FullPath)" "INFO"
}

$onError = {
    param($source, $e)
    
    Write-Error-Custom "Watcher error: $($e.GetException())"
    Write-Log "Watcher error: $($e.GetException())" "ERROR"
}

# === CREAR WATCHER ===

function New-FileWatcher {
    param([string]$WatchPath, [bool]$IsRecursive)
    
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $WatchPath
    $watcher.IncludeSubdirectories = $IsRecursive
    $watcher.EnableRaisingEvents = $true
    
    # Filtro por extensiones (optimización)
    # Nota: Filtro adicional en Test-ShouldProcess
    $watcher.Filter = "*.*"
    
    # Eventos a monitorear
    $watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor
                           [System.IO.NotifyFilters]::LastWrite
    
    # Registrar event handlers
    Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $onChanged | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $onRenamed | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName Error -Action $onError | Out-Null
    
    return $watcher
}

# === MOSTRAR ESTADO ===

function Show-Status {
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║        WATCHER STATUS                  ║" -ForegroundColor Cyan
    Write-Host "╠════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║ Archivos procesados: $($Script:ProcessedCount.ToString().PadLeft(16)) ║" -ForegroundColor Cyan
    Write-Host "║ Errores:             $($Script:ErrorCount.ToString().PadLeft(16)) ║" -ForegroundColor Cyan
    Write-Host "║ Pendientes:          $($Script:PendingFiles.Count.ToString().PadLeft(16)) ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
}

# === CLEANUP ===

function Stop-Watcher {
    param($Watcher)
    
    Write-Info "`nDeteniendo watcher..."
    
    # Detener watcher
    if ($Watcher) {
        $Watcher.EnableRaisingEvents = $false
        $Watcher.Dispose()
    }
    
    # Cancelar timers pendientes
    foreach ($timer in $Script:PendingFiles.Values) {
        $timer.Dispose()
    }
    $Script:PendingFiles.Clear()
    
    # Limpiar event subscriptions
    Get-EventSubscriber | Where-Object { $_.SourceObject -is [System.IO.FileSystemWatcher] } | Unregister-Event
    
    Write-Success "Watcher detenido"
    Write-Log "Watcher stopped" "INFO"
}

# === BANNER ===

function Show-Banner {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                        ║" -ForegroundColor Cyan
    Write-Host "║         METADATA PROTOCOL FILE WATCHER v1.0.0          ║" -ForegroundColor Cyan
    Write-Host "║                                                        ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Configuration {
    Write-Host "Configuración:" -ForegroundColor Yellow
    Write-Host "  Ruta:        $Path" -ForegroundColor White
    Write-Host "  Recursivo:   $Recursive" -ForegroundColor White
    Write-Host "  Debounce:    $Debounce ms" -ForegroundColor White
    Write-Host "  Extensiones: $Extensions" -ForegroundColor White
    Write-Host "  Parser:      $($Script:Config.ParserScript)" -ForegroundColor White
    Write-Host ""
    Write-Host "Rutas excluidas:" -ForegroundColor Yellow
    foreach ($exclude in $Script:Config.ExcludePaths) {
        Write-Host "  - $exclude" -ForegroundColor DarkGray
    }
    Write-Host ""
}

function Show-Instructions {
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  WATCHER ACTIVO - Monitoreando cambios en archivos... ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "Instrucciones:" -ForegroundColor Yellow
    Write-Host "  1. Guarda archivos con bloques @meta" -ForegroundColor White
    Write-Host "  2. El watcher detectará automáticamente" -ForegroundColor White
    Write-Host "  3. El parser procesará los cambios" -ForegroundColor White
    Write-Host "  4. MASTER.md se actualizará solo" -ForegroundColor White
    Write-Host ""
    Write-Host "Controles:" -ForegroundColor Yellow
    Write-Host "  [S] - Mostrar estado" -ForegroundColor White
    Write-Host "  [Q] - Salir" -ForegroundColor White
    Write-Host ""
    Write-Host "Esperando cambios..." -ForegroundColor Cyan
    Write-Host ""
}

# === MAIN ===

function Main {
    # Banner
    Show-Banner
    
    # Validar configuración
    if (!(Test-Configuration)) {
        Write-Error-Custom "Configuración inválida. Saliendo..."
        exit 1
    }
    
    # Mostrar configuración
    Show-Configuration
    
    # Inicializar log
    Write-Log "=== Watcher session started ===" "INFO"
    Write-Log "Path: $Path" "INFO"
    Write-Log "Recursive: $Recursive" "INFO"
    Write-Log "Debounce: $Debounce ms" "INFO"
    Write-Log "Extensions: $Extensions" "INFO"
    
    # Crear watcher
    try {
        $watcher = New-FileWatcher -WatchPath $Path -IsRecursive:$Recursive
        Write-Success "Watcher iniciado correctamente"
        Write-Log "Watcher started successfully" "INFO"
    } catch {
        Write-Error-Custom "Error iniciando watcher: $_"
        Write-Log "Error starting watcher: $_" "ERROR"
        exit 1
    }
    
    # Instrucciones
    Show-Instructions
    
    # Loop principal
    try {
        while ($true) {
            # Esperar input del usuario
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                
                switch ($key.Key) {
                    'S' {
                        Show-Status
                    }
                    'Q' {
                        Write-Info "`nSaliendo..."
                        break
                    }
                }
                
                if ($key.Key -eq 'Q') {
                    break
                }
            }
            
            # Pequeña pausa para no consumir CPU
            Start-Sleep -Milliseconds 100
        }
    } finally {
        # Cleanup
        Stop-Watcher -Watcher $watcher
        
        # Mostrar resumen final
        Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║         RESUMEN DE SESIÓN              ║" -ForegroundColor Green
        Write-Host "╠════════════════════════════════════════╣" -ForegroundColor Green
        Write-Host "║ Archivos procesados: $($Script:ProcessedCount.ToString().PadLeft(16)) ║" -ForegroundColor Green
        Write-Host "║ Errores:             $($Script:ErrorCount.ToString().PadLeft(16)) ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""
        
        Write-Log "=== Watcher session ended ===" "INFO"
        Write-Log "Files processed: $Script:ProcessedCount" "INFO"
        Write-Log "Errors: $Script:ErrorCount" "INFO"
        
        Write-Success "Watcher finalizado. Hasta luego! 👋"
    }
}

# === MANEJO DE CTRL+C ===

# Handler para Ctrl+C
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Write-Host "`n`nCtrl+C detectado. Cerrando watcher..." -ForegroundColor Yellow
}

# === EJECUTAR ===

Main
