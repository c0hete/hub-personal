<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: app/Models/Category.php
 * @refs: [ARCH:FOLDERS]
 * @changes: Created Category model for note organization
 * @doc-update: [ARCH:FOLDERS] ADD Category.php in app/Models/
 * @meta-end
 */

class Category extends Model
{
    /**
     * Campos asignables en masa
     */
    protected $fillable = [
        'name',
        'color',
    ];

    /**
     * Relación: categoría pertenece a un usuario
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relación: categoría tiene muchas notas
     */
    public function notes(): HasMany
    {
        return $this->hasMany(Note::class);
    }

    /**
     * Scope: categorías del usuario autenticado
     */
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }
}