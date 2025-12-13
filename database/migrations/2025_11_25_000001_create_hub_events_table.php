<?php

use App\Enums\HubEventType;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * @meta-start
 * @session: 2025-11-25-001
 * @file: database/migrations/2025_11_25_000001_create_hub_events_table.php
 * @refs: [ARCH:EVENTS]
 * @changes: Created hub_events table to persist outbound event stream
 * @doc-update: [ARCH:EVENTS] ADD hub_events persistence for supervisor contract
 * @meta-end
 */
return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('hub_events', function (Blueprint $table) {
            $table->ulid('id')->primary();
            $table->string('type', 100);
            $table->unsignedTinyInteger('version')->default(1);
            $table->string('source', 100)->nullable();
            $table->jsonb('payload')->nullable();
            $table->timestamp('occurred_at');
            $table->timestamps();

            $table->index('occurred_at');
            $table->index('type');
            $table->index(['type', 'occurred_at']); // Composite index for filtered time queries
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('hub_events');
    }
};
