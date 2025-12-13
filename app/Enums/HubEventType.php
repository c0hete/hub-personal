<?php

namespace App\Enums;

/**
 * @meta-start
 * @session: 2025-11-25-001
 * @file: app/Enums/HubEventType.php
 * @refs: [ARCH:EVENTS]
 * @changes: Added HubEventType enum for supervisor-facing events
 * @doc-update: [ARCH:EVENTS] ADD HubEventType enum to formalize outbound event types
 * @meta-end
 */
enum HubEventType: string
{
    case AppRegistered = 'AppRegistered';
    case AgentHeartbeat = 'AgentHeartbeat';
    case InteractionDetected = 'InteractionDetected';
    case MetricReported = 'MetricReported';
    case ErrorReported = 'ErrorReported';
    case SecuritySignal = 'SecuritySignal';
    case DeploySignal = 'DeploySignal';
}
