<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: database/migrations/2025_11_16_000001_create_notes_table.php
 * @refs: [DB:SCHEMA_NOTES]
 * @changes: Created notes table migration matching MASTER schema
 * @doc-update: [DB:SCHEMA_NOTES] ADD Migration created and tested
 * @meta-end
 */

return new class extends Migration
{
    /**
     * Crear tabla de notas
     */
    public function up(): void
    {
        // Verificar que la tabla no existe
        if (!Schema::hasTable('notes')) {
            Schema::create('notes', function (Blueprint $table) {
                $table->id();
                
                // Relaciones
                $table->foreignId('user_id')
                    ->constrained()
                    ->cascadeOnDelete();
                $table->foreignId('category_id')
                    ->nullable()
                    ->constrained()
                    ->nullOnDelete();
                
                // Contenido
                $table->string('title', 200)->nullable();
                $table->text('content');
                
                // Fechas opcionales (para scheduled notes)
                $table->date('date')->nullable();
                $table->time('time')->nullable();
                
                // Configuración
                $table->boolean('is_pinned')->default(false);
                $table->string('color', 20)->default('yellow');
                $table->string('priority', 10)->default('medium');
                
                // Recordatorios y recurrencia
                $table->integer('reminder_minutes')->nullable();
                $table->string('recurrence', 20)->nullable();
                
                // Metadata JSON para extensibilidad
                $table->json('metadata')->nullable();
                
                // Timestamps y soft deletes
                $table->timestamps();
                $table->softDeletes();
                
                // Índices para rendimiento
                $table->index('user_id');
                $table->index('date');
                $table->index('is_pinned');
                $table->index('deleted_at');
            });
            
            // Índice full-text para búsqueda (PostgreSQL)
            if (DB::getDriverName() === 'pgsql') {
                DB::statement("
                    CREATE INDEX idx_notes_search 
                    ON notes 
                    USING gin(to_tsvector('english', coalesce(title,'') || ' ' || content))
                ");
            }
        }
    }

    /**
     * Revertir migración
     */
    public function down(): void
    {
        Schema::dropIfExists('notes');
    }
};