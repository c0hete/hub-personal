<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: database/migrations/2025_11_16_034800_create_tags_table.php
 * @refs: [DB:SCHEMA_TAGS]
 * @changes: Created tags and notes_tags tables for tagging system
 * @doc-update: [DB:SCHEMA_TAGS] ADD Tags tables created and tested
 * @meta-end
 */

return new class extends Migration
{
    /**
     * Crear tablas de tags
     */
    public function up(): void
    {
        // Tabla tags
        if (!Schema::hasTable('tags')) {
            Schema::create('tags', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')
                    ->constrained()
                    ->cascadeOnDelete();
                $table->string('name', 100);
                $table->string('color', 20)->nullable();
                $table->timestamps();
                
                // Índices
                $table->index('user_id');
                $table->unique(['user_id', 'name']); // Tag único por usuario
            });
        }

        // Tabla pivot notes_tags
        if (!Schema::hasTable('notes_tags')) {
            Schema::create('notes_tags', function (Blueprint $table) {
                $table->foreignId('note_id')
                    ->constrained()
                    ->cascadeOnDelete();
                $table->foreignId('tag_id')
                    ->constrained()
                    ->cascadeOnDelete();
                
                $table->primary(['note_id', 'tag_id']);
                
                // Índices
                $table->index('note_id');
                $table->index('tag_id');
            });
        }
    }

    /**
     * Revertir migraciones
     */
    public function down(): void
    {
        Schema::dropIfExists('notes_tags');
        Schema::dropIfExists('tags');
    }
};