<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: app/Models/Note.php
 * @refs: [ARCH:FOLDERS, DB:SCHEMA_NOTES]
 * @changes: Updated Note model with relationships and scopes
 * @doc-update: [ARCH:FOLDERS] ADD Note.php relationships and scopes implemented
 * @meta-end
 */

class Note extends Model
{
    use SoftDeletes;

    /**
     * Campos asignables en masa
     */
    protected $fillable = [
        'title',
        'content',
        'date',
        'time',
        'is_pinned',
        'color',
        'priority',
        'reminder_minutes',
        'recurrence',
        'metadata',
    ];

    /**
     * Conversión de tipos
     */
    protected $casts = [
        'date' => 'date',
        'time' => 'datetime:H:i',
        'is_pinned' => 'boolean',
        'metadata' => 'array',
        'deleted_at' => 'datetime',
    ];

    /**
     * Valores por defecto
     */
    protected $attributes = [
        'color' => 'yellow',
        'priority' => 'medium',
        'is_pinned' => false,
    ];

    /**
     * Relación: nota pertenece a un usuario
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relación: nota pertenece a una categoría (opcional)
     */
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    /**
     * Relación: nota tiene muchos tags
     */
    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class, 'notes_tags');
    }

    /**
     * Scope: notas del usuario autenticado
     */
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope: notas fijadas
     */
    public function scopePinned($query)
    {
        return $query->where('is_pinned', true);
    }

    /**
     * Scope: notas rápidas (sin fecha)
     */
    public function scopeQuick($query)
    {
        return $query->whereNull('date');
    }

    /**
     * Scope: notas programadas (con fecha)
     */
    public function scopeScheduled($query)
    {
        return $query->whereNotNull('date');
    }

    /**
     * Scope: búsqueda full-text
     */
    public function scopeSearch($query, $term)
    {
        return $query->where(function ($q) use ($term) {
            $q->where('title', 'LIKE', "%{$term}%")
              ->orWhere('content', 'LIKE', "%{$term}%");
        });
    }

    /**
     * Accessor: indica si es nota programada
     */
    public function getIsScheduledAttribute(): bool
    {
        return !is_null($this->date);
    }

    /**
     * Accessor: fecha formateada en español
     */
    public function getFormattedDateAttribute(): ?string
    {
        return $this->date?->format('d/m/Y');
    }
}