<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\JsonResponse;

/**
 * @meta-start
 * @session: 2025-11-25-001
 * @file: app/Http/Controllers/Api/V1/HubHeartbeatController.php
 * @refs: [ARCH:EVENTS]
 * @changes: Added heartbeat endpoint for supervisor health checks
 * @doc-update: [ARCH:EVENTS] ADD heartbeat endpoint contract
 * @meta-end
 */
class HubHeartbeatController
{
    public function __invoke(): JsonResponse
    {
        return response()->json([
            'ok' => true,
            'at' => now()->toIso8601String(),
        ]);
    }
}
