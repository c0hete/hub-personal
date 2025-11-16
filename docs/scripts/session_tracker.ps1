# File: docs/session_tracker.ps1
# Purpose: Track Claude conversation messages and manage session transitions
# Author: Jose Alvarado Mazzei + Claude
# Version: 1.0.0

param(
    [Parameter(Mandatory=$false)]
    [switch]$Start,
    
    [Parameter(Mandatory=$false)]
    [switch]$AddMessage,
    
    [Parameter(Mandatory=$false)]
    [switch]$End,
    
    [Parameter(Mandatory=$false)]
    [switch]$Status,
    
    [Parameter(Mandatory=$false)]
    [string]$Summary = "",
    
    [Parameter(Mandatory=$false)]
    [string]$NextSteps = "",
    
    [Parameter(Mandatory=$false)]
    [string]$ConversationUrl = ""
)

$script:StateFile = Join-Path $PSScriptRoot "session_state.json"
$script:MigrationTemplate = Join-Path $PSScriptRoot "09_MIGRATION_TO_NEW_SESSION.md"

function Get-SessionState {
    if (-not (Test-Path $script:StateFile)) {
        $defaultState = @{
            version = "1.0.0"
            current_session = $null
            sessions = @()
            settings = @{
                warning_threshold = 40
                danger_threshold = 50
                show_notifications = $true
                auto_generate_migration = $true
                save_conversation_links = $true
            }
            statistics = @{
                total_sessions = 0
                total_messages = 0
                average_messages_per_session = 0
                last_session_date = $null
            }
        }
        
        $defaultState | ConvertTo-Json -Depth 10 | Set-Content $script:StateFile
        return $defaultState
    }
    
    $json = Get-Content $script:StateFile -Raw | ConvertFrom-Json
    return $json
}

function Save-SessionState {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $script:StateFile
}

function Get-SessionId {
    $date = Get-Date -Format "yyyy-MM-dd"
    $state = Get-SessionState
    
    $todaySessions = $state.sessions | Where-Object { $_.id -like "$date-*" }
    $sessionNumber = ($todaySessions.Count + 1).ToString("000")
    
    return "$date-$sessionNumber"
}

