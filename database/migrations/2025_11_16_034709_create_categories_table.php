<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: database/migrations/2025_11_16_034700_create_categories_table.php
 * @refs: [DB:SCHEMA_NOTES]
 * @changes: Created categories table for note organization
 * @doc-update: [DB:SCHEMA_NOTES] ADD Categories table created (user-specific)
 * @meta-end
 */

return new class extends Migration
{
    /**
     * Crear tabla de categorías
     */
    public function up(): void
    {
        // Verificar que la tabla no existe
        if (!Schema::hasTable('categories')) {
            Schema::create('categories', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')
                    ->constrained()
                    ->cascadeOnDelete();
                $table->string('name', 100);
                $table->string('color', 20)->nullable();
                $table->timestamps();
                
                // Índices
                $table->index('user_id');
                $table->unique(['user_id', 'name']); // Evitar categorías duplicadas por usuario
            });
        }
    }

    /**
     * Revertir migración
     */
    public function down(): void
    {
        Schema::dropIfExists('categories');
    }
};