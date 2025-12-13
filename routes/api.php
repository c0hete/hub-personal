<?php

use App\Http\Controllers\Api\V1\HubEventsController;
use App\Http\Controllers\Api\V1\HubEventsWriteController;
use App\Http\Controllers\Api\V1\HubHeartbeatController;
use App\Http\Controllers\Api\V1\HubInfoController;
use App\Http\Controllers\Api\V1\HubSourcesController;
use Illuminate\Support\Facades\Route;

/**
 * @meta-start
 * @session: 2025-12-13-002
 * @file: routes/api.php
 * @refs: [ARCH:ROUTING]
 * @changes: Added POST /hub/events for agent writes (hub:write scope)
 * @doc-update: [ARCH:ROUTING] ADD write endpoint for agents
 * @meta-end
 */

// Hub API endpoints
Route::prefix('v1')
    ->name('api.v1.')
    ->middleware(['auth:sanctum', 'throttle:hub-api'])
    ->group(function () {
        // Read-only endpoints (hub:read scope validated in controller)
        Route::get('/hub/info', HubInfoController::class)->name('hub.info');
        Route::get('/hub/heartbeat', HubHeartbeatController::class)->name('hub.heartbeat');
        Route::get('/hub/sources', HubSourcesController::class)->name('hub.sources');
        Route::get('/hub/events', HubEventsController::class)->name('hub.events');

        // Write endpoints (hub:write scope validated in controller)
        Route::post('/hub/events', HubEventsWriteController::class)->name('hub.events.create');
    });
