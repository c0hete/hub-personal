<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\JsonResponse;

/**
 * @meta-start
 * @session: 2025-11-25-001
 * @file: app/Http/Controllers/Api/V1/HubSourcesController.php
 * @refs: [ARCH:EVENTS]
 * @changes: Added sources endpoint returning configured agents/services
 * @doc-update: [ARCH:EVENTS] ADD hub sources endpoint contract
 * @meta-end
 */
class HubSourcesController
{
    public function __invoke(): JsonResponse
    {
        return response()->json([
            'data' => config('hub.sources', []),
        ]);
    }
}
