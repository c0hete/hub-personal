<?php

namespace App\Models;

use App\Enums\HubEventType;
use Illuminate\Database\Eloquent\Concerns\HasUlids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * @meta-start
 * @session: 2025-11-25-001
 * @file: app/Models/HubEvent.php
 * @refs: [ARCH:EVENTS]
 * @changes: Created HubEvent model to expose persisted supervisor events
 * @doc-update: [ARCH:EVENTS] ADD HubEvent model for outbound event stream
 * @meta-end
 */
class HubEvent extends Model
{
    use HasFactory;
    use HasUlids;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'id',
        'type',
        'version',
        'source',
        'payload',
        'occurred_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'type' => HubEventType::class,
        'payload' => 'array',
        'occurred_at' => 'datetime',
        'version' => 'integer',
    ];
}