function Show-ProgressBar {
    param(
        [int]$Current,
        [int]$Warning,
        [int]$Danger
    )
    
    $max = $Danger
    $percentage = [Math]::Min(($Current / $max) * 100, 100)
    $filled = [Math]::Floor($percentage / 10)
    $empty = 10 - $filled
    
    $color = if ($Current -ge $Danger) { 'Red' }
             elseif ($Current -ge $Warning) { 'Yellow' }
             else { 'Green' }
    
    $bar = "[" + ("#" * $filled) + ("-" * $empty) + "]"
    
    Write-Host ""
    Write-Host "Session Progress: " -NoNewline
    Write-Host "$bar $Current/$max messages" -ForegroundColor $color
    
    if ($Current -ge $Danger) {
        Write-Host "!! CAMBIAR CONVERSACION AHORA !!" -ForegroundColor Red
    }
    elseif ($Current -ge $Warning) {
        Write-Host "-> Considera cambiar de conversacion pronto" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

function New-MigrationFile {
    param(
        [hashtable]$Session,
        [string]$Summary,
        [string]$NextSteps
    )
    
    $migrationFile = Join-Path $PSScriptRoot "09_MIGRATION_TO_NEW_SESSION.md"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $content = @"
# [MIGRATION] SESSION CONTEXT TRANSFER

**From:** Session $($Session.id) ($($Session.messages) messages)
**To:** New session  
**Date:** $timestamp

---

## [SESSION:SUMMARY]

**Session ID:** $($Session.id)
**Duration:** $($Session.started) - $($Session.ended)
**Messages:** $($Session.messages)
**Conversation:** $($Session.conversation_url)

**What we accomplished:**
$Summary

**Next steps:**
$NextSteps

---

## [INSTRUCTIONS:NEXT_SESSION]

At start of new conversation:

1. Paste 04_SESSION_START.md (loads base context)
2. Paste this file (09_MIGRATION_TO_NEW_SESSION.md)
3. Run: .\session_tracker.ps1 -Start
4. Continue from where we left off

---

**[MIGRATION:COMPLETE]**
"@
    
    Set-Content -Path $migrationFile -Value $content
    
    Write-Host "Generated migration file: 09_MIGRATION_TO_NEW_SESSION.md" -ForegroundColor Green
    
    return $migrationFile
}

function Start-SessionTracking {
    $state = Get-SessionState
    
    if ($state.current_session) {
        Write-Host "Session already active: $($state.current_session.id)" -ForegroundColor Yellow
        Write-Host "Run -End first to close current session" -ForegroundColor Gray
        return
    }
    
    $sessionId = Get-SessionId
    
    $newSession = @{
        id = $sessionId
        started = (Get-Date -Format "HH:mm:ss")
        ended = $null
        messages = 0
        conversation_url = ""
        accomplishments = @()
        next_steps = @()
        warning_shown = $false
        danger_shown = $false
    }
    
    $state.current_session = $newSession
    Save-SessionState -State $state
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  SESSION TRACKING STARTED" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Session ID: $sessionId" -ForegroundColor White
    Write-Host "Started: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Call .\session_tracker.ps1 -AddMessage after each message sent" -ForegroundColor Yellow
    Write-Host "Warnings at: $($state.settings.warning_threshold) messages" -ForegroundColor Gray
    Write-Host "Critical at: $($state.settings.danger_threshold) messages" -ForegroundColor Gray
    Write-Host ""
    
    Show-ProgressBar -Current 0 -Warning $state.settings.warning_threshold -Danger $state.settings.danger_threshold
}

function Add-SessionMessage {
    $state = Get-SessionState
    
    if (-not $state.current_session) {
        Write-Host "No active session. Run -Start first." -ForegroundColor Red
        return
    }
    
    $state.current_session.messages++
    $current = $state.current_session.messages
    $warning = $state.settings.warning_threshold
    $danger = $state.settings.danger_threshold
    
    Save-SessionState -State $state
    
    Show-ProgressBar -Current $current -Warning $warning -Danger $danger
    
    if ($current -eq $warning -and -not $state.current_session.warning_shown) {
        $state.current_session.warning_shown = $true
        Save-SessionState -State $state
        Write-Host "WARNING: $current mensajes enviados. Considera cambiar pronto." -ForegroundColor Yellow
    }
    
    if ($current -eq $danger -and -not $state.current_session.danger_shown) {
        $state.current_session.danger_shown = $true
        Save-SessionState -State $state
        Write-Host "CRITICAL: $current mensajes. CAMBIAR AHORA." -ForegroundColor Red
        Write-Host "Tip: Run .\session_tracker.ps1 -End -Summary 'what you did' -NextSteps 'what next'" -ForegroundColor Cyan
    }
}

function Stop-SessionTracking {
    param(
        [string]$Summary,
        [string]$NextSteps,
        [string]$ConversationUrl
    )
    
    $state = Get-SessionState
    
    if (-not $state.current_session) {
        Write-Host "No active session." -ForegroundColor Red
        return
    }
    
    $session = $state.current_session
    $session.ended = Get-Date -Format "HH:mm:ss"
    
    if ($ConversationUrl) {
        $session.conversation_url = $ConversationUrl
    }
    
    if ($Summary) {
        $session.accomplishments = $Summary -split ';' | ForEach-Object { $_.Trim() }
    }
    
    if ($NextSteps) {
        $session.next_steps = $NextSteps -split ';' | ForEach-Object { $_.Trim() }
    }
    
    $state.sessions += $session
    
    $state.statistics.total_sessions++
    $state.statistics.total_messages += $session.messages
    $state.statistics.average_messages_per_session = [Math]::Round(
        $state.statistics.total_messages / $state.statistics.total_sessions, 1
    )
    $state.statistics.last_session_date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $state.current_session = $null
    
    Save-SessionState -State $state
    
    if ($state.settings.auto_generate_migration -and ($Summary -or $NextSteps)) {
        New-MigrationFile -Session $session -Summary $Summary -NextSteps $NextSteps
    }
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  SESSION CLOSED" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Session: $($session.id)" -ForegroundColor White
    Write-Host "Duration: $($session.started) - $($session.ended)" -ForegroundColor Gray
    Write-Host "Messages: $($session.messages)" -ForegroundColor Gray
    
    if ($session.accomplishments.Count -gt 0) {
        Write-Host ""
        Write-Host "Accomplishments:" -ForegroundColor Yellow
        $session.accomplishments | ForEach-Object { Write-Host "  - $_" -ForegroundColor Green }
    }
    
    if ($session.next_steps.Count -gt 0) {
        Write-Host ""
        Write-Host "Next Steps:" -ForegroundColor Yellow
        $session.next_steps | ForEach-Object { Write-Host "  -> $_" -ForegroundColor Cyan }
    }
    
    Write-Host ""
    Write-Host "Total sessions: $($state.statistics.total_sessions)" -ForegroundColor Gray
    Write-Host "Avg messages/session: $($state.statistics.average_messages_per_session)" -ForegroundColor Gray
    
    if ($state.settings.auto_generate_migration) {
        Write-Host ""
        Write-Host "Migration file ready: 09_MIGRATION_TO_NEW_SESSION.md" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "For next session:" -ForegroundColor Yellow
    Write-Host "   1. Open new Claude conversation" -ForegroundColor Gray
    Write-Host "   2. Paste 04_SESSION_START.md" -ForegroundColor Gray
    Write-Host "   3. Paste 09_MIGRATION_TO_NEW_SESSION.md" -ForegroundColor Gray
    Write-Host "   4. Run: .\session_tracker.ps1 -Start" -ForegroundColor Gray
    Write-Host ""
}

function Show-SessionStatus {
    $state = Get-SessionState
    
    if (-not $state.current_session) {
        Write-Host ""
        Write-Host "No active session" -ForegroundColor Yellow
        Write-Host "Run: .\session_tracker.ps1 -Start" -ForegroundColor Gray
        Write-Host ""
        
        if ($state.statistics.total_sessions -gt 0) {
            Write-Host "Last session: $($state.statistics.last_session_date)" -ForegroundColor Gray
            Write-Host "Total sessions: $($state.statistics.total_sessions)" -ForegroundColor Gray
            Write-Host "Total messages: $($state.statistics.total_messages)" -ForegroundColor Gray
            Write-Host "Average messages/session: $($state.statistics.average_messages_per_session)" -ForegroundColor Gray
            Write-Host ""
        }
        
        return
    }
    
    $session = $state.current_session
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  CURRENT SESSION STATUS" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Session ID: $($session.id)" -ForegroundColor White
    Write-Host "Started: $($session.started)" -ForegroundColor Gray
    Write-Host "Messages: $($session.messages)" -ForegroundColor Gray
    
    Show-ProgressBar -Current $session.messages -Warning $state.settings.warning_threshold -Danger $state.settings.danger_threshold
    
    Write-Host "Settings:" -ForegroundColor Yellow
    Write-Host "  Warning threshold: $($state.settings.warning_threshold)" -ForegroundColor Gray
    Write-Host "  Danger threshold: $($state.settings.danger_threshold)" -ForegroundColor Gray
    Write-Host "  Notifications: $($state.settings.show_notifications)" -ForegroundColor Gray
    Write-Host "  Auto-migration: $($state.settings.auto_generate_migration)" -ForegroundColor Gray
    Write-Host ""
}

if ($Start) {
    Start-SessionTracking
}
elseif ($AddMessage) {
    Add-SessionMessage
}
elseif ($End) {
    Stop-SessionTracking -Summary $Summary -NextSteps $NextSteps -ConversationUrl $ConversationUrl
}
elseif ($Status) {
    Show-SessionStatus
}
else {
    Write-Host ""
    Write-Host "HubPersonal Session Tracker" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Track Claude conversation messages locally (zero cost)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  -Start                    Start new session tracking" -ForegroundColor White
    Write-Host "  -AddMessage              Increment message counter" -ForegroundColor White
    Write-Host "  -Status                  Show current session status" -ForegroundColor White
    Write-Host "  -End                     End session" -ForegroundColor White
    Write-Host "    -Summary 'text'         What was accomplished" -ForegroundColor Gray
    Write-Host "    -NextSteps 'text'       What to do next" -ForegroundColor Gray
    Write-Host "    -ConversationUrl 'url'  Link to conversation" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\session_tracker.ps1 -Start" -ForegroundColor Gray
    Write-Host "  .\session_tracker.ps1 -AddMessage" -ForegroundColor Gray
    Write-Host "  .\session_tracker.ps1 -Status" -ForegroundColor Gray
    Write-Host "  .\session_tracker.ps1 -End -Summary 'Tested watcher' -NextSteps 'Start Laravel'" -ForegroundColor Gray
    Write-Host ""
}
