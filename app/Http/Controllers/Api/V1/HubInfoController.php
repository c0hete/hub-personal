<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\JsonResponse;

/**
 * @meta-start
 * @session: 2025-11-25-001
 * @file: app/Http/Controllers/Api/V1/HubInfoController.php
 * @refs: [ARCH:EVENTS]
 * @changes: Added API controller exposing hub metadata for supervisor
 * @doc-update: [ARCH:EVENTS] ADD hub info endpoint contract
 * @meta-end
 */
class HubInfoController
{
    public function __invoke(): JsonResponse
    {
        $requestTime = (float) ($_SERVER['REQUEST_TIME_FLOAT'] ?? microtime(true));
        $uptimeSeconds = (int) max(0, microtime(true) - $requestTime);

        return response()->json([
            'name' => config('app.name', 'HubPersonal'),
            'env' => app()->environment(),
            'version' => config('hub.version', '0.0.0'),
            'uptime_seconds' => $uptimeSeconds,
            'time' => now()->toIso8601String(),
        ]);
    }
}
