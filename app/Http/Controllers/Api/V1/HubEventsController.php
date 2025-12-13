<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\HubEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @meta-start
 * @session: 2025-11-25-001
 * @file: app/Http/Controllers/Api/V1/HubEventsController.php
 * @refs: [ARCH:EVENTS]
 * @changes: Added events endpoint scaffolding with incremental pagination
 * @doc-update: [ARCH:EVENTS] ADD hub events endpoint contract
 * @meta-end
 */
class HubEventsController
{
    public function __invoke(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'since' => ['nullable', 'date'],
            'cursor' => ['nullable', 'string', 'size:26'], // ULID length
            'limit' => ['nullable', 'integer', 'min:1', 'max:200'],
        ]);

        $limit = $validated['limit'] ?? 50;

        $query = HubEvent::query()->orderBy('occurred_at')->orderBy('id');

        if (!empty($validated['since'])) {
            $query->where('occurred_at', '>=', $validated['since']);
        }

        if (!empty($validated['cursor'])) {
            $query->where('id', '>', $validated['cursor']);
        }

        $events = $query
            ->limit($limit + 1) // Fetch one extra to check if there are more
            ->get();

        $hasMore = $events->count() > $limit;
        $data = $events->take($limit);
        $nextCursor = $hasMore ? $events->get($limit - 1)->id : null;

        return response()->json([
            'data' => $data->map(fn (HubEvent $event) => [
                'id' => $event->id,
                'type' => $event->type->value,
                'version' => $event->version,
                'source' => $event->source,
                'occurred_at' => $event->occurred_at?->toIso8601String(),
                'payload' => $event->payload ?? [],
            ]),
            'next_cursor' => $nextCursor,
            'has_more' => $hasMore,
        ]);
    }
}
