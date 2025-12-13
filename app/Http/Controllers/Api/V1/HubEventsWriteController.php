<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\HubEventType;
use App\Models\HubEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Enum;

/**
 * @meta-start
 * @session: 2025-12-13-002
 * @file: app/Http/Controllers/Api/V1/HubEventsWriteController.php
 * @refs: [ARCH:EVENTS]
 * @changes: Created write endpoint for agents to report events
 * @doc-update: [ARCH:EVENTS] ADD POST /api/v1/hub/events for agent writes
 * @meta-end
 */
class HubEventsWriteController
{
    public function __invoke(Request $request): JsonResponse
    {
        // Verify hub:write scope
        $token = $request->user()->currentAccessToken();

        if (!$token || !$token->can('hub:write')) {
            return response()->json([
                'error' => 'insufficient_permissions',
                'message' => 'Token requires hub:write scope',
            ], 403);
        }

        $validated = $request->validate([
            'type' => ['required', 'string', new Enum(HubEventType::class)],
            'source' => ['required', 'string', 'max:100'],
            'occurred_at' => ['required', 'date', 'before_or_equal:now +5 minutes'],
            'payload' => ['nullable', 'array'],
            'version' => ['nullable', 'integer', 'min:1', 'max:255'],
        ]);

        // Security: Verify source matches token name (agent identity)
        $tokenName = $token->name;
        $expectedSource = $this->extractSourceFromTokenName($tokenName);

        if ($expectedSource && $validated['source'] !== $expectedSource) {
            return response()->json([
                'error' => 'source_mismatch',
                'message' => "Source '{$validated['source']}' does not match token identity '{$expectedSource}'",
            ], 403);
        }

        // Create event
        $event = HubEvent::create([
            'type' => HubEventType::from($validated['type']),
            'source' => $validated['source'],
            'occurred_at' => $validated['occurred_at'],
            'payload' => $validated['payload'] ?? [],
            'version' => $validated['version'] ?? 1,
        ]);

        return response()->json([
            'id' => $event->id,
            'type' => $event->type->value,
            'source' => $event->source,
            'occurred_at' => $event->occurred_at->toIso8601String(),
            'created_at' => $event->created_at->toIso8601String(),
        ], 201);
    }

    /**
     * Extract source identifier from token name.
     * Token naming convention: "<source>-<env>" (e.g., "energyapp-prod", "supervisor-prod")
     */
    private function extractSourceFromTokenName(?string $tokenName): ?string
    {
        if (!$tokenName) {
            return null;
        }

        // Extract first part before hyphen (e.g., "energyapp-prod" -> "energyapp")
        $parts = explode('-', $tokenName);

        return $parts[0] ?? null;
    }
}
